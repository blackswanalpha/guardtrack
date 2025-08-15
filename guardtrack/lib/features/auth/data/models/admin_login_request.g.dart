// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminLoginRequest _$AdminLoginRequestFromJson(Map<String, dynamic> json) =>
    AdminLoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      twoFactorCode: json['twoFactorCode'] as String?,
      rememberMe: json['rememberMe'] as bool? ?? false,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
    );

Map<String, dynamic> _$AdminLoginRequestToJson(AdminLoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'twoFactorCode': instance.twoFactorCode,
      'rememberMe': instance.rememberMe,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
    };
