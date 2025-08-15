import 'dart:async';
import '../../core/utils/logger.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';
import 'database_service.dart';
import 'notification_service.dart';
import 'smtp_email_service.dart';

/// Service for generating and sending daily attendance reports
/// Automatically sends reports at 8:00 AM via multiple channels
class DailyReportService {
  static final DailyReportService _instance = DailyReportService._internal();
  factory DailyReportService() => _instance;
  DailyReportService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final SMTPEmailService _smtpEmailService = SMTPEmailService();

  Timer? _dailyReportTimer;
  bool _isInitialized = false;

  /// Initialize the daily report service
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      await _notificationService.initialize();
      _scheduleDailyReports();
      _isInitialized = true;

      Logger.info('DailyReportService initialized successfully',
          tag: 'DailyReportService');
    } catch (e) {
      throw NetworkException(
          message: 'Failed to initialize daily report service: $e');
    }
  }

  /// Schedule daily reports to be sent at 8:00 AM
  void _scheduleDailyReports() {
    // Cancel existing timer if any
    _dailyReportTimer?.cancel();

    // Calculate time until next 8:00 AM
    final now = DateTime.now();
    var next8AM = DateTime(now.year, now.month, now.day, 8, 0, 0);

    // If it's already past 8 AM today, schedule for tomorrow
    if (now.isAfter(next8AM)) {
      next8AM = next8AM.add(const Duration(days: 1));
    }

    final timeUntilNext8AM = next8AM.difference(now);

    Logger.info(
      'Daily report scheduled for ${next8AM.toString()} (in ${timeUntilNext8AM.inHours}h ${timeUntilNext8AM.inMinutes % 60}m)',
      tag: 'DailyReportService',
    );

    // Schedule the first report
    _dailyReportTimer = Timer(timeUntilNext8AM, () {
      _sendDailyReport();

      // Schedule recurring daily reports every 24 hours
      _dailyReportTimer = Timer.periodic(const Duration(days: 1), (timer) {
        _sendDailyReport();
      });
    });
  }

  /// Generate and send daily report
  Future<void> _sendDailyReport() async {
    try {
      Logger.info('Generating daily attendance report...',
          tag: 'DailyReportService');

      final report = await generateDailyReport();
      await _sendReportToAdmins(report);

      Logger.info('Daily report sent successfully', tag: 'DailyReportService');
    } catch (e) {
      Logger.error('Failed to send daily report: $e',
          tag: 'DailyReportService');
    }
  }

  /// Generate daily attendance report for the previous day
  Future<DailyAttendanceReport> generateDailyReport({DateTime? date}) async {
    try {
      final reportDate =
          date ?? DateTime.now().subtract(const Duration(days: 1));
      final startOfDay =
          DateTime(reportDate.year, reportDate.month, reportDate.day);
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      // Get all check-in events for the day
      final checkInEvents =
          await _getCheckInEventsForDate(startOfDay, endOfDay);

      // Get all employees and sites
      final allEmployees = await _databaseService.getUsers();
      final allSites = await _databaseService.getSites();
      final activeEmployees = allEmployees
          .where((e) => e.role == UserRole.guard && e.isActive)
          .toList();

      // Process check-ins by employee
      final employeeCheckIns = <String, List<CheckInSummary>>{};
      final siteCheckIns = <String, List<CheckInSummary>>{};

      for (final event in checkInEvents) {
        final checkInSummary = CheckInSummary(
          employeeId: event['employee_id'],
          employeeName: event['employee_name'],
          siteId: event['site_id'],
          siteName: event['site_name'],
          checkInTime:
              DateTime.fromMillisecondsSinceEpoch(event['check_in_time']),
          arrivalCode: event['arrival_code'],
          latitude: event['latitude'],
          longitude: event['longitude'],
        );

        // Group by employee
        employeeCheckIns
            .putIfAbsent(event['employee_id'], () => [])
            .add(checkInSummary);

        // Group by site
        siteCheckIns
            .putIfAbsent(event['site_id'], () => [])
            .add(checkInSummary);
      }

      // Find employees who didn't check in
      final employeesWhoCheckedIn = employeeCheckIns.keys.toSet();
      final employeesWhoDidntCheckIn = activeEmployees
          .where((emp) => !employeesWhoCheckedIn.contains(emp.id))
          .map((emp) => EmployeeSummary(
                id: emp.id,
                name: emp.fullName,
                email: emp.email,
                phone: emp.phone,
              ))
          .toList();

      // Calculate statistics
      final totalActiveEmployees = activeEmployees.length;
      final totalCheckIns = checkInEvents.length;
      final uniqueEmployeesCheckedIn = employeeCheckIns.length;
      final attendanceRate = totalActiveEmployees > 0
          ? (uniqueEmployeesCheckedIn / totalActiveEmployees * 100)
          : 0.0;

      return DailyAttendanceReport(
        date: reportDate,
        totalActiveEmployees: totalActiveEmployees,
        totalCheckIns: totalCheckIns,
        uniqueEmployeesCheckedIn: uniqueEmployeesCheckedIn,
        attendanceRate: attendanceRate,
        employeeCheckIns: employeeCheckIns,
        siteCheckIns: siteCheckIns,
        employeesWhoDidntCheckIn: employeesWhoDidntCheckIn,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw NetworkException(message: 'Failed to generate daily report: $e');
    }
  }

  /// Get check-in events for a specific date range
  Future<List<Map<String, dynamic>>> _getCheckInEventsForDate(
      DateTime start, DateTime end) async {
    try {
      return await _databaseService.getCheckInEventsForDateRange(
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      );
    } catch (e) {
      Logger.error('Failed to get check-in events: $e',
          tag: 'DailyReportService');
      return [];
    }
  }

  /// Send report to all admin users via multiple channels
  Future<void> _sendReportToAdmins(DailyAttendanceReport report) async {
    try {
      final adminUsers = await _getAdminUsers();

      for (final admin in adminUsers) {
        // Send in-app notification
        await _sendInAppReportNotification(admin, report);

        // Send email (mock implementation)
        await _sendEmailReport(admin, report);

        // Send WhatsApp message (mock implementation)
        await _sendWhatsAppReport(admin, report);

        // Send SMS (mock implementation)
        await _sendSMSReport(admin, report);
      }
    } catch (e) {
      Logger.error('Failed to send report to admins: $e',
          tag: 'DailyReportService');
    }
  }

  /// Send in-app notification with report summary
  Future<void> _sendInAppReportNotification(
      UserModel admin, DailyAttendanceReport report) async {
    try {
      final title = 'Daily Attendance Report';
      final body =
          '${report.uniqueEmployeesCheckedIn}/${report.totalActiveEmployees} employees checked in (${report.attendanceRate.toStringAsFixed(1)}%)';

      await _notificationService.showLocalNotification(
        title: title,
        body: body,
        payload: 'daily_report_${report.date.millisecondsSinceEpoch}',
      );
    } catch (e) {
      Logger.error('Failed to send in-app report notification: $e',
          tag: 'DailyReportService');
    }
  }

  /// Send email report with PDF attachment
  Future<void> _sendEmailReport(
      UserModel admin, DailyAttendanceReport report) async {
    try {
      // Send daily attendance report via SMTP with PDF attachment
      await _smtpEmailService.sendDailyAttendanceReport(date: report.date);

      Logger.info(
        'Email report sent to ${admin.email}: Daily Attendance Report for ${_formatDate(report.date)}',
        tag: 'DailyReportService',
      );
    } catch (e) {
      Logger.error('Failed to send email report: $e',
          tag: 'DailyReportService');
    }
  }

  /// Send WhatsApp report (mock implementation)
  Future<void> _sendWhatsAppReport(
      UserModel admin, DailyAttendanceReport report) async {
    try {
      final whatsappMessage = _generateWhatsAppMessage(report);

      // Mock WhatsApp sending
      Logger.info(
        'WhatsApp report sent to ${admin.phone}: ${whatsappMessage.substring(0, 50)}...',
        tag: 'DailyReportService',
      );

      // TODO: Integrate with WhatsApp Business API
    } catch (e) {
      Logger.error('Failed to send WhatsApp report: $e',
          tag: 'DailyReportService');
    }
  }

  /// Send SMS report (mock implementation)
  Future<void> _sendSMSReport(
      UserModel admin, DailyAttendanceReport report) async {
    try {
      final smsMessage = _generateSMSMessage(report);

      // Mock SMS sending
      Logger.info(
        'SMS report sent to ${admin.phone}: $smsMessage',
        tag: 'DailyReportService',
      );

      // TODO: Integrate with SMS service (Twilio, AWS SNS, etc.)
    } catch (e) {
      Logger.error('Failed to send SMS report: $e', tag: 'DailyReportService');
    }
  }

  /// Get all admin users
  Future<List<UserModel>> _getAdminUsers() async {
    try {
      final users = await _databaseService.getUsers();
      return users.where((user) => user.isAdmin).toList();
    } catch (e) {
      Logger.error('Failed to get admin users: $e', tag: 'DailyReportService');
      return [];
    }
  }

  /// Generate email content for the report
  String _generateEmailContent(DailyAttendanceReport report) {
    final buffer = StringBuffer();
    buffer.writeln('Daily Attendance Report - ${_formatDate(report.date)}');
    buffer.writeln('=' * 50);
    buffer.writeln();
    buffer.writeln('SUMMARY:');
    buffer.writeln('- Total Active Employees: ${report.totalActiveEmployees}');
    buffer.writeln(
        '- Employees Who Checked In: ${report.uniqueEmployeesCheckedIn}');
    buffer.writeln('- Total Check-ins: ${report.totalCheckIns}');
    buffer.writeln(
        '- Attendance Rate: ${report.attendanceRate.toStringAsFixed(1)}%');
    buffer.writeln();

    if (report.employeeCheckIns.isNotEmpty) {
      buffer.writeln('EMPLOYEES WHO CHECKED IN:');
      report.employeeCheckIns.forEach((employeeId, checkIns) {
        final firstCheckIn = checkIns.first;
        buffer.writeln(
            '- ${firstCheckIn.employeeName}: ${checkIns.length} check-in(s)');
        for (final checkIn in checkIns) {
          buffer.writeln(
              '  • ${checkIn.siteName} at ${_formatTime(checkIn.checkInTime)}');
        }
      });
      buffer.writeln();
    }

    if (report.employeesWhoDidntCheckIn.isNotEmpty) {
      buffer.writeln('EMPLOYEES WHO DID NOT CHECK IN:');
      for (final employee in report.employeesWhoDidntCheckIn) {
        buffer.writeln('- ${employee.name} (${employee.email})');
      }
    }

    return buffer.toString();
  }

  /// Generate WhatsApp message for the report
  String _generateWhatsAppMessage(DailyAttendanceReport report) {
    return '🛡️ *GuardTrack Daily Report* - ${_formatDate(report.date)}\n\n'
        '📊 *Summary:*\n'
        '• Attendance Rate: ${report.attendanceRate.toStringAsFixed(1)}%\n'
        '• Checked In: ${report.uniqueEmployeesCheckedIn}/${report.totalActiveEmployees}\n'
        '• Total Check-ins: ${report.totalCheckIns}\n\n'
        '${report.employeesWhoDidntCheckIn.isNotEmpty ? "⚠️ ${report.employeesWhoDidntCheckIn.length} employee(s) did not check in" : "✅ All employees checked in"}';
  }

  /// Generate SMS message for the report
  String _generateSMSMessage(DailyAttendanceReport report) {
    return 'GuardTrack Report ${_formatDate(report.date)}: '
        '${report.uniqueEmployeesCheckedIn}/${report.totalActiveEmployees} checked in '
        '(${report.attendanceRate.toStringAsFixed(1)}%). '
        '${report.employeesWhoDidntCheckIn.length} absent.';
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format time for display
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Manually trigger daily report generation (for testing)
  Future<void> generateAndSendReport({DateTime? date}) async {
    final report = await generateDailyReport(date: date);
    await _sendReportToAdmins(report);
  }

  /// Send daily report via email on app startup
  Future<void> sendDailyReportOnStartup() async {
    try {
      Logger.info('Sending daily attendance report on app startup...',
          tag: 'DailyReportService');

      // Send report for today
      await _smtpEmailService.sendDailyAttendanceReport();

      Logger.info('Daily report sent successfully on app startup',
          tag: 'DailyReportService');
    } catch (e) {
      Logger.error('Failed to send daily report on startup: $e',
          tag: 'DailyReportService');
      // Don't throw the error to prevent app startup failure
    }
  }

  /// Dispose resources
  void dispose() {
    _dailyReportTimer?.cancel();
    _isInitialized = false;
  }
}

/// Model for daily attendance report
class DailyAttendanceReport {
  final DateTime date;
  final int totalActiveEmployees;
  final int totalCheckIns;
  final int uniqueEmployeesCheckedIn;
  final double attendanceRate;
  final Map<String, List<CheckInSummary>> employeeCheckIns;
  final Map<String, List<CheckInSummary>> siteCheckIns;
  final List<EmployeeSummary> employeesWhoDidntCheckIn;
  final DateTime generatedAt;

  const DailyAttendanceReport({
    required this.date,
    required this.totalActiveEmployees,
    required this.totalCheckIns,
    required this.uniqueEmployeesCheckedIn,
    required this.attendanceRate,
    required this.employeeCheckIns,
    required this.siteCheckIns,
    required this.employeesWhoDidntCheckIn,
    required this.generatedAt,
  });
}

/// Model for check-in summary
class CheckInSummary {
  final String employeeId;
  final String employeeName;
  final String siteId;
  final String siteName;
  final DateTime checkInTime;
  final String arrivalCode;
  final double latitude;
  final double longitude;

  const CheckInSummary({
    required this.employeeId,
    required this.employeeName,
    required this.siteId,
    required this.siteName,
    required this.checkInTime,
    required this.arrivalCode,
    required this.latitude,
    required this.longitude,
  });
}

/// Model for employee summary
class EmployeeSummary {
  final String id;
  final String name;
  final String email;
  final String? phone;

  const EmployeeSummary({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });
}
