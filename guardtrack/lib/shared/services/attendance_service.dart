import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../core/errors/exceptions.dart';
import '../models/attendance_model.dart';
import '../models/site_model.dart';
import '../models/user_model.dart';
import 'location_service.dart';
import 'geofencing_service.dart';
import 'database_service.dart';
import 'check_in_notification_service.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  final LocationService _locationService = LocationService();
  final GeofencingService _geofencingService = GeofencingService();
  final CheckInNotificationService _notificationService =
      CheckInNotificationService();
  final Uuid _uuid = const Uuid();

  // Generate unique arrival code
  String generateArrivalCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    return List.generate(
      AppConstants.arrivalCodeLength,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  // Validate check-in requirements
  Future<AttendanceValidationResult> validateCheckIn({
    required SiteModel site,
    Position? position,
    double? customAccuracyThreshold,
  }) async {
    try {
      // Get current position if not provided
      final currentPosition = position ??
          await _locationService.getAccuratePosition(
            requiredAccuracy:
                customAccuracyThreshold ?? AppConstants.defaultLocationAccuracy,
          );

      // Check GPS accuracy
      final accuracyThreshold =
          customAccuracyThreshold ?? AppConstants.defaultLocationAccuracy;
      if (currentPosition.accuracy > accuracyThreshold) {
        return AttendanceValidationResult(
          isValid: false,
          errorMessage:
              'GPS accuracy is too low (${currentPosition.accuracy.toStringAsFixed(1)}m). Required: ${accuracyThreshold.toStringAsFixed(1)}m or better.',
          position: currentPosition,
        );
      }

      // Validate geofence
      final isWithinGeofence = await _geofencingService.validateCheckInLocation(
        site.id,
        position: currentPosition,
      );

      if (!isWithinGeofence) {
        final distance = _locationService.calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          site.latitude,
          site.longitude,
        );

        return AttendanceValidationResult(
          isValid: false,
          errorMessage:
              'You are ${distance.toStringAsFixed(0)}m away from the site. You must be within ${site.allowedRadius.toStringAsFixed(0)}m to check in.',
          position: currentPosition,
          distance: distance,
        );
      }

      return AttendanceValidationResult(
        isValid: true,
        position: currentPosition,
        distance: _locationService.calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          site.latitude,
          site.longitude,
        ),
      );
    } catch (e) {
      return AttendanceValidationResult(
        isValid: false,
        errorMessage: 'Validation failed: $e',
      );
    }
  }

  // Create check-in record
  Future<AttendanceModel> createCheckIn({
    required String guardId,
    required SiteModel site,
    Position? position,
    String? photoUrl,
    String? notes,
  }) async {
    // Validate check-in first
    final validation = await validateCheckIn(site: site, position: position);

    if (!validation.isValid) {
      throw ValidationException(message: validation.errorMessage!);
    }

    final currentPosition = validation.position!;
    final arrivalCode = generateArrivalCode();

    final attendance = AttendanceModel(
      id: _uuid.v4(),
      guardId: guardId,
      siteId: site.id,
      type: AttendanceType.checkIn,
      status: AttendanceStatus.pending,
      arrivalCode: arrivalCode,
      latitude: currentPosition.latitude,
      longitude: currentPosition.longitude,
      accuracy: currentPosition.accuracy,
      timestamp: DateTime.now(),
      photoUrl: photoUrl,
      notes: notes,
      createdAt: DateTime.now(),
    );

    return attendance;
  }

  // Create check-out record
  Future<AttendanceModel> createCheckOut({
    required String guardId,
    required SiteModel site,
    Position? position,
    String? photoUrl,
    String? notes,
  }) async {
    try {
      // Get current position
      final currentPosition =
          position ?? await _locationService.getCurrentPosition();

      final arrivalCode = generateArrivalCode();

      final attendance = AttendanceModel(
        id: _uuid.v4(),
        guardId: guardId,
        siteId: site.id,
        type: AttendanceType.checkOut,
        status: AttendanceStatus.pending,
        arrivalCode: arrivalCode,
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        accuracy: currentPosition.accuracy,
        timestamp: DateTime.now(),
        photoUrl: photoUrl,
        notes: notes,
        createdAt: DateTime.now(),
      );

      return attendance;
    } catch (e) {
      throw ValidationException(message: 'Check-out failed: $e');
    }
  }

  // Verify attendance record
  AttendanceModel verifyAttendance({
    required AttendanceModel attendance,
    required String verifiedBy,
    String? adminNotes,
  }) {
    return attendance.copyWith(
      status: AttendanceStatus.verified,
      verifiedBy: verifiedBy,
      verifiedAt: DateTime.now(),
      adminNotes: adminNotes,
      updatedAt: DateTime.now(),
    );
  }

  // Reject attendance record
  AttendanceModel rejectAttendance({
    required AttendanceModel attendance,
    required String verifiedBy,
    required String reason,
  }) {
    return attendance.copyWith(
      status: AttendanceStatus.rejected,
      verifiedBy: verifiedBy,
      verifiedAt: DateTime.now(),
      adminNotes: reason,
      updatedAt: DateTime.now(),
    );
  }

  // Calculate distance between attendance location and site
  double calculateAttendanceDistance(
      AttendanceModel attendance, SiteModel site) {
    return _locationService.calculateDistance(
      attendance.latitude,
      attendance.longitude,
      site.latitude,
      site.longitude,
    );
  }

  // Check if attendance is within acceptable accuracy
  bool isAttendanceAccurate(AttendanceModel attendance, {double? threshold}) {
    final accuracyThreshold = threshold ?? AppConstants.defaultLocationAccuracy;
    return attendance.accuracy <= accuracyThreshold;
  }

  // Get attendance summary for a guard
  AttendanceSummary getAttendanceSummary(List<AttendanceModel> attendanceList) {
    final checkIns = attendanceList.where((a) => a.isCheckIn).toList();
    final checkOuts = attendanceList.where((a) => a.isCheckOut).toList();

    final verified = attendanceList.where((a) => a.isVerified).length;
    final pending = attendanceList.where((a) => a.isPending).length;
    final rejected = attendanceList.where((a) => a.isRejected).length;

    return AttendanceSummary(
      totalRecords: attendanceList.length,
      checkIns: checkIns.length,
      checkOuts: checkOuts.length,
      verified: verified,
      pending: pending,
      rejected: rejected,
    );
  }

  // Format arrival code for display
  String formatArrivalCode(String code) {
    if (code.length == 6) {
      return '${code.substring(0, 3)}-${code.substring(3)}';
    }
    return code;
  }

  // Get current attendance for a guard
  Future<AttendanceModel?> getCurrentAttendance(String guardId) async {
    // Mock implementation - replace with actual database query
    await Future.delayed(const Duration(milliseconds: 200));
    return null; // No current attendance
  }

  // Perform check-in
  Future<String> checkIn({
    required String guardId,
    required String siteId,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    try {
      // Get site information
      final databaseService = DatabaseService();
      final sites = await databaseService.getSites();
      final site = sites.firstWhere((s) => s.id == siteId);

      // Get user information
      final user = await databaseService.getUser(guardId);
      if (user == null) {
        throw const ValidationException(message: 'User not found');
      }

      // Create position object
      final position = Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: accuracy,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      // Create attendance record
      final attendance = await createCheckIn(
        guardId: guardId,
        site: site,
        position: position,
      );

      // Save to database
      await databaseService.insertAttendance(attendance);

      // Trigger notification service
      await _notificationService.processCheckInEvent(
        attendance: attendance,
        employee: user,
        site: site,
      );

      Logger.info(
        'Check-in completed: ${user.fullName} at ${site.name}',
        tag: 'AttendanceService',
      );

      return attendance.arrivalCode;
    } catch (e) {
      Logger.error('Check-in failed: $e', tag: 'AttendanceService');
      throw ValidationException(message: 'Check-in failed: $e');
    }
  }

  // Perform check-out
  Future<void> checkOut({
    required String guardId,
    required String siteId,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    // Mock implementation - replace with actual database operations
    await Future.delayed(const Duration(milliseconds: 500));

    // Here you would typically:
    // 1. Update attendance record with check-out time
    // 2. Store GPS coordinates and timestamp
    // 3. Calculate total hours worked
  }
}

class AttendanceValidationResult {
  final bool isValid;
  final String? errorMessage;
  final Position? position;
  final double? distance;

  const AttendanceValidationResult({
    required this.isValid,
    this.errorMessage,
    this.position,
    this.distance,
  });
}

class AttendanceSummary {
  final int totalRecords;
  final int checkIns;
  final int checkOuts;
  final int verified;
  final int pending;
  final int rejected;

  const AttendanceSummary({
    required this.totalRecords,
    required this.checkIns,
    required this.checkOuts,
    required this.verified,
    required this.pending,
    required this.rejected,
  });

  double get verificationRate {
    if (totalRecords == 0) return 0.0;
    return verified / totalRecords;
  }

  double get rejectionRate {
    if (totalRecords == 0) return 0.0;
    return rejected / totalRecords;
  }
}
