# 📧 GuardTrack Email Setup Guide

This guide will help you set up the SMTP email service for GuardTrack to send daily attendance reports automatically.

## 🎯 Overview

GuardTrack includes an automated email service that:
- 📊 Generates daily attendance reports as PDF attachments
- 📧 Sends reports via Gmail SMTP when the app loads
- 🔄 Provides both scheduled and on-demand report generation
- 🛡️ Uses secure Gmail App Passwords for authentication

## 🚀 Quick Setup

### Step 1: Enable Gmail 2-Factor Authentication

1. Go to your [Google Account settings](https://myaccount.google.com/)
2. Navigate to **Security** → **2-Step Verification**
3. Follow the setup process to enable 2FA
4. ✅ Verify that 2-Step Verification is enabled

### Step 2: Generate Gmail App Password

1. Go to [Google Account settings](https://myaccount.google.com/)
2. Navigate to **Security** → **App passwords**
3. Select **Mail** as the app type
4. Click **Generate**
5. 📋 Copy the 16-character password (e.g., `abcd efgh ijkl mnop`)

### Step 3: Configure GuardTrack

1. Open `guardtrack/lib/core/config/email_config.dart`
2. Replace `'your_gmail_app_password_here'` with your App Password:

```dart
static const String senderPassword = 'abcd efgh ijkl mnop'; // Your actual App Password
```

3. 💾 Save the file

### Step 4: Test the Configuration

Run the app and check the logs for email status, or use the test service:

```dart
import 'package:guardtrack/shared/services/email_test_service.dart';

// Test all email functionality
final emailTest = EmailTestService();
await emailTest.runAllTests();
```

## 📋 Features

### Daily Attendance Reports

- **📅 Automatic Generation**: Reports are generated for the current day
- **📊 Comprehensive Data**: Includes employee check-ins, site attendance, and absent employees
- **📎 PDF Attachment**: Professional PDF report attached to email
- **🕐 App Startup Trigger**: Email sent automatically when app loads

### Email Content

The daily report email includes:
- 📈 **Attendance Summary**: Total employees, check-ins, attendance rate
- 👥 **Employee Details**: List of all check-ins with times and locations
- 🏢 **Site Breakdown**: Attendance summary by site
- ⚠️ **Absent Employees**: List of employees who didn't check in
- 🎨 **Professional Formatting**: HTML email with GuardTrack branding

### PDF Report Structure

- **Header**: GuardTrack logo and report date
- **Summary Cards**: Key statistics in visual format
- **Employee Table**: Detailed check-in information
- **Site Summary**: Attendance by location
- **Absent List**: Missing employees highlighted
- **Footer**: Generation timestamp and branding

## 🔧 Configuration Options

### Email Settings

Edit `lib/core/config/email_config.dart` to customize:

```dart
class EmailConfig {
  static const String smtpHost = 'smtp.gmail.com';
  static const int smtpPort = 587;
  static const String senderEmail = 'your-email@gmail.com';
  static const String recipientEmail = 'recipient@gmail.com';
  static const String senderPassword = 'your_app_password';
  static const String senderName = 'GuardTrack System';
}
```

### Trigger Options

The email service can be triggered:

1. **App Startup** (default): Automatically when app loads
2. **Manual**: Call `sendDailyReportOnStartup()` method
3. **Scheduled**: Using the existing daily report timer
4. **On-Demand**: Generate reports for specific dates

## 🧪 Testing

### Test Email Configuration

```dart
final emailTest = EmailTestService();

// Check configuration status
await emailTest.testEmailSetup();

// Send test email
await emailTest.testCustomEmail();

// Send sample daily report
await emailTest.testDailyReport();

// Run all tests
await emailTest.runAllTests();
```

### Print Setup Instructions

```dart
final emailTest = EmailTestService();
emailTest.printSetupInstructions();
```

## 🔒 Security Best Practices

### ✅ Do's
- ✅ Use Gmail App Passwords (never regular passwords)
- ✅ Enable 2-Factor Authentication
- ✅ Keep App Passwords secure and private
- ✅ Use environment variables in production
- ✅ Regularly rotate App Passwords

### ❌ Don'ts
- ❌ Never commit App Passwords to version control
- ❌ Don't share App Passwords
- ❌ Don't use regular Gmail passwords
- ❌ Don't disable 2FA after setup

### Production Security

For production deployments, consider:

```dart
// Use environment variables
static String get senderPassword => 
    Platform.environment['GMAIL_APP_PASSWORD'] ?? '';

// Or use secure storage
final secureStorage = FlutterSecureStorage();
static Future<String> getSenderPassword() async {
  return await secureStorage.read(key: 'gmail_app_password') ?? '';
}
```

## 🐛 Troubleshooting

### Common Issues

**❌ "Email service not configured"**
- Check that App Password is set in `email_config.dart`
- Verify the password is exactly 16 characters
- Ensure no extra spaces in the password

**❌ "Authentication failed"**
- Verify 2FA is enabled on Gmail
- Regenerate App Password if needed
- Check that you're using App Password, not regular password

**❌ "Connection timeout"**
- Check internet connectivity
- Verify SMTP settings (host: smtp.gmail.com, port: 587)
- Ensure firewall allows SMTP connections

**❌ "PDF generation failed"**
- Check that attendance data exists
- Verify database connectivity
- Ensure sufficient storage space

### Debug Logs

Enable detailed logging to troubleshoot:

```dart
Logger.info('Email config status: ${EmailConfig.isConfigured()}');
Logger.info('Configuration: ${EmailConfig.getConfigurationMessage()}');
```

## 📱 Integration

### App Startup Integration

The email service is automatically integrated in `main.dart`:

```dart
Future<void> _initializeServices() async {
  // ... other services
  
  final dailyReportService = DailyReportService();
  await dailyReportService.initialize();
  
  // Send daily attendance report via email on app startup
  await dailyReportService.sendDailyReportOnStartup();
}
```

### Manual Triggering

```dart
final smtpService = SMTPEmailService();

// Send today's report
await smtpService.sendDailyAttendanceReport();

// Send report for specific date
await smtpService.sendDailyAttendanceReport(
  date: DateTime(2024, 1, 15)
);
```

## 📞 Support

If you encounter issues:

1. 📋 Check the troubleshooting section above
2. 🔍 Review the debug logs
3. 🧪 Run the email test service
4. 📧 Verify Gmail App Password setup
5. 🔄 Try regenerating the App Password

---

**🛡️ GuardTrack Email Service** - Secure, automated attendance reporting via email.
