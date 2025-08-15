// Test script to verify WhatsApp Cloud API integration
// Run this to test your WhatsApp API configuration

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 WhatsApp Cloud API Test');
  print('==========================');
  print('');
  
  // Configuration from your curl command
  const String baseUrl = 'https://graph.facebook.com/v22.0';
  const String phoneNumberId = '668434946363881';
  const String accessToken = 'EAAOedUFFQu4BPD5Y5fuJSBhXLcXnVc8eFG0s4OlH2Rc6CUqEw3uEPptOBH85tcDWcFjPvaXZAZBDaHE55JZCJ5ZBnqwNBcZAq5AqpJtpmVg5GeRuXqQGVYftKfKeFx8FV2XrGN0Ir1rXuSt0MxUbgR9bHjRMEk9FwDoPTuiOMBKQW7w7HLIdkhuTjKK7EtgcC7ZAKFPo1UFpZB4JgkJpReVUYfVbRvF1tTkqFVlN0RtSzgbvQZDZD';
  const String toNumber = '254792823173';
  
  print('📋 Configuration:');
  print('   API Version: v22.0');
  print('   Phone Number ID: $phoneNumberId');
  print('   To Number: +$toNumber');
  print('   Access Token: ${accessToken.substring(0, 20)}...');
  print('');
  
  // Test 1: Send hello_world template
  print('🧪 Test 1: Sending hello_world template...');
  final templateSuccess = await sendTemplateMessage(
    baseUrl: baseUrl,
    phoneNumberId: phoneNumberId,
    accessToken: accessToken,
    to: toNumber,
    templateName: 'hello_world',
    languageCode: 'en_US',
  );
  
  if (templateSuccess) {
    print('✅ Template message sent successfully!');
  } else {
    print('❌ Template message failed');
    
    // Test 2: Send text message as fallback
    print('');
    print('🧪 Test 2: Sending text message as fallback...');
    final textSuccess = await sendTextMessage(
      baseUrl: baseUrl,
      phoneNumberId: phoneNumberId,
      accessToken: accessToken,
      to: toNumber,
      message: 'hello mbugua from app',
    );
    
    if (textSuccess) {
      print('✅ Text message sent successfully!');
    } else {
      print('❌ Text message also failed');
    }
  }
  
  print('');
  print('🎯 Summary:');
  print('   - Check your WhatsApp (+254792823173) for the message');
  print('   - If no message received, check WhatsApp Business Manager settings');
  print('   - Ensure your phone number is verified and approved');
  print('');
}

Future<bool> sendTemplateMessage({
  required String baseUrl,
  required String phoneNumberId,
  required String accessToken,
  required String to,
  required String templateName,
  required String languageCode,
}) async {
  try {
    final url = Uri.parse('$baseUrl/$phoneNumberId/messages');
    
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    
    final body = jsonEncode({
      'messaging_product': 'whatsapp',
      'to': to,
      'type': 'template',
      'template': {
        'name': templateName,
        'language': {
          'code': languageCode,
        },
      },
    });
    
    print('   📤 Sending template request...');
    final response = await http.post(url, headers: headers, body: body);
    
    print('   📊 Response Status: ${response.statusCode}');
    print('   📄 Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['messages'] != null) {
        final messageId = responseData['messages'][0]['id'];
        print('   📨 Message ID: $messageId');
        return true;
      }
    }
    
    return false;
  } catch (e) {
    print('   ❌ Error: $e');
    return false;
  }
}

Future<bool> sendTextMessage({
  required String baseUrl,
  required String phoneNumberId,
  required String accessToken,
  required String to,
  required String message,
}) async {
  try {
    final url = Uri.parse('$baseUrl/$phoneNumberId/messages');
    
    final headers = {
      'Authorization': 'Bearer $accessToken',
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
    
    print('   📤 Sending text request...');
    final response = await http.post(url, headers: headers, body: body);
    
    print('   📊 Response Status: ${response.statusCode}');
    print('   📄 Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['messages'] != null) {
        final messageId = responseData['messages'][0]['id'];
        print('   📨 Message ID: $messageId');
        return true;
      }
    }
    
    return false;
  } catch (e) {
    print('   ❌ Error: $e');
    return false;
  }
}
