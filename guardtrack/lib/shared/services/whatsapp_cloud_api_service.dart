import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/utils/logger.dart';

class WhatsAppCloudApiService {
  // WhatsApp Cloud API Configuration
  static const String _baseUrl = 'https://graph.facebook.com/v22.0';
  static const String _accessToken =
      'EAAOedUFFQu4BPD5Y5fuJSBhXLcXnVc8eFG0s4OlH2Rc6CUqEw3uEPptOBH85tcDWcFjPvaXZAZBDaHE55JZCJ5ZBnqwNBcZAq5AqpJtpmVg5GeRuXqQGVYftKfKeFx8FV2XrGN0Ir1rXuSt0MxUbgR9bHjRMEk9FwDoPTuiOMBKQW7w7HLIdkhuTjKK7EtgcC7ZAKFPo1UFpZB4JgkJpReVUYfVbRvF1tTkqFVlN0RtSzgbvQZDZD';

  // Phone Number ID for +254792823173 (both sender and receiver)
  static const String _phoneNumberId = '668434946363881';

  /// Send a text message via WhatsApp Cloud API
  Future<bool> sendTextMessage({
    required String to,
    required String message,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/$_phoneNumberId/messages');

      final headers = {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        'messaging_product': 'whatsapp',
        'to': to,
        'type': 'text',
        'text': {
          'body': message,
        },
      });

      Logger.info(
        'Sending WhatsApp message to $to: $message',
        tag: 'WhatsAppCloudApiService',
      );

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Logger.info(
          'WhatsApp message sent successfully: ${responseData.toString()}',
          tag: 'WhatsAppCloudApiService',
        );
        return true;
      } else {
        Logger.error(
          'Failed to send WhatsApp message. Status: ${response.statusCode}, Body: ${response.body}',
          tag: 'WhatsAppCloudApiService',
        );
        return false;
      }
    } catch (e) {
      Logger.error(
        'Error sending WhatsApp message: $e',
        tag: 'WhatsAppCloudApiService',
      );
      return false;
    }
  }

  /// Send a template message via WhatsApp Cloud API
  Future<bool> sendTemplateMessage({
    required String to,
    required String templateName,
    required String languageCode,
    List<String>? parameters,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/$_phoneNumberId/messages');

      final headers = {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };

      // Build template components
      final templateComponents = <Map<String, dynamic>>[];

      if (parameters != null && parameters.isNotEmpty) {
        final bodyParameters = parameters
            .map((param) => {
                  'type': 'text',
                  'text': param,
                })
            .toList();

        templateComponents.add({
          'type': 'body',
          'parameters': bodyParameters,
        });
      }

      final body = jsonEncode({
        'messaging_product': 'whatsapp',
        'to': to,
        'type': 'template',
        'template': {
          'name': templateName,
          'language': {
            'code': languageCode,
          },
          if (templateComponents.isNotEmpty) 'components': templateComponents,
        },
      });

      Logger.info(
        'Sending WhatsApp template message to $to: $templateName',
        tag: 'WhatsAppCloudApiService',
      );

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Logger.info(
          'WhatsApp template message sent successfully: ${responseData.toString()}',
          tag: 'WhatsAppCloudApiService',
        );
        return true;
      } else {
        Logger.error(
          'Failed to send WhatsApp template message. Status: ${response.statusCode}, Body: ${response.body}',
          tag: 'WhatsAppCloudApiService',
        );
        return false;
      }
    } catch (e) {
      Logger.error(
        'Error sending WhatsApp template message: $e',
        tag: 'WhatsAppCloudApiService',
      );
      return false;
    }
  }

  /// Get WhatsApp Business Account information
  Future<Map<String, dynamic>?> getBusinessAccountInfo() async {
    try {
      final url = Uri.parse('$_baseUrl/$_phoneNumberId');

      final headers = {
        'Authorization': 'Bearer $_accessToken',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Logger.info(
          'WhatsApp Business Account info retrieved: ${responseData.toString()}',
          tag: 'WhatsAppCloudApiService',
        );
        return responseData;
      } else {
        Logger.error(
          'Failed to get WhatsApp Business Account info. Status: ${response.statusCode}, Body: ${response.body}',
          tag: 'WhatsAppCloudApiService',
        );
        return null;
      }
    } catch (e) {
      Logger.error(
        'Error getting WhatsApp Business Account info: $e',
        tag: 'WhatsAppCloudApiService',
      );
      return null;
    }
  }

  /// Validate phone number format for WhatsApp
  String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // If it starts with +, remove it for the API (API expects just digits)
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }

    // Ensure it starts with country code (254 for Kenya)
    if (!cleaned.startsWith('254') && cleaned.length == 9) {
      cleaned = '254$cleaned';
    }

    return cleaned;
  }

  /// Check if the service is properly configured
  bool isConfigured() {
    return _phoneNumberId != 'YOUR_PHONE_NUMBER_ID' && _accessToken.isNotEmpty;
  }

  /// Get configuration status for debugging
  Map<String, dynamic> getConfigurationStatus() {
    return {
      'baseUrl': _baseUrl,
      'hasAccessToken': _accessToken.isNotEmpty,
      'phoneNumberId': _phoneNumberId,
      'isConfigured': isConfigured(),
    };
  }
}
