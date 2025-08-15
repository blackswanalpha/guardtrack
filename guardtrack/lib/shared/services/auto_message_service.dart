import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/logger.dart';
import 'whatsapp_bot_service.dart';
import 'whatsapp_cloud_api_service.dart';

class AutoMessageService {
  static const String _lastSentKey = 'auto_message_last_sent';
  static const String _enabledKey = 'auto_message_enabled';

  // Configuration - Using +254792823173 as both sender and receiver
  static const String defaultPhoneNumber = '+254792823173'; // Receiver
  static const String defaultSenderNumber =
      '+254792823173'; // Sender (WhatsApp Business number)
  static const String defaultMessage = 'hello mbugua from app';
  static const String defaultRecipientName = 'Mbugua';

  // Template configuration (fallback to hello_world template if text fails)
  static const String defaultTemplateName = 'hello_world';
  static const String defaultTemplateLanguage = 'en_US';

  final WhatsAppBotService _botService;
  final WhatsAppCloudApiService _cloudApiService;

  AutoMessageService({
    WhatsAppBotService? botService,
    WhatsAppCloudApiService? cloudApiService,
  })  : _botService = botService ?? WhatsAppBotService(),
        _cloudApiService = cloudApiService ?? WhatsAppCloudApiService();

  /// Send automatic startup message if conditions are met
  Future<bool> sendStartupMessage() async {
    try {
      // Check if auto-message is enabled
      if (!await isAutoMessageEnabled()) {
        Logger.info('Auto-message is disabled', tag: 'AutoMessageService');
        return false;
      }

      // Check if we should send the message (not sent today)
      if (!await shouldSendMessage()) {
        Logger.info('Auto-message already sent today',
            tag: 'AutoMessageService');
        return false;
      }

      Logger.info(
          'Sending automatic startup message from $defaultSenderNumber to $defaultPhoneNumber...',
          tag: 'AutoMessageService');

      // Try to send via WhatsApp Cloud API first, fallback to bot service
      bool success = false;

      if (_cloudApiService.isConfigured()) {
        Logger.info('Using WhatsApp Cloud API for automatic message',
            tag: 'AutoMessageService');
        final formattedPhone =
            _cloudApiService.formatPhoneNumber(defaultPhoneNumber);

        // Try template message first (more reliable for new WhatsApp Business accounts)
        success = await _cloudApiService.sendTemplateMessage(
          to: formattedPhone,
          templateName: defaultTemplateName,
          languageCode: defaultTemplateLanguage,
        );

        // If template fails, try text message
        if (!success) {
          Logger.info('Template message failed, trying text message',
              tag: 'AutoMessageService');
          success = await _cloudApiService.sendTextMessage(
            to: formattedPhone,
            message: defaultMessage,
          );
        }
      } else {
        Logger.info('WhatsApp Cloud API not configured, using fallback method',
            tag: 'AutoMessageService');
        success = await _botService.sendWhatsAppMessage(
          phoneNumber: defaultPhoneNumber,
          message: defaultMessage,
          recipientName: defaultRecipientName,
        );
      }

      if (success) {
        // Update last sent timestamp
        await _updateLastSentTimestamp();
        Logger.info(
          'Automatic startup message sent successfully from $defaultSenderNumber to $defaultPhoneNumber',
          tag: 'AutoMessageService',
        );
      } else {
        Logger.error(
          'Failed to send automatic startup message',
          tag: 'AutoMessageService',
        );
      }

      return success;
    } catch (e) {
      Logger.error(
        'Error sending automatic startup message: $e',
        tag: 'AutoMessageService',
      );
      return false;
    }
  }

