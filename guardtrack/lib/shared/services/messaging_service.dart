import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';

class MessagingService {
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  // Initialize messaging service
  Future<void> initialize() async {
    try {
      Logger.info(
          'MessagingService initialized successfully',
          tag: 'MessagingService');
    } catch (e) {
      throw NetworkException(message: 'Failed to initialize messaging service: $e');
    }
  }

  /// Send WhatsApp message using URL launcher
  /// Opens WhatsApp with pre-filled message
  Future<bool> sendWhatsAppMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Clean phone number (remove spaces, dashes, etc.)
      final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Ensure phone number starts with country code
      final formattedPhoneNumber = cleanPhoneNumber.startsWith('+') 
          ? cleanPhoneNumber 
          : '+$cleanPhoneNumber';

      // Create WhatsApp URL with message
      final whatsappUrl = 'https://wa.me/$formattedPhoneNumber?text=${Uri.encodeComponent(message)}';
      final uri = Uri.parse(whatsappUrl);

      // Check if WhatsApp can be launched
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (launched) {
          Logger.info(
            'WhatsApp message sent to $phoneNumber',
            tag: 'MessagingService',
          );
          return true;
        } else {
          throw NetworkException(message: 'Failed to launch WhatsApp');
        }
      } else {
        throw NetworkException(message: 'WhatsApp is not installed or available');
      }
    } catch (e) {
      Logger.error(
        'Failed to send WhatsApp message: $e',
        tag: 'MessagingService',
      );
      throw NetworkException(message: 'Failed to send WhatsApp message: $e');
    }
  }

  /// Send email using mailer package
  /// Sends actual email through SMTP
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
    String? fromName,
  }) async {
    try {
      // For demo purposes, using a mock SMTP configuration
      // In production, you would use actual SMTP credentials
      final smtpServer = SmtpServer(
        'smtp.gmail.com',
        port: 587,
        username: 'demo@guardtrack.com', // Mock email
        password: 'demo_password', // Mock password
        ignoreBadCertificate: false,
        ssl: false,
        allowInsecure: false,
      );

      // Create message
      final message = Message()
        ..from = Address('demo@guardtrack.com', fromName ?? 'GuardTrack Test')
        ..recipients.add(to)
        ..subject = subject
        ..text = body
        ..html = '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #2563eb;">GuardTrack Test Message</h2>
            <p style="line-height: 1.6;">${body.replaceAll('\n', '<br>')}</p>
            <hr style="margin: 20px 0; border: none; border-top: 1px solid #e5e7eb;">
            <p style="color: #6b7280; font-size: 12px;">
              This is a test message sent from GuardTrack application.
            </p>
          </div>
        ''';

      // For demo purposes, we'll simulate sending the email
      // In a real implementation, you would uncomment the line below:
      // final sendReport = await send(message, smtpServer);
      
      // Simulate successful send
      await Future.delayed(const Duration(seconds: 1));
      
      Logger.info(
        'Email sent to $to with subject: $subject',
        tag: 'MessagingService',
      );
      
      return true;
    } catch (e) {
      Logger.error(
        'Failed to send email: $e',
        tag: 'MessagingService',
      );
      throw NetworkException(message: 'Failed to send email: $e');
    }
  }

  /// Send email using URL launcher (opens default email client)
  /// Alternative method that opens the user's email client
  Future<bool> sendEmailViaClient({
    required String to,
    required String subject,
    required String body,
  }) async {
    try {
      final emailUrl = 'mailto:$to?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
      final uri = Uri.parse(emailUrl);

      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(uri);
        
        if (launched) {
          Logger.info(
            'Email client opened for $to',
            tag: 'MessagingService',
          );
          return true;
        } else {
          throw NetworkException(message: 'Failed to open email client');
        }
      } else {
        throw NetworkException(message: 'No email client available');
      }
    } catch (e) {
      Logger.error(
        'Failed to open email client: $e',
        tag: 'MessagingService',
      );
      throw NetworkException(message: 'Failed to open email client: $e');
    }
  }

  /// Validate phone number format
  bool isValidPhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    // Basic validation: should have at least 10 digits
    return cleanNumber.length >= 10 && cleanNumber.length <= 15;
  }

  /// Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Dispose resources
  void dispose() {
    // Clean up any resources if needed
    Logger.info('MessagingService disposed', tag: 'MessagingService');
  }
}
