import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserRole { guard, admin, superAdmin }

@JsonSerializable()
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? phone;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? profileImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>? assignedSiteIds;

  const UserModel({
    required this.id,
    required this.email,
    this.phone,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.profileImageUrl,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.assignedSiteIds,
  });

  String get fullName => '$firstName $lastName';
  
  String get displayName => fullName.trim().isEmpty ? email : fullName;
  
  bool get isGuard => role == UserRole.guard;
  
  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;
  
  bool get isSuperAdmin => role == UserRole.superAdmin;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    UserRole? role,
    String? profileImageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? assignedSiteIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedSiteIds: assignedSiteIds ?? this.assignedSiteIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        firstName,
        lastName,
        role,
        profileImageUrl,
        isActive,
        createdAt,
        updatedAt,
        assignedSiteIds,
      ];
}
