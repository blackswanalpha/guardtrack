// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    AttendanceModel(
      id: json['id'] as String,
      guardId: json['guardId'] as String,
      siteId: json['siteId'] as String,
      type: $enumDecode(_$AttendanceTypeEnumMap, json['type']),
      status: $enumDecode(_$AttendanceStatusEnumMap, json['status']),
      arrivalCode: json['arrivalCode'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      photoUrl: json['photoUrl'] as String?,
      notes: json['notes'] as String?,
      adminNotes: json['adminNotes'] as String?,
      verifiedBy: json['verifiedBy'] as String?,
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.parse(json['verifiedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AttendanceModelToJson(AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guardId': instance.guardId,
      'siteId': instance.siteId,
      'type': _$AttendanceTypeEnumMap[instance.type]!,
      'status': _$AttendanceStatusEnumMap[instance.status]!,
      'arrivalCode': instance.arrivalCode,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'timestamp': instance.timestamp.toIso8601String(),
      'photoUrl': instance.photoUrl,
      'notes': instance.notes,
      'adminNotes': instance.adminNotes,
      'verifiedBy': instance.verifiedBy,
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$AttendanceTypeEnumMap = {
  AttendanceType.checkIn: 'checkIn',
  AttendanceType.checkOut: 'checkOut',
};

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.pending: 'pending',
  AttendanceStatus.verified: 'verified',
  AttendanceStatus.rejected: 'rejected',
};
