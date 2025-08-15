import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_history.g.dart';

@JsonSerializable()
class MessageHistory extends Equatable {
  final String id;
  final String recipientName;
  final String recipientPhone;
  final String message;
  final String? templateId;
  final String? templateName;
  final MessageType type;
  final MessageStatus status;
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final String? errorMessage;
  final Map<String, String> metadata;

  const MessageHistory({
    required this.id,
    required this.recipientName,
    required this.recipientPhone,
    required this.message,
    this.templateId,
    this.templateName,
    required this.type,
    required this.status,
    required this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.errorMessage,
    this.metadata = const {},
  });

  factory MessageHistory.fromJson(Map<String, dynamic> json) =>
      _$MessageHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$MessageHistoryToJson(this);

  MessageHistory copyWith({
    String? id,
    String? recipientName,
    String? recipientPhone,
    String? message,
    String? templateId,
    String? templateName,
    MessageType? type,
    MessageStatus? status,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    String? errorMessage,
    Map<String, String>? metadata,
  }) {
    return MessageHistory(
      id: id ?? this.id,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      message: message ?? this.message,
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      type: type ?? this.type,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get formatted phone number
  String get formattedPhone {
    final cleanNumber = recipientPhone.replaceAll(RegExp(r'[^\d+]'), '');
    return cleanNumber.startsWith('+') ? cleanNumber : '+$cleanNumber';
  }

  /// Check if message was sent successfully
  bool get wasSuccessful => status == MessageStatus.sent || status == MessageStatus.delivered || status == MessageStatus.read;

  /// Get time since message was sent
  Duration get timeSinceSent => DateTime.now().difference(sentAt);

  @override
  List<Object?> get props => [
        id,
        recipientName,
        recipientPhone,
        message,
        templateId,
        templateName,
        type,
        status,
        sentAt,
        deliveredAt,
        readAt,
        errorMessage,
        metadata,
      ];
}

@JsonEnum()
enum MessageType {
  @JsonValue('whatsapp')
  whatsapp,
  @JsonValue('email')
  email,
  @JsonValue('sms')
  sms,
}

@JsonEnum()
enum MessageStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('sent')
  sent,
  @JsonValue('delivered')
  delivered,
  @JsonValue('read')
  read,
  @JsonValue('failed')
  failed,
}

extension MessageTypeExtension on MessageType {
  String get displayName {
    switch (this) {
      case MessageType.whatsapp:
        return 'WhatsApp';
      case MessageType.email:
        return 'Email';
      case MessageType.sms:
        return 'SMS';
    }
  }

  String get icon {
    switch (this) {
      case MessageType.whatsapp:
        return '💬';
      case MessageType.email:
        return '📧';
      case MessageType.sms:
        return '📱';
    }
  }
}

extension MessageStatusExtension on MessageStatus {
  String get displayName {
    switch (this) {
      case MessageStatus.pending:
        return 'Pending';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
      case MessageStatus.failed:
        return 'Failed';
    }
  }

  String get icon {
    switch (this) {
      case MessageStatus.pending:
        return '⏳';
      case MessageStatus.sent:
        return '✅';
      case MessageStatus.delivered:
        return '📨';
      case MessageStatus.read:
        return '👁️';
      case MessageStatus.failed:
        return '❌';
    }
  }
}
