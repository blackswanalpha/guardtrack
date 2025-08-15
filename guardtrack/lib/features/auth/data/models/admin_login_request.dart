import 'package:json_annotation/json_annotation.dart';

part 'admin_login_request.g.dart';

@JsonSerializable()
class AdminLoginRequest {
  final String email;
  final String password;
  final String? twoFactorCode;
  final bool rememberMe;
  final String? deviceId;
  final String? deviceName;

  const AdminLoginRequest({
    required this.email,
    required this.password,
    this.twoFactorCode,
    this.rememberMe = false,
    this.deviceId,
    this.deviceName,
  });

  factory AdminLoginRequest.fromJson(Map<String, dynamic> json) => 
      _$AdminLoginRequestFromJson(json);
  
  Map<String, dynamic> toJson() => _$AdminLoginRequestToJson(this);

  // Convert to regular LoginRequest for API compatibility
  Map<String, dynamic> toLoginRequestJson() {
    final json = toJson();
    // Remove admin-specific fields that the API might not expect
    json.remove('rememberMe');
    return json;
  }
}
