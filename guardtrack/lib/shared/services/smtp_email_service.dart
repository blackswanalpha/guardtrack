import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:intl/intl.dart';
import '../../core/utils/logger.dart';
import '../../core/errors/exceptions.dart';
import '../../core/config/email_config.dart';
import 'pdf_report_service.dart';

class SMTPEmailService {
  static final SMTPEmailService _instance = SMTPEmailService._internal();
  factory SMTPEmailService() => _instance;
  SMTPEmailService._internal();

  final PDFReportService _pdfReportService = PDFReportService();

  /// Send daily attendance report via email with PDF attachment
  Future<bool> sendDailyAttendanceReport({DateTime? date}) async {
    try {
      // Check if email is configured
      if (!EmailConfig.isConfigured()) {
        final configMessage = EmailConfig.getConfigurationMessage();
        Logger.warning('Email service not configured: $configMessage',
            tag: 'SMTPEmailService');
        print('❌ EMAIL NOT CONFIGURED: $configMessage');
        throw NetworkException(
            message:
                'Email service not configured. Please set up Gmail App Password.');
      }

      final reportDate = date ?? DateTime.now();
      Logger.info(
          'Sending daily attendance report for ${_formatDate(reportDate)}',
          tag: 'SMTPEmailService');

      // Generate PDF report
      final pdfFile =
          await _pdfReportService.generateDailyAttendancePDF(date: reportDate);

      // Create SMTP server configuration
      final smtpServer = SmtpServer(
        EmailConfig.smtpHost,
        port: EmailConfig.smtpPort,
        username: EmailConfig.senderEmail,
        password: EmailConfig.senderPassword,
        ignoreBadCertificate: EmailConfig.ignoreBadCertificate,
        ssl: EmailConfig.useSSL,
        allowInsecure: EmailConfig.allowInsecure,
      );

      // Create email message
      final message = Message()
        ..from = Address(EmailConfig.senderEmail, EmailConfig.senderName)
        ..recipients.add(EmailConfig.recipientEmail)
        ..subject =
            'GuardTrack Daily Attendance Report - ${_formatDate(reportDate)}'
        ..html = _generateEmailBody(reportDate)
        ..attachments = [
          FileAttachment(pdfFile)
            ..location = Location.attachment
            ..cid = 'attendance_report_${_formatDateForFile(reportDate)}.pdf'
        ];

      // Send email
      final sendReport = await send(message, smtpServer);

      // Clean up temporary PDF file
      try {
        await pdfFile.delete();
      } catch (e) {
        Logger.warning('Failed to delete temporary PDF file: $e',
            tag: 'SMTPEmailService');
      }

      Logger.info('Email sent successfully: ${sendReport.toString()}',
          tag: 'SMTPEmailService');
      return true;
    } catch (e) {
      Logger.error('Failed to send daily attendance report: $e',
          tag: 'SMTPEmailService');
      throw NetworkException(message: 'Failed to send email: $e');
    }
  }

  /// Send custom email with optional PDF attachment
  Future<bool> sendCustomEmail({
    required String subject,
    required String body,
    String? recipientEmail,
    File? pdfAttachment,
  }) async {
    try {
      // Check if email is configured
      if (!EmailConfig.isConfigured()) {
        Logger.warning('Email service not configured', tag: 'SMTPEmailService');
        throw NetworkException(
            message:
                'Email service not configured. Please set up Gmail App Password.');
      }

      final recipient = recipientEmail ?? EmailConfig.recipientEmail;
      Logger.info('Sending custom email to $recipient',
          tag: 'SMTPEmailService');

      // Create SMTP server configuration
      final smtpServer = SmtpServer(
        EmailConfig.smtpHost,
        port: EmailConfig.smtpPort,
        username: EmailConfig.senderEmail,
        password: EmailConfig.senderPassword,
        ignoreBadCertificate: EmailConfig.ignoreBadCertificate,
        ssl: EmailConfig.useSSL,
        allowInsecure: EmailConfig.allowInsecure,
      );

      // Create email message
      final message = Message()
        ..from = Address(EmailConfig.senderEmail, EmailConfig.senderName)
        ..recipients.add(recipient)
        ..subject = subject
        ..html = body;

      // Add PDF attachment if provided
      if (pdfAttachment != null) {
        message.attachments = [
          FileAttachment(pdfAttachment)..location = Location.attachment
        ];
      }

      // Send email
      final sendReport = await send(message, smtpServer);

      Logger.info('Custom email sent successfully: ${sendReport.toString()}',
          tag: 'SMTPEmailService');
      return true;
    } catch (e) {
      Logger.error('Failed to send custom email: $e', tag: 'SMTPEmailService');
      throw NetworkException(message: 'Failed to send email: $e');
    }
  }

