import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'whatsapp_contact.g.dart';

@JsonSerializable()
class WhatsAppContact extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? company;
  final String? position;
  final List<String> groups;
  final Map<String, String> customFields;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastMessageSent;

  const WhatsAppContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.company,
    this.position,
    this.groups = const [],
    this.customFields = const {},
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.lastMessageSent,
  });

  factory WhatsAppContact.fromJson(Map<String, dynamic> json) =>
      _$WhatsAppContactFromJson(json);

  Map<String, dynamic> toJson() => _$WhatsAppContactToJson(this);

  WhatsAppContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? company,
    String? position,
    List<String>? groups,
    Map<String, String>? customFields,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastMessageSent,
  }) {
    return WhatsAppContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      company: company ?? this.company,
      position: position ?? this.position,
      groups: groups ?? this.groups,
      customFields: customFields ?? this.customFields,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageSent: lastMessageSent ?? this.lastMessageSent,
    );
  }

  /// Get formatted phone number for WhatsApp
  String get formattedPhoneNumber {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    return cleanNumber.startsWith('+') ? cleanNumber : '+$cleanNumber';
  }

  /// Get display name with company if available
  String get displayName {
    if (company != null && company!.isNotEmpty) {
      return '$name ($company)';
    }
    return name;
  }

  /// Check if contact belongs to a specific group
  bool belongsToGroup(String groupName) {
    return groups.contains(groupName);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        email,
        company,
        position,
        groups,
        customFields,
        isActive,
        createdAt,
        updatedAt,
        lastMessageSent,
      ];
}

/// Contact group model
@JsonSerializable()
class ContactGroup extends Equatable {
  final String id;
  final String name;
  final String description;
  final String color;
  final int contactCount;
  final DateTime createdAt;

  const ContactGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    this.contactCount = 0,
    required this.createdAt,
  });

  factory ContactGroup.fromJson(Map<String, dynamic> json) =>
      _$ContactGroupFromJson(json);

  Map<String, dynamic> toJson() => _$ContactGroupToJson(this);

  ContactGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    int? contactCount,
    DateTime? createdAt,
  }) {
    return ContactGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      contactCount: contactCount ?? this.contactCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        color,
        contactCount,
        createdAt,
      ];
}