  /// Check if auto-message feature is enabled
  Future<bool> isAutoMessageEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_enabledKey) ?? true; // Default to enabled
    } catch (e) {
      Logger.error('Error checking auto-message enabled status: $e',
          tag: 'AutoMessageService');
      return true; // Default to enabled on error
    }
  }

  /// Enable or disable auto-message feature
  Future<bool> setAutoMessageEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setBool(_enabledKey, enabled);

      Logger.info(
        'Auto-message ${enabled ? 'enabled' : 'disabled'}',
        tag: 'AutoMessageService',
      );

      return success;
    } catch (e) {
      Logger.error('Error setting auto-message enabled status: $e',
          tag: 'AutoMessageService');
      return false;
    }
  }

  /// Check if we should send the message (not sent today)
  Future<bool> shouldSendMessage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSentTimestamp = prefs.getInt(_lastSentKey);

      if (lastSentTimestamp == null) {
        return true; // Never sent before
      }

      final lastSentDate =
          DateTime.fromMillisecondsSinceEpoch(lastSentTimestamp);
      final today = DateTime.now();

      // Check if last sent was on a different day
      return lastSentDate.day != today.day ||
          lastSentDate.month != today.month ||
          lastSentDate.year != today.year;
    } catch (e) {
      Logger.error('Error checking if should send message: $e',
          tag: 'AutoMessageService');
      return true; // Default to sending on error
    }
  }

  /// Update the last sent timestamp to now
  Future<bool> _updateLastSentTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setInt(
          _lastSentKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      Logger.error('Error updating last sent timestamp: $e',
          tag: 'AutoMessageService');
      return false;
    }
  }

  /// Get the last sent date (for display purposes)
  Future<DateTime?> getLastSentDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSentTimestamp = prefs.getInt(_lastSentKey);

      if (lastSentTimestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(lastSentTimestamp);
      }

      return null;
    } catch (e) {
      Logger.error('Error getting last sent date: $e',
          tag: 'AutoMessageService');
      return null;
    }
  }

  /// Send the startup message immediately (for testing or manual trigger)
  Future<bool> sendMessageNow() async {
    try {
      Logger.info(
          'Sending immediate startup message from $defaultSenderNumber to $defaultPhoneNumber...',
          tag: 'AutoMessageService');

      // Try to send via WhatsApp Cloud API first, fallback to bot service
      bool success = false;

      if (_cloudApiService.isConfigured()) {
        Logger.info('Using WhatsApp Cloud API for immediate message',
            tag: 'AutoMessageService');
        final formattedPhone =
            _cloudApiService.formatPhoneNumber(defaultPhoneNumber);

        // Try template message first (more reliable for new WhatsApp Business accounts)
        success = await _cloudApiService.sendTemplateMessage(
          to: formattedPhone,
          templateName: defaultTemplateName,
          languageCode: defaultTemplateLanguage,
        );

        // If template fails, try text message
        if (!success) {
          Logger.info('Template message failed, trying text message',
              tag: 'AutoMessageService');
          success = await _cloudApiService.sendTextMessage(
            to: formattedPhone,
            message: defaultMessage,
          );
        }
      } else {
        Logger.info('WhatsApp Cloud API not configured, using fallback method',
            tag: 'AutoMessageService');
        success = await _botService.sendWhatsAppMessage(
          phoneNumber: defaultPhoneNumber,
          message: defaultMessage,
          recipientName: defaultRecipientName,
        );
      }

      if (success) {
        await _updateLastSentTimestamp();
        Logger.info(
          'Immediate startup message sent successfully from $defaultSenderNumber to $defaultPhoneNumber',
          tag: 'AutoMessageService',
        );
      } else {
        Logger.error(
          'Failed to send immediate startup message',
          tag: 'AutoMessageService',
        );
      }

      return success;
    } catch (e) {
      Logger.error(
        'Error sending immediate startup message: $e',
        tag: 'AutoMessageService',
      );
      return false;
    }
  }

  /// Reset the auto-message system (clear last sent date)
  Future<bool> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastSentKey);

      Logger.info('Auto-message system reset', tag: 'AutoMessageService');
      return true;
    } catch (e) {
      Logger.error('Error resetting auto-message system: $e',
          tag: 'AutoMessageService');
      return false;
    }
  }

  /// Get auto-message configuration info
  Map<String, dynamic> getConfiguration() {
    return {
      'phoneNumber': defaultPhoneNumber,
      'message': defaultMessage,
      'recipientName': defaultRecipientName,
    };
  }
}