  /// Generate HTML email body for daily attendance report
  String _generateEmailBody(DateTime reportDate) {
    final dateStr = _formatDate(reportDate);

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>GuardTrack Daily Attendance Report</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                line-height: 1.6;
                color: #333;
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
            }
            .header {
                background: linear-gradient(135deg, #1e3a8a, #3b82f6);
                color: white;
                padding: 30px;
                text-align: center;
                border-radius: 10px 10px 0 0;
            }
            .header h1 {
                margin: 0;
                font-size: 28px;
                font-weight: bold;
            }
            .header p {
                margin: 5px 0 0 0;
                font-size: 14px;
                opacity: 0.9;
            }
            .content {
                background: #f8fafc;
                padding: 30px;
                border-radius: 0 0 10px 10px;
                border: 1px solid #e2e8f0;
            }
            .date-badge {
                background: #3b82f6;
                color: white;
                padding: 8px 16px;
                border-radius: 20px;
                display: inline-block;
                font-weight: bold;
                margin-bottom: 20px;
            }
            .message {
                font-size: 16px;
                margin-bottom: 20px;
            }
            .attachment-info {
                background: #e0f2fe;
                border: 1px solid #0284c7;
                border-radius: 8px;
                padding: 15px;
                margin: 20px 0;
            }
            .attachment-info h3 {
                margin: 0 0 10px 0;
                color: #0284c7;
                font-size: 16px;
            }
            .footer {
                text-align: center;
                margin-top: 30px;
                padding-top: 20px;
                border-top: 1px solid #e2e8f0;
                color: #64748b;
                font-size: 14px;
            }
            .footer strong {
                color: #1e3a8a;
            }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>🛡️ GuardTrack</h1>
            <p>Secure Arrival. Verified Presence.</p>
        </div>
        
        <div class="content">
            <div class="date-badge">📅 $dateStr</div>
            
            <div class="message">
                <p>Dear Administrator,</p>
                
                <p>Please find attached the daily attendance report for <strong>$dateStr</strong>. This comprehensive report includes:</p>
                
                <ul>
                    <li>📊 <strong>Attendance Summary</strong> - Overall statistics and attendance rates</li>
                    <li>👥 <strong>Employee Check-ins</strong> - Detailed list of all employee check-ins with times and locations</li>
                    <li>🏢 <strong>Site Attendance</strong> - Breakdown of attendance by site location</li>
                    <li>⚠️ <strong>Absent Employees</strong> - List of employees who did not check in</li>
                </ul>
            </div>
            
            <div class="attachment-info">
                <h3>📎 PDF Report Attached</h3>
                <p>The detailed attendance report is attached as a PDF file. This report contains all the information needed for attendance tracking and payroll processing.</p>
            </div>
            
            <p>If you have any questions about this report or need additional information, please don't hesitate to contact the system administrator.</p>
            
            <p>Best regards,<br>
            <strong>GuardTrack Automated System</strong></p>
        </div>
        
        <div class="footer">
            <p>This email was automatically generated by <strong>GuardTrack</strong> on ${_formatDateTime(DateTime.now())}</p>
            <p>© ${DateTime.now().year} GuardTrack System. All rights reserved.</p>
        </div>
    </body>
    </html>
    ''';
  }

  /// Test email connectivity
  Future<bool> testEmailConnection() async {
    try {
      // Check if email is configured
      if (!EmailConfig.isConfigured()) {
        Logger.warning('Email service not configured for testing',
            tag: 'SMTPEmailService');
        return false;
      }

      Logger.info('Testing email connection...', tag: 'SMTPEmailService');

      final smtpServer = SmtpServer(
        EmailConfig.smtpHost,
        port: EmailConfig.smtpPort,
        username: EmailConfig.senderEmail,
        password: EmailConfig.senderPassword,
        ignoreBadCertificate: EmailConfig.ignoreBadCertificate,
        ssl: EmailConfig.useSSL,
        allowInsecure: EmailConfig.allowInsecure,
      );

      final message = Message()
        ..from = Address(EmailConfig.senderEmail, EmailConfig.senderName)
        ..recipients.add(EmailConfig.recipientEmail)
        ..subject = 'GuardTrack Email Test - ${_formatDateTime(DateTime.now())}'
        ..html = '''
        <h2>🛡️ GuardTrack Email Test</h2>
        <p>This is a test email to verify that the GuardTrack email system is working correctly.</p>
        <p><strong>Test Time:</strong> ${_formatDateTime(DateTime.now())}</p>
        <p>If you receive this email, the SMTP configuration is working properly.</p>
        ''';

      await send(message, smtpServer);

      Logger.info('Email connection test successful', tag: 'SMTPEmailService');
      return true;
    } catch (e) {
      Logger.error('Email connection test failed: $e', tag: 'SMTPEmailService');
      return false;
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  /// Format date for filename
  String _formatDateForFile(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format date and time for display
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }
}
