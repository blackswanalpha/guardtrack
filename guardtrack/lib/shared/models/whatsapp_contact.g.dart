// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whatsapp_contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WhatsAppContact _$WhatsAppContactFromJson(Map<String, dynamic> json) =>
    WhatsAppContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      company: json['company'] as String?,
      position: json['position'] as String?,
      groups: (json['groups'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      customFields: (json['customFields'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      lastMessageSent: json['lastMessageSent'] == null
          ? null
          : DateTime.parse(json['lastMessageSent'] as String),
    );

Map<String, dynamic> _$WhatsAppContactToJson(WhatsAppContact instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'company': instance.company,
      'position': instance.position,
      'groups': instance.groups,
      'customFields': instance.customFields,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'lastMessageSent': instance.lastMessageSent?.toIso8601String(),
    };

ContactGroup _$ContactGroupFromJson(Map<String, dynamic> json) => ContactGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      color: json['color'] as String,
      contactCount: (json['contactCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ContactGroupToJson(ContactGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'color': instance.color,
      'contactCount': instance.contactCount,
      'createdAt': instance.createdAt.toIso8601String(),
    };
