// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SiteModel _$SiteModelFromJson(Map<String, dynamic> json) => SiteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      allowedRadius: (json['allowedRadius'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      description: json['description'] as String?,
      contactPerson: json['contactPerson'] as String?,
      contactPhone: json['contactPhone'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      assignedGuardIds: (json['assignedGuardIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      emergencyContact: json['emergencyContact'] as String?,
      shiftStartTime: json['shiftStartTime'] as String?,
      shiftEndTime: json['shiftEndTime'] as String?,
      specialInstructions: json['specialInstructions'] as String?,
    );

Map<String, dynamic> _$SiteModelToJson(SiteModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'allowedRadius': instance.allowedRadius,
      'isActive': instance.isActive,
      'description': instance.description,
      'contactPerson': instance.contactPerson,
      'contactPhone': instance.contactPhone,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'assignedGuardIds': instance.assignedGuardIds,
      'emergencyContact': instance.emergencyContact,
      'shiftStartTime': instance.shiftStartTime,
      'shiftEndTime': instance.shiftEndTime,
      'specialInstructions': instance.specialInstructions,
    };
