import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/message_template.dart';
import '../models/whatsapp_contact.dart';
import '../models/message_history.dart';
import '../../core/utils/logger.dart';
import 'messaging_service.dart';

class WhatsAppBotService {
  static const String _templatesKey = 'whatsapp_templates';
  static const String _contactsKey = 'whatsapp_contacts';
  static const String _historyKey = 'whatsapp_history';
  static const String _groupsKey = 'whatsapp_groups';

  final MessagingService _messagingService;
  final Uuid _uuid = const Uuid();

  WhatsAppBotService({MessagingService? messagingService})
      : _messagingService = messagingService ?? MessagingService();

  // Template Management
  Future<List<MessageTemplate>> getTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getStringList(_templatesKey) ?? [];
      
      if (templatesJson.isEmpty) {
        // Return default templates if none exist
        return _getDefaultTemplates();
      }
      
      return templatesJson
          .map((json) => MessageTemplate.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      Logger.error('Error loading templates: $e', tag: 'WhatsAppBotService');
      return _getDefaultTemplates();
    }
  }

  Future<bool> saveTemplate(MessageTemplate template) async {
    try {
      final templates = await getTemplates();
      final existingIndex = templates.indexWhere((t) => t.id == template.id);
      
      if (existingIndex >= 0) {
        templates[existingIndex] = template.copyWith(updatedAt: DateTime.now());
      } else {
        templates.add(template);
      }
      
      return await _saveTemplates(templates);
    } catch (e) {
      Logger.error('Error saving template: $e', tag: 'WhatsAppBotService');
      return false;
    }
  }

  Future<bool> deleteTemplate(String templateId) async {
    try {
      final templates = await getTemplates();
      templates.removeWhere((t) => t.id == templateId);
      return await _saveTemplates(templates);
    } catch (e) {
      Logger.error('Error deleting template: $e', tag: 'WhatsAppBotService');
      return false;
    }
  }

  // Contact Management
  Future<List<WhatsAppContact>> getContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getStringList(_contactsKey) ?? [];
      
      return contactsJson
          .map((json) => WhatsAppContact.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      Logger.error('Error loading contacts: $e', tag: 'WhatsAppBotService');
      return [];
    }
  }

  Future<bool> saveContact(WhatsAppContact contact) async {
    try {
      final contacts = await getContacts();
      final existingIndex = contacts.indexWhere((c) => c.id == contact.id);
      
      if (existingIndex >= 0) {
        contacts[existingIndex] = contact.copyWith(updatedAt: DateTime.now());
      } else {
        contacts.add(contact);
      }
      
      return await _saveContacts(contacts);
    } catch (e) {
      Logger.error('Error saving contact: $e', tag: 'WhatsAppBotService');
      return false;
    }
  }

  Future<bool> deleteContact(String contactId) async {
    try {
      final contacts = await getContacts();
      contacts.removeWhere((c) => c.id == contactId);
      return await _saveContacts(contacts);
    } catch (e) {
      Logger.error('Error deleting contact: $e', tag: 'WhatsAppBotService');
      return false;
    }
  }

  // Message History
  Future<List<MessageHistory>> getMessageHistory({int? limit}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];
      
      final history = historyJson
          .map((json) => MessageHistory.fromJson(jsonDecode(json)))
          .toList();
      
      // Sort by sent date (newest first)
      history.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      
      if (limit != null && history.length > limit) {
        return history.take(limit).toList();
      }
      
      return history;
    } catch (e) {
      Logger.error('Error loading message history: $e', tag: 'WhatsAppBotService');
      return [];
    }
  }

  Future<bool> addToHistory(MessageHistory message) async {
    try {
      final history = await getMessageHistory();
      history.insert(0, message); // Add to beginning
      
      // Keep only last 1000 messages
      if (history.length > 1000) {
        history.removeRange(1000, history.length);
      }
      
      return await _saveHistory(history);
    } catch (e) {
      Logger.error('Error adding to history: $e', tag: 'WhatsAppBotService');
      return false;
    }
  }

  // Enhanced Message Sending
  Future<bool> sendWhatsAppMessage({
    required String phoneNumber,
    required String message,
    String? recipientName,
    String? templateId,
    String? templateName,
  }) async {
    try {
      // Create history entry
      final historyEntry = MessageHistory(
        id: _uuid.v4(),
        recipientName: recipientName ?? 'Unknown',
        recipientPhone: phoneNumber,
        message: message,
        templateId: templateId,
        templateName: templateName,
        type: MessageType.whatsapp,
        status: MessageStatus.pending,
        sentAt: DateTime.now(),
      );

      // Add to history
      await addToHistory(historyEntry);

      // Send message using existing service
      final success = await _messagingService.sendWhatsAppMessage(
        phoneNumber: phoneNumber,
        message: message,
      );

      // Update history with result
      final updatedEntry = historyEntry.copyWith(
        status: success ? MessageStatus.sent : MessageStatus.failed,
        errorMessage: success ? null : 'Failed to open WhatsApp',
      );
      
      await _updateHistoryEntry(updatedEntry);

      // Update contact's last message sent time
      await _updateContactLastMessage(phoneNumber);

      return success;
    } catch (e) {
      Logger.error('Error sending WhatsApp message: $e', tag: 'WhatsAppBotService');
      return false;
    }
  }

  // Bulk messaging
  Future<Map<String, bool>> sendBulkMessages({
    required List<WhatsAppContact> contacts,
    required String message,
    String? templateId,
    String? templateName,
  }) async {
    final results = <String, bool>{};
    
    for (final contact in contacts) {
      final success = await sendWhatsAppMessage(
        phoneNumber: contact.phoneNumber,
        message: message,
        recipientName: contact.name,
        templateId: templateId,
        templateName: templateName,
      );
      
      results[contact.id] = success;
      
      // Add small delay between messages to avoid overwhelming the system
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    return results;
  }

  // Private helper methods
  Future<bool> _saveTemplates(List<MessageTemplate> templates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = templates
          .map((template) => jsonEncode(template.toJson()))
          .toList();
      return await prefs.setStringList(_templatesKey, templatesJson);
    } catch (e) {
      Logger.error('Error saving templates: $e', tag: 'WhatsAppBotService');
      return false;
    }
  }

  Future<bool> _saveContacts(List<WhatsAppContact> contacts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = contacts
          .map((contact) => jsonEncode(contact.toJson()))
          .toList();
      return await prefs.setStringList(_contactsKey, contactsJson);
    } catch (e) {
      Logger.error('Error saving contacts: $e', tag: 'WhatsAppBotService');
      return false;
    }
  }

  Future<bool> _saveHistory(List<MessageHistory> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = history
          .map((message) => jsonEncode(message.toJson()))
          .toList();
      return await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      Logger.error('Error saving history: $e', tag: 'WhatsAppBotService');
      return false;
    }
  }

  Future<void> _updateHistoryEntry(MessageHistory entry) async {
    final history = await getMessageHistory();
    final index = history.indexWhere((h) => h.id == entry.id);
    if (index >= 0) {
      history[index] = entry;
      await _saveHistory(history);
    }
  }

  Future<void> _updateContactLastMessage(String phoneNumber) async {
    final contacts = await getContacts();
    final index = contacts.indexWhere((c) => c.phoneNumber == phoneNumber);
    if (index >= 0) {
      contacts[index] = contacts[index].copyWith(
        lastMessageSent: DateTime.now(),
      );
      await _saveContacts(contacts);
    }
  }

  List<MessageTemplate> _getDefaultTemplates() {
    final now = DateTime.now();
    return [
      MessageTemplate(
        id: _uuid.v4(),
        name: 'Welcome Message',
        content: 'Hello {name}! Welcome to GuardTrack. Your security is our priority.',
        category: TemplateCategory.greeting,
        variables: ['name'],
        createdAt: now,
      ),
      MessageTemplate(
        id: _uuid.v4(),
        name: 'Shift Reminder',
        content: 'Hi {name}, this is a reminder that your shift starts at {time} today. Please arrive 15 minutes early.',
        category: TemplateCategory.reminder,
        variables: ['name', 'time'],
        createdAt: now,
      ),
      MessageTemplate(
        id: _uuid.v4(),
        name: 'Emergency Alert',
        content: 'EMERGENCY ALERT: {message}. Please respond immediately. Location: {location}',
        category: TemplateCategory.emergency,
        variables: ['message', 'location'],
        createdAt: now,
      ),
    ];
  }
}
