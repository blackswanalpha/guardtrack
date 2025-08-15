import 'lib/shared/services/smtp_email_service.dart';
import 'lib/shared/services/email_test_service.dart';
import 'lib/core/config/email_config.dart';
import 'lib/core/utils/logger.dart';

/// Simple test script to verify email functionality
void main() async {
  print('🧪 Testing GuardTrack Email Service...\n');
  
  // Check configuration
  print('📧 Email Configuration:');
  print('- Sender: ${EmailConfig.senderEmail}');
  print('- Recipient: ${EmailConfig.recipientEmail}');
  print('- SMTP Host: ${EmailConfig.smtpHost}:${EmailConfig.smtpPort}');
  print('- Configured: ${EmailConfig.isConfigured() ? "✅ Yes" : "❌ No"}');
  
  if (!EmailConfig.isConfigured()) {
    print('\n❌ Email service is not configured!');
    print(EmailConfig.getConfigurationMessage());
    return;
  }
  
  print('\n🔧 Testing email service...');
  
  try {
    final emailTest = EmailTestService();
    
    // Test 1: Configuration check
    print('\n1️⃣ Testing configuration...');
    await emailTest.testEmailSetup();
    
    // Test 2: Simple email test
    print('\n2️⃣ Testing simple email...');
    await emailTest.testCustomEmail();
    
    // Test 3: Daily report test
    print('\n3️⃣ Testing daily report...');
    await emailTest.testDailyReport();
    
    print('\n✅ All tests completed! Check your email inbox.');
    
  } catch (e) {
    print('\n❌ Email test failed: $e');
    print('\n🔧 Troubleshooting tips:');
    print('1. Verify Gmail App Password is correct');
    print('2. Check internet connection');
    print('3. Ensure 2FA is enabled on Gmail');
    print('4. Try regenerating the App Password');
  }
}
