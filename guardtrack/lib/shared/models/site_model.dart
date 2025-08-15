import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'site_model.g.dart';

@JsonSerializable()
class SiteModel extends Equatable {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double allowedRadius; // in meters
  final bool isActive;
  final String? description;
  final String? contactPerson;
  final String? contactPhone;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>? assignedGuardIds;

  // Additional properties for comprehensive site management
  final String? emergencyContact;
  final String? shiftStartTime;
  final String? shiftEndTime;
  final String? specialInstructions;

  // Convenience getter for geofenceRadius (alias for allowedRadius)
  double get geofenceRadius => allowedRadius;

  const SiteModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.allowedRadius,
    required this.isActive,
    this.description,
    this.contactPerson,
    this.contactPhone,
    required this.createdAt,
    this.updatedAt,
    this.assignedGuardIds,
    this.emergencyContact,
    this.shiftStartTime,
    this.shiftEndTime,
    this.specialInstructions,
  });

  factory SiteModel.fromJson(Map<String, dynamic> json) =>
      _$SiteModelFromJson(json);

  Map<String, dynamic> toJson() => _$SiteModelToJson(this);

  SiteModel copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    double? allowedRadius,
    bool? isActive,
    String? description,
    String? contactPerson,
    String? contactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? assignedGuardIds,
  }) {
    return SiteModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      allowedRadius: allowedRadius ?? this.allowedRadius,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedGuardIds: assignedGuardIds ?? this.assignedGuardIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        latitude,
        longitude,
        allowedRadius,
        isActive,
        description,
        contactPerson,
        contactPhone,
        createdAt,
        updatedAt,
        assignedGuardIds,
      ];
}
