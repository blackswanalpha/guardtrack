// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageHistory _$MessageHistoryFromJson(Map<String, dynamic> json) =>
    MessageHistory(
      id: json['id'] as String,
      recipientName: json['recipientName'] as String,
      recipientPhone: json['recipientPhone'] as String,
      message: json['message'] as String,
      templateId: json['templateId'] as String?,
      templateName: json['templateName'] as String?,
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      status: $enumDecode(_$MessageStatusEnumMap, json['status']),
      sentAt: DateTime.parse(json['sentAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      errorMessage: json['errorMessage'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$MessageHistoryToJson(MessageHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipientName': instance.recipientName,
      'recipientPhone': instance.recipientPhone,
      'message': instance.message,
      'templateId': instance.templateId,
      'templateName': instance.templateName,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'status': _$MessageStatusEnumMap[instance.status]!,
      'sentAt': instance.sentAt.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
      'errorMessage': instance.errorMessage,
      'metadata': instance.metadata,
    };

const _$MessageTypeEnumMap = {
  MessageType.whatsapp: 'whatsapp',
  MessageType.email: 'email',
  MessageType.sms: 'sms',
};

const _$MessageStatusEnumMap = {
  MessageStatus.pending: 'pending',
  MessageStatus.sent: 'sent',
  MessageStatus.delivered: 'delivered',
  MessageStatus.read: 'read',
  MessageStatus.failed: 'failed',
};
