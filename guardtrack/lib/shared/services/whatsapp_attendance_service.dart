import 'dart:async';
import 'package:intl/intl.dart';
import '../../core/utils/logger.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';
import '../models/site_model.dart';
import '../models/whatsapp_contact.dart';
import 'whatsapp_cloud_api_service.dart';
import 'database_service.dart';

class WhatsAppAttendanceService {
  static final WhatsAppAttendanceService _instance =
      WhatsAppAttendanceService._internal();
  factory WhatsAppAttendanceService() => _instance;
  WhatsAppAttendanceService._internal();

  final WhatsAppCloudApiService _whatsappService = WhatsAppCloudApiService();
  final DatabaseService _databaseService = DatabaseService();

  // Admin contacts who receive attendance notifications
  static const List<String> adminPhoneNumbers = [
    '+254792823173', // Main admin
    // Add more admin numbers as needed
  ];

  /// Send individual check-in notification
  Future<bool> sendCheckInNotification({
    required AttendanceModel attendance,
    required UserModel employee,
    required SiteModel site,
  }) async {
    try {
      final message = _generateCheckInMessage(attendance, employee, site);

      // Send to all admin numbers
      bool allSent = true;
      for (final phoneNumber in adminPhoneNumbers) {
        final success = await _sendMessage(phoneNumber, message);
        if (!success) allSent = false;
      }

      Logger.info(
        'Check-in notification sent for ${employee.fullName} at ${site.name}',
        tag: 'WhatsAppAttendanceService',
      );

      return allSent;
    } catch (e) {
      Logger.error('Failed to send check-in notification: $e',
          tag: 'WhatsAppAttendanceService');
      return false;
    }
  }

