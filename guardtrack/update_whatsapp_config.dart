// Quick configuration update script for WhatsApp Cloud API
// Run this script to update your Phone Number ID

import 'dart:io';

void main() {
  print('🚀 WhatsApp Cloud API Configuration Updater');
  print('============================================');
  print('');

  // Get Phone Number ID from user
  print('Please enter your Phone Number ID from Meta for Developers:');
  print('(You can find this in WhatsApp > Getting Started)');
  stdout.write('Phone Number ID: ');

  final phoneNumberId = stdin.readLineSync();

  if (phoneNumberId == null || phoneNumberId.trim().isEmpty) {
    print('❌ No Phone Number ID provided. Exiting...');
    return;
  }

  // Update the configuration file
  final filePath = 'lib/shared/services/whatsapp_cloud_api_service.dart';
  final file = File(filePath);

  if (!file.existsSync()) {
    print('❌ Configuration file not found: $filePath');
    return;
  }

  try {
    // Read the file
    String content = file.readAsStringSync();

    // Replace the placeholder
    content = content.replaceAll(
      "static const String _phoneNumberId = 'YOUR_PHONE_NUMBER_ID';",
      "static const String _phoneNumberId = '${phoneNumberId.trim()}';",
    );

    // Write back to file
    file.writeAsStringSync(content);

    print('✅ Configuration updated successfully!');
    print('');
    print('📱 Current Configuration:');
    print('   Sender (WhatsApp Business): +254792823173');
    print('   Receiver: +254792823173 (same number)');
    print('   Message: "hello mbugua from app"');
    print('   Phone Number ID: ${phoneNumberId.trim()}');
    print('');
    print('🔥 Next Steps:');
    print('1. Restart your Flutter app');
    print('2. Go to WhatsApp Bot > Settings');
    print('3. Check the configuration status (should show green checkmarks)');
    print('4. Use "Send Now" button to test the integration');
    print('');
    print(
        '📋 The app will now automatically send WhatsApp messages via the Cloud API!');
  } catch (e) {
    print('❌ Error updating configuration: $e');
  }
}
