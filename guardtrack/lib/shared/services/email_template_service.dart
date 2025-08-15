import 'dart:io';
import 'package:intl/intl.dart';
import '../../core/utils/logger.dart';
import '../../core/errors/exceptions.dart';

import 'smtp_email_service.dart';
import 'pdf_report_service.dart';

/// Email template types
enum EmailTemplateType {
  dailyAttendanceReport,
  weeklyAttendanceReport,
  monthlyAttendanceReport,
  customReport,
  attendanceAlert,
  systemNotification,
}

/// Email template data model
class EmailTemplateData {
  final String subject;
  final String htmlBody;
  final List<File>? attachments;
  final String? recipientEmail;

  EmailTemplateData({
    required this.subject,
    required this.htmlBody,
    this.attachments,
    this.recipientEmail,
  });
}

/// Professional email template service for GuardTrack
class EmailTemplateService {
  static final EmailTemplateService _instance =
      EmailTemplateService._internal();
  factory EmailTemplateService() => _instance;
  EmailTemplateService._internal();

  final SMTPEmailService _smtpService = SMTPEmailService();
  final PDFReportService _pdfService = PDFReportService();

  /// Send daily attendance report with professional template
  Future<bool> sendDailyAttendanceReport({
    DateTime? date,
    String? recipientEmail,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final reportDate = date ?? DateTime.now();
      Logger.info(
          'Generating daily attendance email template for ${_formatDate(reportDate)}',
          tag: 'EmailTemplateService');

      // Generate PDF report
      final pdfFile =
          await _pdfService.generateDailyAttendancePDF(date: reportDate);

      // Create email template data
      final templateData = await _generateDailyAttendanceTemplate(
        reportDate: reportDate,
        pdfFile: pdfFile,
        recipientEmail: recipientEmail,
        additionalData: additionalData,
      );

      // Send email using SMTP service
      final success = await _smtpService.sendCustomEmail(
        subject: templateData.subject,
        body: templateData.htmlBody,
        recipientEmail: templateData.recipientEmail,
        pdfAttachment: pdfFile,
      );

      // Clean up temporary files
      try {
        await pdfFile.delete();
      } catch (e) {
        Logger.warning('Failed to delete temporary PDF file: $e',
            tag: 'EmailTemplateService');
      }

      return success;
    } catch (e) {
      Logger.error('Failed to send daily attendance report: $e',
          tag: 'EmailTemplateService');
      throw NetworkException(
          message: 'Failed to send daily attendance report: $e');
    }
  }

  /// Send weekly attendance summary
  Future<bool> sendWeeklyAttendanceSummary({
    DateTime? weekStartDate,
    String? recipientEmail,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final startDate = weekStartDate ?? _getWeekStart(DateTime.now());
      final endDate = startDate.add(const Duration(days: 6));

      Logger.info(
          'Generating weekly attendance summary for ${_formatDate(startDate)} - ${_formatDate(endDate)}',
          tag: 'EmailTemplateService');

      // Create email template data
      final templateData = await _generateWeeklyAttendanceTemplate(
        startDate: startDate,
        endDate: endDate,
        recipientEmail: recipientEmail,
        additionalData: additionalData,
      );

      // Send email using SMTP service
      return await _smtpService.sendCustomEmail(
        subject: templateData.subject,
        body: templateData.htmlBody,
        recipientEmail: templateData.recipientEmail,
      );
    } catch (e) {
      Logger.error('Failed to send weekly attendance summary: $e',
          tag: 'EmailTemplateService');
      throw NetworkException(
          message: 'Failed to send weekly attendance summary: $e');
    }
  }

  /// Send custom report with flexible template
  Future<bool> sendCustomReport({
    required String reportTitle,
    required String reportDescription,
    File? pdfAttachment,
    String? recipientEmail,
    Map<String, dynamic>? customData,
  }) async {
    try {
      Logger.info('Generating custom report email: $reportTitle',
          tag: 'EmailTemplateService');

      // Create email template data
      final templateData = _generateCustomReportTemplate(
        reportTitle: reportTitle,
        reportDescription: reportDescription,
        pdfAttachment: pdfAttachment,
        recipientEmail: recipientEmail,
        customData: customData,
      );

      // Send email using SMTP service
      return await _smtpService.sendCustomEmail(
        subject: templateData.subject,
        body: templateData.htmlBody,
        recipientEmail: templateData.recipientEmail,
        pdfAttachment: pdfAttachment,
      );
    } catch (e) {
      Logger.error('Failed to send custom report: $e',
          tag: 'EmailTemplateService');
      throw NetworkException(message: 'Failed to send custom report: $e');
    }
  }

