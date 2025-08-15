import 'package:flutter_test/flutter_test.dart';
import 'package:guardtrack/shared/services/attendance_service.dart';
import 'package:guardtrack/shared/models/site_model.dart';
import 'package:guardtrack/shared/models/attendance_model.dart';
import 'package:guardtrack/core/constants/app_constants.dart';

void main() {
  group('AttendanceService', () {
    late AttendanceService attendanceService;

    setUp(() {
      attendanceService = AttendanceService();
    });

    group('generateArrivalCode', () {
      test('should generate code with correct length', () {
        // Act
        final code = attendanceService.generateArrivalCode();

        // Assert
        expect(code.length, equals(AppConstants.arrivalCodeLength));
      });

      test('should generate unique codes', () {
        // Act
        final code1 = attendanceService.generateArrivalCode();
        final code2 = attendanceService.generateArrivalCode();

        // Assert
        expect(code1, isNot(equals(code2)));
      });

      test('should generate codes with valid characters', () {
        // Act
        final code = attendanceService.generateArrivalCode();

        // Assert
        final validChars = RegExp(r'^[A-Z0-9]+$');
        expect(validChars.hasMatch(code), isTrue);
      });
    });

    group('formatArrivalCode', () {
      test('should format 6-character code correctly', () {
        // Arrange
        const code = 'ABC123';

        // Act
        final formatted = attendanceService.formatArrivalCode(code);

        // Assert
        expect(formatted, equals('ABC-123'));
      });

      test('should return original code if not 6 characters', () {
        // Arrange
        const code = 'ABC12';

        // Act
        final formatted = attendanceService.formatArrivalCode(code);

        // Assert
        expect(formatted, equals(code));
      });
    });

    group('calculateAttendanceDistance', () {
      test('should calculate correct distance between attendance and site', () {
        // Arrange
        final attendance = AttendanceModel(
          id: '1',
          guardId: 'guard1',
          siteId: 'site1',
          type: AttendanceType.checkIn,
          status: AttendanceStatus.pending,
          arrivalCode: 'ABC123',
          latitude: -1.2921,
          longitude: 36.8219,
          accuracy: 10.0,
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final site = SiteModel(
          id: 'site1',
          name: 'Test Site',
          address: 'Test Address',
          latitude: -1.2921,
          longitude: 36.8219,
          allowedRadius: 100.0,
          isActive: true,
          createdAt: DateTime.now(),
        );

        // Act
        final distance =
            attendanceService.calculateAttendanceDistance(attendance, site);

        // Assert
        expect(distance, equals(0.0));
      });
    });

    group('isAttendanceAccurate', () {
      test('should return true for accurate attendance', () {
        // Arrange
        final attendance = AttendanceModel(
          id: '1',
          guardId: 'guard1',
          siteId: 'site1',
          type: AttendanceType.checkIn,
          status: AttendanceStatus.pending,
          arrivalCode: 'ABC123',
          latitude: -1.2921,
          longitude: 36.8219,
          accuracy: 10.0,
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Act
        final isAccurate = attendanceService.isAttendanceAccurate(attendance);

        // Assert
        expect(isAccurate, isTrue);
      });

      test('should return false for inaccurate attendance', () {
        // Arrange
        final attendance = AttendanceModel(
          id: '1',
          guardId: 'guard1',
          siteId: 'site1',
          type: AttendanceType.checkIn,
          status: AttendanceStatus.pending,
          arrivalCode: 'ABC123',
          latitude: -1.2921,
          longitude: 36.8219,
          accuracy: 100.0, // Poor accuracy
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Act
        final isAccurate = attendanceService.isAttendanceAccurate(attendance);

        // Assert
        expect(isAccurate, isFalse);
      });
    });

    group('getAttendanceSummary', () {
      test('should calculate correct summary statistics', () {
        // Arrange
        final attendanceList = [
          AttendanceModel(
            id: '1',
            guardId: 'guard1',
            siteId: 'site1',
            type: AttendanceType.checkIn,
            status: AttendanceStatus.verified,
            arrivalCode: 'ABC123',
            latitude: -1.2921,
            longitude: 36.8219,
            accuracy: 10.0,
            timestamp: DateTime.now(),
            createdAt: DateTime.now(),
          ),
          AttendanceModel(
            id: '2',
            guardId: 'guard1',
            siteId: 'site1',
            type: AttendanceType.checkOut,
            status: AttendanceStatus.pending,
            arrivalCode: 'DEF456',
            latitude: -1.2921,
            longitude: 36.8219,
            accuracy: 15.0,
            timestamp: DateTime.now(),
            createdAt: DateTime.now(),
          ),
          AttendanceModel(
            id: '3',
            guardId: 'guard1',
            siteId: 'site1',
            type: AttendanceType.checkIn,
            status: AttendanceStatus.rejected,
            arrivalCode: 'GHI789',
            latitude: -1.2921,
            longitude: 36.8219,
            accuracy: 20.0,
            timestamp: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];

        // Act
        final summary = attendanceService.getAttendanceSummary(attendanceList);

        // Assert
        expect(summary.totalRecords, equals(3));
        expect(summary.checkIns, equals(2));
        expect(summary.checkOuts, equals(1));
        expect(summary.verified, equals(1));
        expect(summary.pending, equals(1));
        expect(summary.rejected, equals(1));
        expect(summary.verificationRate, closeTo(0.33, 0.01));
        expect(summary.rejectionRate, closeTo(0.33, 0.01));
      });

      test('should handle empty attendance list', () {
        // Arrange
        final attendanceList = <AttendanceModel>[];

        // Act
        final summary = attendanceService.getAttendanceSummary(attendanceList);

        // Assert
        expect(summary.totalRecords, equals(0));
        expect(summary.checkIns, equals(0));
        expect(summary.checkOuts, equals(0));
        expect(summary.verified, equals(0));
        expect(summary.pending, equals(0));
        expect(summary.rejected, equals(0));
        expect(summary.verificationRate, equals(0.0));
        expect(summary.rejectionRate, equals(0.0));
      });
    });

    group('verifyAttendance', () {
      test('should update attendance status to verified', () {
        // Arrange
        final attendance = AttendanceModel(
          id: '1',
          guardId: 'guard1',
          siteId: 'site1',
          type: AttendanceType.checkIn,
          status: AttendanceStatus.pending,
          arrivalCode: 'ABC123',
          latitude: -1.2921,
          longitude: 36.8219,
          accuracy: 10.0,
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Act
        final verified = attendanceService.verifyAttendance(
          attendance: attendance,
          verifiedBy: 'admin1',
          adminNotes: 'Verified successfully',
        );

        // Assert
        expect(verified.status, equals(AttendanceStatus.verified));
        expect(verified.verifiedBy, equals('admin1'));
        expect(verified.adminNotes, equals('Verified successfully'));
        expect(verified.verifiedAt, isNotNull);
        expect(verified.updatedAt, isNotNull);
      });
    });

    group('rejectAttendance', () {
      test('should update attendance status to rejected', () {
        // Arrange
        final attendance = AttendanceModel(
          id: '1',
          guardId: 'guard1',
          siteId: 'site1',
          type: AttendanceType.checkIn,
          status: AttendanceStatus.pending,
          arrivalCode: 'ABC123',
          latitude: -1.2921,
          longitude: 36.8219,
          accuracy: 10.0,
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Act
        final rejected = attendanceService.rejectAttendance(
          attendance: attendance,
          verifiedBy: 'admin1',
          reason: 'Location inaccurate',
        );

        // Assert
        expect(rejected.status, equals(AttendanceStatus.rejected));
        expect(rejected.verifiedBy, equals('admin1'));
        expect(rejected.adminNotes, equals('Location inaccurate'));
        expect(rejected.verifiedAt, isNotNull);
        expect(rejected.updatedAt, isNotNull);
      });
    });
  });
}