  /// Send daily attendance summary for all sites
  Future<bool> sendDailyAttendanceSummary({DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);

      Logger.info('Generating daily attendance summary for $dateStr',
          tag: 'WhatsAppAttendanceService');

      // Get all sites
      final sites = await _databaseService.getSites();
      final activeSites = sites.where((site) => site.isActive).toList();

      // Get attendance records for the date
      final attendanceRecords = await _getAttendanceForDate(targetDate);

      // Generate summary message
      final message = await _generateDailySummaryMessage(
        date: targetDate,
        sites: activeSites,
        attendanceRecords: attendanceRecords,
      );

      // Send to all admin numbers
      bool allSent = true;
      for (final phoneNumber in adminPhoneNumbers) {
        final success = await _sendMessage(phoneNumber, message);
        if (!success) allSent = false;
      }

      Logger.info('Daily attendance summary sent for $dateStr',
          tag: 'WhatsAppAttendanceService');
      return allSent;
    } catch (e) {
      Logger.error('Failed to send daily attendance summary: $e',
          tag: 'WhatsAppAttendanceService');
      return false;
    }
  }

  /// Send site-specific attendance report
  Future<bool> sendSiteAttendanceReport({
    required String siteId,
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);

      // Get site information
      final sites = await _databaseService.getSites();
      final site = sites.firstWhere((s) => s.id == siteId);

      // Get attendance records for the site and date
      final attendanceRecords = await _getAttendanceForSite(siteId, targetDate);

      // Generate site report message
      final message = await _generateSiteReportMessage(
        site: site,
        date: targetDate,
        attendanceRecords: attendanceRecords,
      );

      // Send to all admin numbers
      bool allSent = true;
      for (final phoneNumber in adminPhoneNumbers) {
        final success = await _sendMessage(phoneNumber, message);
        if (!success) allSent = false;
      }

      Logger.info('Site attendance report sent for ${site.name} on $dateStr',
          tag: 'WhatsAppAttendanceService');
      return allSent;
    } catch (e) {
      Logger.error('Failed to send site attendance report: $e',
          tag: 'WhatsAppAttendanceService');
      return false;
    }
  }

  /// Send bulk attendance notifications for multiple check-ins
  Future<Map<String, bool>> sendBulkCheckInNotifications({
    required List<AttendanceModel> attendanceList,
  }) async {
    final results = <String, bool>{};

    try {
      // Group attendance by site for better organization
      final attendanceBysite = <String, List<AttendanceModel>>{};

      for (final attendance in attendanceList) {
        if (!attendanceBysite.containsKey(attendance.siteId)) {
          attendanceBysite[attendance.siteId] = [];
        }
        attendanceBysite[attendance.siteId]!.add(attendance);
      }

      // Get all sites and users
      final sites = await _databaseService.getSites();
      final users = await _databaseService.getUsers();

      // Generate bulk message
      final message = await _generateBulkCheckInMessage(
        attendanceBysite: attendanceBysite,
        sites: sites,
        users: users,
      );

      // Send to all admin numbers
      for (final phoneNumber in adminPhoneNumbers) {
        final success = await _sendMessage(phoneNumber, message);
        results[phoneNumber] = success;
      }

      Logger.info(
          'Bulk check-in notifications sent for ${attendanceList.length} records',
          tag: 'WhatsAppAttendanceService');
      return results;
    } catch (e) {
      Logger.error('Failed to send bulk check-in notifications: $e',
          tag: 'WhatsAppAttendanceService');
      return results;
    }
  }

  /// Send attendance alerts for missing check-ins
  Future<bool> sendMissingCheckInAlerts({DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);

      // Get all active sites and assigned guards
      final sites = await _databaseService.getSites();
      final activeSites = sites.where((site) => site.isActive).toList();

      // Get attendance records for the date
      final attendanceRecords = await _getAttendanceForDate(targetDate);

      // Find missing check-ins
      final missingCheckIns =
          await _findMissingCheckIns(activeSites, attendanceRecords);

      if (missingCheckIns.isEmpty) {
        Logger.info('No missing check-ins found for $dateStr',
            tag: 'WhatsAppAttendanceService');
        return true;
      }

      // Generate alert message
      final message = _generateMissingCheckInAlert(missingCheckIns, targetDate);

      // Send to all admin numbers
      bool allSent = true;
      for (final phoneNumber in adminPhoneNumbers) {
        final success = await _sendMessage(phoneNumber, message);
        if (!success) allSent = false;
      }

      Logger.info('Missing check-in alerts sent for $dateStr',
          tag: 'WhatsAppAttendanceService');
      return allSent;
    } catch (e) {
      Logger.error('Failed to send missing check-in alerts: $e',
          tag: 'WhatsAppAttendanceService');
      return false;
    }
  }

  // Private helper methods
  Future<bool> _sendMessage(String phoneNumber, String message) async {
    try {
      final formattedPhone = _whatsappService.formatPhoneNumber(phoneNumber);

      // Try template first, then text message
      bool success = await _whatsappService.sendTemplateMessage(
        to: formattedPhone,
        templateName: 'hello_world',
        languageCode: 'en_US',
      );

      if (!success) {
        success = await _whatsappService.sendTextMessage(
          to: formattedPhone,
          message: message,
        );
      }

      return success;
    } catch (e) {
      Logger.error('Failed to send WhatsApp message to $phoneNumber: $e',
          tag: 'WhatsAppAttendanceService');
      return false;
    }
  }

  String _generateCheckInMessage(
      AttendanceModel attendance, UserModel employee, SiteModel site) {
    final timeStr = DateFormat('HH:mm').format(attendance.timestamp);
    final dateStr = DateFormat('MMM dd, yyyy').format(attendance.timestamp);

    return '''
🟢 CHECK-IN ALERT

👤 Employee: ${employee.fullName}
📍 Site: ${site.name}
⏰ Time: $timeStr
📅 Date: $dateStr
🔢 Code: ${attendance.arrivalCode}

${attendance.notes != null ? '📝 Notes: ${attendance.notes}' : ''}

Status: ${attendance.status.name.toUpperCase()}
''';
  }

  Future<String> _generateDailySummaryMessage({
    required DateTime date,
    required List<SiteModel> sites,
    required List<AttendanceModel> attendanceRecords,
  }) async {
    final dateStr = DateFormat('MMM dd, yyyy').format(date);
    final checkIns = attendanceRecords.where((a) => a.isCheckIn).toList();
    final checkOuts = attendanceRecords.where((a) => a.isCheckOut).toList();

    // Group by site
    final siteStats = <String, Map<String, int>>{};
    for (final site in sites) {
      final siteCheckIns = checkIns.where((a) => a.siteId == site.id).length;
      final siteCheckOuts = checkOuts.where((a) => a.siteId == site.id).length;
      siteStats[site.name] = {
        'checkIns': siteCheckIns,
        'checkOuts': siteCheckOuts,
      };
    }

    final buffer = StringBuffer();
    buffer.writeln('📊 DAILY ATTENDANCE SUMMARY');
    buffer.writeln('📅 Date: $dateStr');
    buffer.writeln('');
    buffer.writeln('📈 Overall Stats:');
    buffer.writeln('✅ Total Check-ins: ${checkIns.length}');
    buffer.writeln('🚪 Total Check-outs: ${checkOuts.length}');
    buffer.writeln('🏢 Active Sites: ${sites.length}');
    buffer.writeln('');
    buffer.writeln('📍 Site Breakdown:');

    for (final entry in siteStats.entries) {
      final siteName = entry.key;
      final stats = entry.value;
      buffer.writeln(
          '• $siteName: ${stats['checkIns']}↗️ ${stats['checkOuts']}↙️');
    }

    return buffer.toString();
  }

  Future<String> _generateSiteReportMessage({
    required SiteModel site,
    required DateTime date,
    required List<AttendanceModel> attendanceRecords,
  }) async {
    final dateStr = DateFormat('MMM dd, yyyy').format(date);
    final checkIns = attendanceRecords.where((a) => a.isCheckIn).toList();
    final checkOuts = attendanceRecords.where((a) => a.isCheckOut).toList();

    // Get employee details
    final users = await _databaseService.getUsers();

    final buffer = StringBuffer();
    buffer.writeln('🏢 SITE ATTENDANCE REPORT');
    buffer.writeln('📍 Site: ${site.name}');
    buffer.writeln('📅 Date: $dateStr');
    buffer.writeln('');
    buffer.writeln('📊 Summary:');
    buffer.writeln('✅ Check-ins: ${checkIns.length}');
    buffer.writeln('🚪 Check-outs: ${checkOuts.length}');
    buffer.writeln('');

    if (checkIns.isNotEmpty) {
      buffer.writeln('👥 Check-in Details:');
      for (final attendance in checkIns) {
        final employee = users.firstWhere((u) => u.id == attendance.guardId);
        final timeStr = DateFormat('HH:mm').format(attendance.timestamp);
        buffer.writeln(
            '• ${employee.fullName} - $timeStr (${attendance.arrivalCode})');
      }
    }

    return buffer.toString();
  }

  Future<String> _generateBulkCheckInMessage({
    required Map<String, List<AttendanceModel>> attendanceBysite,
    required List<SiteModel> sites,
    required List<UserModel> users,
  }) async {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);
    final dateStr = DateFormat('MMM dd, yyyy').format(now);

    final buffer = StringBuffer();
    buffer.writeln('📋 BULK CHECK-IN REPORT');
    buffer.writeln('⏰ Generated: $timeStr');
    buffer.writeln('📅 Date: $dateStr');
    buffer.writeln('');

    int totalCheckIns = 0;
    for (final entry in attendanceBysite.entries) {
      final siteId = entry.key;
      final attendanceList = entry.value;
      final site = sites.firstWhere((s) => s.id == siteId);

      totalCheckIns += attendanceList.length;

      buffer.writeln('🏢 ${site.name} (${attendanceList.length} check-ins):');
      for (final attendance in attendanceList) {
        final employee = users.firstWhere((u) => u.id == attendance.guardId);
        final checkInTime = DateFormat('HH:mm').format(attendance.timestamp);
        buffer.writeln('  • ${employee.fullName} - $checkInTime');
      }
      buffer.writeln('');
    }

    buffer.writeln(
        '📊 Total: $totalCheckIns check-ins across ${attendanceBysite.length} sites');
    return buffer.toString();
  }

  String _generateMissingCheckInAlert(
      List<Map<String, dynamic>> missingCheckIns, DateTime date) {
    final dateStr = DateFormat('MMM dd, yyyy').format(date);

    final buffer = StringBuffer();
    buffer.writeln('⚠️ MISSING CHECK-IN ALERT');
    buffer.writeln('📅 Date: $dateStr');
    buffer.writeln('');
    buffer.writeln('🚨 Employees who haven\'t checked in:');

    for (final missing in missingCheckIns) {
      final siteName = missing['siteName'] as String;
      final employeeName = missing['employeeName'] as String;
      buffer.writeln('• $employeeName at $siteName');
    }

    buffer.writeln('');
    buffer.writeln('📞 Please follow up with these employees.');
    return buffer.toString();
  }

  // Database helper methods
  Future<List<AttendanceModel>> _getAttendanceForDate(DateTime date) async {
    // Mock implementation - replace with actual database query
    // This should get all attendance records for the specified date
    return [];
  }

  Future<List<AttendanceModel>> _getAttendanceForSite(
      String siteId, DateTime date) async {
    // Mock implementation - replace with actual database query
    // This should get attendance records for a specific site and date
    return [];
  }

  Future<List<Map<String, dynamic>>> _findMissingCheckIns(
    List<SiteModel> sites,
    List<AttendanceModel> attendanceRecords,
  ) async {
    final missingCheckIns = <Map<String, dynamic>>[];

    // Mock implementation - replace with actual logic
    // This should compare expected employees vs actual check-ins

    return missingCheckIns;
  }
}