  /// Send attendance alert notification
  Future<bool> sendAttendanceAlert({
    required String alertType,
    required String alertMessage,
    String? recipientEmail,
    Map<String, dynamic>? alertData,
  }) async {
    try {
      Logger.info('Sending attendance alert: $alertType',
          tag: 'EmailTemplateService');

      // Create email template data
      final templateData = _generateAttendanceAlertTemplate(
        alertType: alertType,
        alertMessage: alertMessage,
        recipientEmail: recipientEmail,
        alertData: alertData,
      );

      // Send email using SMTP service
      return await _smtpService.sendCustomEmail(
        subject: templateData.subject,
        body: templateData.htmlBody,
        recipientEmail: templateData.recipientEmail,
      );
    } catch (e) {
      Logger.error('Failed to send attendance alert: $e',
          tag: 'EmailTemplateService');
      throw NetworkException(message: 'Failed to send attendance alert: $e');
    }
  }

  /// Generate daily attendance email template
  Future<EmailTemplateData> _generateDailyAttendanceTemplate({
    required DateTime reportDate,
    required File pdfFile,
    String? recipientEmail,
    Map<String, dynamic>? additionalData,
  }) async {
    final dateStr = _formatDate(reportDate);
    final subject = 'GuardTrack Daily Attendance Report - $dateStr';

    final htmlBody = _buildProfessionalEmailTemplate(
      title: 'Daily Attendance Report',
      subtitle: 'Comprehensive attendance tracking for $dateStr',
      mainContent: _buildDailyReportContent(reportDate, additionalData),
      attachmentInfo:
          'The detailed attendance report is attached as a PDF file containing all check-ins, site assignments, and attendance statistics.',
      footerNote:
          'This automated report helps ensure accurate attendance tracking and payroll processing.',
    );

    return EmailTemplateData(
      subject: subject,
      htmlBody: htmlBody,
      attachments: [pdfFile],
      recipientEmail: recipientEmail,
    );
  }

  /// Generate weekly attendance email template
  Future<EmailTemplateData> _generateWeeklyAttendanceTemplate({
    required DateTime startDate,
    required DateTime endDate,
    String? recipientEmail,
    Map<String, dynamic>? additionalData,
  }) async {
    final dateRange = '${_formatDate(startDate)} - ${_formatDate(endDate)}';
    final subject = 'GuardTrack Weekly Attendance Summary - $dateRange';

    final htmlBody = _buildProfessionalEmailTemplate(
      title: 'Weekly Attendance Summary',
      subtitle: 'Attendance overview for $dateRange',
      mainContent:
          _buildWeeklyReportContent(startDate, endDate, additionalData),
      attachmentInfo: null,
      footerNote:
          'This weekly summary provides insights into attendance patterns and trends.',
    );

    return EmailTemplateData(
      subject: subject,
      htmlBody: htmlBody,
      recipientEmail: recipientEmail,
    );
  }

  /// Generate custom report email template
  EmailTemplateData _generateCustomReportTemplate({
    required String reportTitle,
    required String reportDescription,
    File? pdfAttachment,
    String? recipientEmail,
    Map<String, dynamic>? customData,
  }) {
    final subject = 'GuardTrack Report - $reportTitle';

    final htmlBody = _buildProfessionalEmailTemplate(
      title: reportTitle,
      subtitle: reportDescription,
      mainContent:
          _buildCustomReportContent(reportTitle, reportDescription, customData),
      attachmentInfo: pdfAttachment != null
          ? 'The detailed report is attached as a PDF file for your review and records.'
          : null,
      footerNote:
          'This custom report was generated based on your specific requirements.',
    );

    return EmailTemplateData(
      subject: subject,
      htmlBody: htmlBody,
      attachments: pdfAttachment != null ? [pdfAttachment] : null,
      recipientEmail: recipientEmail,
    );
  }

