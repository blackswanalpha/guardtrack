/// Email configuration for SMTP service
///
/// IMPORTANT SECURITY NOTE:
/// For production use, replace the hardcoded password with:
/// 1. Environment variables
/// 2. Secure storage (flutter_secure_storage)
/// 3. External configuration service
///
/// For Gmail, you should use an App Password instead of your regular password:
/// 1. Go to Google Account settings
/// 2. Enable 2-Factor Authentication
/// 3. Generate an App Password for "Mail"
/// 4. Use that App Password here instead of your regular password

class EmailConfig {
  // Gmail SMTP configuration
  static const String smtpHost = 'smtp.gmail.com';
  static const int smtpPort = 587;
  static const String senderEmail = 'kamandembugua18@gmail.com';
  static const String recipientEmail = 'kamandembugua18@gmail.com';

  // Gmail App Password for kamandembugua18@gmail.com
  // This is the actual App Password for SMTP authentication
  static const String senderPassword = 'lmqo ufte kfhr ebob';

  // Email settings
  static const String senderName = 'GuardTrack System';
  static const bool useSSL = false; // Using TLS on port 587
  static const bool ignoreBadCertificate = false;
  static const bool allowInsecure = false;

  /// Validate email configuration
  static bool isConfigured() {
    return senderPassword != 'your_gmail_app_password_here' &&
        senderPassword.isNotEmpty;
  }

  /// Get configuration status message
  static String getConfigurationMessage() {
    if (!isConfigured()) {
      return '''
Email service is not properly configured.

To set up Gmail SMTP:
1. Go to your Google Account settings
2. Enable 2-Factor Authentication
3. Go to Security > App passwords
4. Generate a new App Password for "Mail"
5. Replace 'your_gmail_app_password_here' in EmailConfig with your App Password

Current status: Email password not configured
''';
    }
    return 'Email service is properly configured';
  }
}
