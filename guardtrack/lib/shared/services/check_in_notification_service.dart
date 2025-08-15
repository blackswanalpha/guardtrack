import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/utils/logger.dart';
import '../../core/errors/exceptions.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';
import '../models/site_model.dart';
import 'notification_service.dart';
import 'database_service.dart';
import 'whatsapp_attendance_service.dart';

/// Service for handling real-time check-in notifications
/// Sends instant notifications to admin users when employees check in
class CheckInNotificationService {
  static final CheckInNotificationService _instance =
      CheckInNotificationService._internal();
  factory CheckInNotificationService() => _instance;
  CheckInNotificationService._internal();

  final NotificationService _notificationService = NotificationService();
  final DatabaseService _databaseService = DatabaseService();
  final WhatsAppAttendanceService _whatsappService =
      WhatsAppAttendanceService();

  // Stream controller for real-time check-in events
  final StreamController<CheckInEvent> _checkInStreamController =
      StreamController<CheckInEvent>.broadcast();

  // Stream for listening to check-in events
  Stream<CheckInEvent> get checkInStream => _checkInStreamController.stream;

  /// Initialize the check-in notification service
  Future<void> initialize() async {
    try {
      await _notificationService.initialize();
      Logger.info('CheckInNotificationService initialized successfully',
          tag: 'CheckInNotificationService');
    } catch (e) {
      throw NetworkException(
          message: 'Failed to initialize check-in notification service: $e');
    }
  }

  /// Process a check-in event and send notifications to all admin users
  Future<void> processCheckInEvent({
    required AttendanceModel attendance,
    required UserModel employee,
    required SiteModel site,
  }) async {
    try {
      // Create check-in event
      final checkInEvent = CheckInEvent(
        attendance: attendance,
        employee: employee,
        site: site,
        timestamp: DateTime.now(),
      );

      // Emit event to stream for real-time updates
      _checkInStreamController.add(checkInEvent);

      // Send instant notifications to all admin users
      await _sendInstantNotifications(checkInEvent);

      // Store event for daily reporting
      await _storeCheckInEvent(checkInEvent);

      Logger.info(
        'Check-in event processed: ${employee.fullName} at ${site.name}',
        tag: 'CheckInNotificationService',
      );
    } catch (e) {
      Logger.error(
        'Failed to process check-in event: $e',
        tag: 'CheckInNotificationService',
      );
      throw NetworkException(message: 'Failed to process check-in event: $e');
    }
  }

  /// Send instant notifications to all admin users
  Future<void> _sendInstantNotifications(CheckInEvent event) async {
    try {
      // Get all admin users
      final adminUsers = await _getAdminUsers();

      for (final admin in adminUsers) {
        // Send in-app notification
        await _sendInAppNotification(admin, event);

        // Send push notification (if FCM is enabled)
        await _sendPushNotification(admin, event);
      }

      // Send WhatsApp notification
      await _whatsappService.sendCheckInNotification(
        attendance: event.attendance,
        employee: event.employee,
        site: event.site,
      );
    } catch (e) {
      Logger.error('Failed to send instant notifications: $e',
          tag: 'CheckInNotificationService');
    }
  }

  /// Send in-app notification to admin user
  Future<void> _sendInAppNotification(
      UserModel admin, CheckInEvent event) async {
    try {
      final title = 'Employee Check-in Alert';
      final body =
          '${event.employee.fullName} checked in at ${event.site.name}';

      await _notificationService.showLocalNotification(
        title: title,
        body: body,
        payload: 'check_in_${event.attendance.id}',
      );
    } catch (e) {
      Logger.error('Failed to send in-app notification: $e',
          tag: 'CheckInNotificationService');
    }
  }

  /// Send push notification to admin user
  Future<void> _sendPushNotification(
      UserModel admin, CheckInEvent event) async {
    try {
      // Mock implementation - would integrate with FCM when enabled
      final title = 'GuardTrack Alert';
      final body =
          '${event.employee.fullName} checked in at ${event.site.name} at ${_formatTime(event.timestamp)}';

      Logger.info(
        'Push notification sent to ${admin.email}: $title - $body',
        tag: 'CheckInNotificationService',
      );
    } catch (e) {
      Logger.error('Failed to send push notification: $e',
          tag: 'CheckInNotificationService');
    }
  }

  /// Store check-in event for daily reporting
  Future<void> _storeCheckInEvent(CheckInEvent event) async {
    try {
      // Store in local database for daily report generation
      await _databaseService.insertCheckInEvent({
        'id': event.attendance.id,
        'employee_id': event.employee.id,
        'employee_name': event.employee.fullName,
        'site_id': event.site.id,
        'site_name': event.site.name,
        'check_in_time': event.timestamp.millisecondsSinceEpoch,
        'latitude': event.attendance.latitude,
        'longitude': event.attendance.longitude,
        'arrival_code': event.attendance.arrivalCode,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      Logger.error('Failed to store check-in event: $e',
          tag: 'CheckInNotificationService');
    }
  }

  /// Get all admin users from database
  Future<List<UserModel>> _getAdminUsers() async {
    try {
      final users = await _databaseService.getUsers();
      return users.where((user) => user.isAdmin).toList();
    } catch (e) {
      Logger.error('Failed to get admin users: $e',
          tag: 'CheckInNotificationService');
      return [];
    }
  }

  /// Format time for display
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Dispose resources
  void dispose() {
    _checkInStreamController.close();
  }
}

/// Model for check-in events
class CheckInEvent {
  final AttendanceModel attendance;
  final UserModel employee;
  final SiteModel site;
  final DateTime timestamp;

  const CheckInEvent({
    required this.attendance,
    required this.employee,
    required this.site,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'attendance': attendance.toJson(),
      'employee': employee.toJson(),
      'site': site.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