  /// Generate attendance alert email template
  EmailTemplateData _generateAttendanceAlertTemplate({
    required String alertType,
    required String alertMessage,
    String? recipientEmail,
    Map<String, dynamic>? alertData,
  }) {
    final subject = 'GuardTrack Alert - $alertType';

    final htmlBody = _buildProfessionalEmailTemplate(
      title: '⚠️ Attendance Alert',
      subtitle: alertType,
      mainContent: _buildAlertContent(alertType, alertMessage, alertData),
      attachmentInfo: null,
      footerNote:
          'This alert was automatically generated to notify you of important attendance events.',
      isAlert: true,
    );

    return EmailTemplateData(
      subject: subject,
      htmlBody: htmlBody,
      recipientEmail: recipientEmail,
    );
  }

  /// Build professional email template structure
  String _buildProfessionalEmailTemplate({
    required String title,
    required String subtitle,
    required String mainContent,
    String? attachmentInfo,
    String? footerNote,
    bool isAlert = false,
  }) {
    final headerColor = isAlert ? '#dc2626' : '#1e3a8a';
    final headerGradient = isAlert
        ? 'linear-gradient(135deg, #dc2626, #ef4444)'
        : 'linear-gradient(135deg, #1e3a8a, #3b82f6)';

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>$title - GuardTrack</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                line-height: 1.6;
                color: #333;
                max-width: 650px;
                margin: 0 auto;
                padding: 20px;
                background-color: #f8fafc;
            }
            .email-container {
                background: white;
                border-radius: 12px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                overflow: hidden;
            }
            .header {
                background: $headerGradient;
                color: white;
                padding: 40px 30px;
                text-align: center;
            }
            .header h1 {
                margin: 0 0 10px 0;
                font-size: 32px;
                font-weight: bold;
            }
            .header p {
                margin: 0;
                font-size: 16px;
                opacity: 0.9;
            }
            .content {
                padding: 40px 30px;
            }
            .date-badge {
                background: #3b82f6;
                color: white;
                padding: 10px 20px;
                border-radius: 25px;
                display: inline-block;
                font-weight: bold;
                margin-bottom: 25px;
                font-size: 14px;
            }
            .alert-badge {
                background: #dc2626;
                color: white;
                padding: 10px 20px;
                border-radius: 25px;
                display: inline-block;
                font-weight: bold;
                margin-bottom: 25px;
                font-size: 14px;
            }
            .message {
                font-size: 16px;
                margin-bottom: 25px;
                line-height: 1.7;
            }
            .attachment-info {
                background: #e0f2fe;
                border: 1px solid #0284c7;
                border-radius: 10px;
                padding: 20px;
                margin: 25px 0;
            }
            .attachment-info h3 {
                margin: 0 0 10px 0;
                color: #0284c7;
                font-size: 18px;
            }
            .alert-info {
                background: #fef2f2;
                border: 1px solid #dc2626;
                border-radius: 10px;
                padding: 20px;
                margin: 25px 0;
            }
            .alert-info h3 {
                margin: 0 0 10px 0;
                color: #dc2626;
                font-size: 18px;
            }
            .footer {
                background: #f8fafc;
                text-align: center;
                padding: 30px;
                border-top: 1px solid #e2e8f0;
                color: #64748b;
                font-size: 14px;
            }
            .footer strong {
                color: $headerColor;
            }
            ul {
                padding-left: 20px;
            }
            li {
                margin-bottom: 8px;
            }
            .highlight {
                background: #fef3c7;
                padding: 2px 6px;
                border-radius: 4px;
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <div class="email-container">
            <div class="header">
                <h1>🛡️ GuardTrack</h1>
                <p>$subtitle</p>
            </div>
            
            <div class="content">
                ${isAlert ? '<div class="alert-badge">🚨 ALERT</div>' : '<div class="date-badge">📅 ${_formatDate(DateTime.now())}</div>'}
                
                <div class="message">
                    $mainContent
                </div>
                
                ${attachmentInfo != null ? '''
                <div class="attachment-info">
                    <h3>📎 PDF Report Attached</h3>
                    <p>$attachmentInfo</p>
                </div>
                ''' : ''}
                
                <p>If you have any questions or need additional information, please contact the system administrator.</p>
                
                <p>Best regards,<br>
                <strong>GuardTrack Automated System</strong></p>
            </div>
            
            <div class="footer">
                <p>$footerNote</p>
                <p>This email was automatically generated by <strong>GuardTrack</strong> on ${_formatDateTime(DateTime.now())}</p>
                <p>© ${DateTime.now().year} GuardTrack System. All rights reserved.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Build daily report content
  String _buildDailyReportContent(
      DateTime reportDate, Map<String, dynamic>? additionalData) {
    final dateStr = _formatDate(reportDate);

    return '''
    <p>Dear Administrator,</p>
    
    <p>Please find attached the comprehensive daily attendance report for <span class="highlight">$dateStr</span>. This detailed report includes:</p>
    
    <ul>
        <li>📊 <strong>Attendance Summary</strong> - Overall statistics, attendance rates, and key metrics</li>
        <li>👥 <strong>Employee Check-ins</strong> - Complete list of all employee check-ins with precise times and GPS locations</li>
        <li>🏢 <strong>Site Attendance</strong> - Detailed breakdown of attendance by site location and shift assignments</li>
        <li>⚠️ <strong>Absent Employees</strong> - List of employees who did not check in with their assigned sites</li>
        <li>📍 <strong>Location Verification</strong> - GPS coordinates and geofencing validation for all check-ins</li>
        <li>⏰ <strong>Time Analysis</strong> - Early arrivals, late check-ins, and shift duration analysis</li>
    </ul>
    
    ${additionalData != null && additionalData.containsKey('totalEmployees') ? '<p><strong>Quick Stats:</strong> ${additionalData['totalEmployees']} total employees, ${additionalData['checkedIn'] ?? 'N/A'} checked in today.</p>' : ''}
    ''';
  }

  /// Build weekly report content
  String _buildWeeklyReportContent(DateTime startDate, DateTime endDate,
      Map<String, dynamic>? additionalData) {
    final dateRange = '${_formatDate(startDate)} - ${_formatDate(endDate)}';

    return '''
    <p>Dear Administrator,</p>
    
    <p>Here's your weekly attendance summary for <span class="highlight">$dateRange</span>:</p>
    
    <ul>
        <li>📈 <strong>Weekly Trends</strong> - Attendance patterns and daily comparisons</li>
        <li>🎯 <strong>Performance Metrics</strong> - Average attendance rates and punctuality statistics</li>
        <li>📊 <strong>Site Performance</strong> - Attendance breakdown by location and shift coverage</li>
        <li>⚡ <strong>Key Insights</strong> - Notable patterns, improvements, and areas of concern</li>
        <li>📋 <strong>Action Items</strong> - Recommended follow-ups based on attendance data</li>
    </ul>
    
    ${additionalData != null && additionalData.containsKey('weeklyAverage') ? '<p><strong>Weekly Average:</strong> ${additionalData['weeklyAverage']}% attendance rate across all sites.</p>' : ''}
    ''';
  }

  /// Build custom report content
  String _buildCustomReportContent(String reportTitle, String reportDescription,
      Map<String, dynamic>? customData) {
    return '''
    <p>Dear Administrator,</p>
    
    <p>$reportDescription</p>
    
    <p>This custom report has been generated according to your specifications and includes the most relevant data for your analysis.</p>
    
    ${customData != null ? '''
    <p><strong>Report Parameters:</strong></p>
    <ul>
        ${customData.entries.map((entry) => '<li><strong>${entry.key}:</strong> ${entry.value}</li>').join('\n        ')}
    </ul>
    ''' : ''}
    ''';
  }

  /// Build alert content
  String _buildAlertContent(
      String alertType, String alertMessage, Map<String, dynamic>? alertData) {
    return '''
    <div class="alert-info">
        <h3>⚠️ $alertType</h3>
        <p>$alertMessage</p>
    </div>
    
    <p>This alert requires your immediate attention. Please review the details and take appropriate action if necessary.</p>
    
    ${alertData != null ? '''
    <p><strong>Alert Details:</strong></p>
    <ul>
        ${alertData.entries.map((entry) => '<li><strong>${entry.key}:</strong> ${entry.value}</li>').join('\n        ')}
    </ul>
    ''' : ''}
    
    <p><strong>Timestamp:</strong> ${_formatDateTime(DateTime.now())}</p>
    ''';
  }

  /// Get start of week (Monday)
  DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  /// Format date and time for display
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }
}
