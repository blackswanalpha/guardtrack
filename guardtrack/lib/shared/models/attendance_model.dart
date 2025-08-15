import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attendance_model.g.dart';

enum AttendanceStatus { pending, verified, rejected }
enum AttendanceType { checkIn, checkOut }

@JsonSerializable()
class AttendanceModel extends Equatable {
  final String id;
  final String guardId;
  final String siteId;
  final AttendanceType type;
  final AttendanceStatus status;
  final String arrivalCode;
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final String? photoUrl;
  final String? notes;
  final String? adminNotes;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AttendanceModel({
    required this.id,
    required this.guardId,
    required this.siteId,
    required this.type,
    required this.status,
    required this.arrivalCode,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.photoUrl,
    this.notes,
    this.adminNotes,
    this.verifiedBy,
    this.verifiedAt,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isCheckIn => type == AttendanceType.checkIn;
  bool get isCheckOut => type == AttendanceType.checkOut;
  bool get isPending => status == AttendanceStatus.pending;
  bool get isVerified => status == AttendanceStatus.verified;
  bool get isRejected => status == AttendanceStatus.rejected;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) => 
      _$AttendanceModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);

  AttendanceModel copyWith({
    String? id,
    String? guardId,
    String? siteId,
    AttendanceType? type,
    AttendanceStatus? status,
    String? arrivalCode,
    double? latitude,
    double? longitude,
    double? accuracy,
    DateTime? timestamp,
    String? photoUrl,
    String? notes,
    String? adminNotes,
    String? verifiedBy,
    DateTime? verifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      guardId: guardId ?? this.guardId,
      siteId: siteId ?? this.siteId,
      type: type ?? this.type,
      status: status ?? this.status,
      arrivalCode: arrivalCode ?? this.arrivalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      adminNotes: adminNotes ?? this.adminNotes,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        guardId,
        siteId,
        type,
        status,
        arrivalCode,
        latitude,
        longitude,
        accuracy,
        timestamp,
        photoUrl,
        notes,
        adminNotes,
        verifiedBy,
        verifiedAt,
        createdAt,
        updatedAt,
      ];
}
