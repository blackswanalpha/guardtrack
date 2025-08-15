import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_template.g.dart';

@JsonSerializable()
class MessageTemplate extends Equatable {
  final String id;
  final String name;
  final String content;
  final String category;
  final List<String> variables;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MessageTemplate({
    required this.id,
    required this.name,
    required this.content,
    required this.category,
    required this.variables,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory MessageTemplate.fromJson(Map<String, dynamic> json) =>
      _$MessageTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$MessageTemplateToJson(this);

  MessageTemplate copyWith({
    String? id,
    String? name,
    String? content,
    String? category,
    List<String>? variables,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      content: content ?? this.content,
      category: category ?? this.category,
      variables: variables ?? this.variables,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Replace variables in the template content with actual values
  String generateMessage(Map<String, String> variableValues) {
    String message = content;
    for (String variable in variables) {
      final value = variableValues[variable] ?? '{$variable}';
      message = message.replaceAll('{$variable}', value);
    }
    return message;
  }

  /// Extract variables from template content
  static List<String> extractVariables(String content) {
    final RegExp variableRegex = RegExp(r'\{([^}]+)\}');
    final matches = variableRegex.allMatches(content);
    return matches.map((match) => match.group(1)!).toList();
  }

  @override
  List<Object?> get props => [
        id,
        name,
        content,
        category,
        variables,
        isActive,
        createdAt,
        updatedAt,
      ];
}

/// Predefined template categories
class TemplateCategory {
  static const String greeting = 'greeting';
  static const String notification = 'notification';
  static const String reminder = 'reminder';
  static const String emergency = 'emergency';
  static const String report = 'report';
  static const String custom = 'custom';

  static const List<String> all = [
    greeting,
    notification,
    reminder,
    emergency,
    report,
    custom,
  ];

  static String getDisplayName(String category) {
    switch (category) {
      case greeting:
        return 'Greeting';
      case notification:
        return 'Notification';
      case reminder:
        return 'Reminder';
      case emergency:
        return 'Emergency';
      case report:
        return 'Report';
      case custom:
        return 'Custom';
      default:
        return 'Unknown';
    }
  }
}
