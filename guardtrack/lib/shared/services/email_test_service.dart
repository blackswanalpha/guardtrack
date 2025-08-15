import '../../core/utils/logger.dart';
import '../../core/config/email_config.dart';
import 'smtp_email_service.dart';
import 'daily_report_service.dart';

/// Service for testing email functionality
/// This service provides methods to test the email configuration and sending
class EmailTestService {
  static final EmailTestService _instance = EmailTestService._internal();
  factory EmailTestService() => _instance;
  EmailTestService._internal();

  final SMTPEmailService _smtpEmailService = SMTPEmailService();
  final DailyReportService _dailyReportService = DailyReportService();

  /// Test email configuration and connectivity
  Future<void> testEmailSetup() async {
    try {
      Logger.info('Starting email setup test...', tag: 'EmailTestService');
      
      // Check configuration
      Logger.info('Email Configuration Status:', tag: 'EmailTestService');
      Logger.info(EmailConfig.getConfigurationMessage(), tag: 'EmailTestService');
      
      if (!EmailConfig.isConfigured()) {
        Logger.warning('Email is not configured. Please set up Gmail App Password.', tag: 'EmailTestService');
        return;
      }
      
      // Test connectivity
      Logger.info('Testing email connectivity...', tag: 'EmailTestService');
      final connectionTest = await _smtpEmailService.testEmailConnection();
      
      if (connectionTest) {
        Logger.info('✅ Email connectivity test passed!', tag: 'EmailTestService');
      } else {
        Logger.error('❌ Email connectivity test failed!', tag: 'EmailTestService');
      }
      
    } catch (e) {
      Logger.error('Email setup test failed: $e', tag: 'EmailTestService');
    }
  }

  /// Test sending a daily attendance report
  Future<void> testDailyReport() async {
    try {
      Logger.info('Testing daily attendance report...', tag: 'EmailTestService');
      
      if (!EmailConfig.isConfigured()) {
        Logger.warning('Email is not configured. Cannot send daily report.', tag: 'EmailTestService');
        return;
      }
      
      // Send daily report for today
      await _smtpEmailService.sendDailyAttendanceReport();
      
      Logger.info('✅ Daily attendance report sent successfully!', tag: 'EmailTestService');
      
    } catch (e) {
      Logger.error('❌ Daily report test failed: $e', tag: 'EmailTestService');
    }
  }

  /// Test sending a custom email
  Future<void> testCustomEmail() async {
    try {
      Logger.info('Testing custom email...', tag: 'EmailTestService');
      
      if (!EmailConfig.isConfigured()) {
        Logger.warning('Email is not configured. Cannot send custom email.', tag: 'EmailTestService');
        return;
      }
      
      final customSubject = 'GuardTrack Custom Email Test';
      final customBody = '''
      <h2>🛡️ GuardTrack Custom Email Test</h2>
      <p>This is a test of the custom email functionality.</p>
      <p><strong>Features tested:</strong></p>
      <ul>
        <li>HTML email formatting</li>
        <li>Custom subject and body</li>
        <li>SMTP configuration</li>
      </ul>
      <p>If you receive this email, the custom email feature is working correctly!</p>
      ''';
      
      await _smtpEmailService.sendCustomEmail(
        subject: customSubject,
        body: customBody,
      );
      
      Logger.info('✅ Custom email sent successfully!', tag: 'EmailTestService');
      
    } catch (e) {
      Logger.error('❌ Custom email test failed: $e', tag: 'EmailTestService');
    }
  }

  /// Run all email tests
  Future<void> runAllTests() async {
    Logger.info('🧪 Running all email tests...', tag: 'EmailTestService');
    
    await testEmailSetup();
    await Future.delayed(const Duration(seconds: 2));
    
    await testCustomEmail();
    await Future.delayed(const Duration(seconds: 2));
    
    await testDailyReport();
    
    Logger.info('🏁 All email tests completed!', tag: 'EmailTestService');
  }

  /// Print setup instructions
  void printSetupInstructions() {
    Logger.info('''
📧 EMAIL SETUP INSTRUCTIONS:

To enable email functionality in GuardTrack:

1. 🔐 Enable 2-Factor Authentication on your Gmail account
   - Go to Google Account settings
   - Security > 2-Step Verification
   - Follow the setup process

2. 🔑 Generate an App Password
   - Go to Google Account settings
   - Security > App passwords
   - Select "Mail" as the app
   - Copy the generated 16-character password

3. ⚙️ Configure GuardTrack
   - Open: lib/core/config/email_config.dart
   - Replace 'your_gmail_app_password_here' with your App Password
   - Save the file

4. ✅ Test the configuration
   - Run the app and check the logs
   - Or call EmailTestService().runAllTests()

Current Configuration:
- Sender Email: ${EmailConfig.senderEmail}
- Recipient Email: ${EmailConfig.recipientEmail}
- SMTP Host: ${EmailConfig.smtpHost}:${EmailConfig.smtpPort}
- Status: ${EmailConfig.isConfigured() ? '✅ Configured' : '❌ Not Configured'}

⚠️  SECURITY NOTE:
Never commit your actual App Password to version control!
Consider using environment variables or secure storage in production.
    ''', tag: 'EmailTestService');
  }
}
