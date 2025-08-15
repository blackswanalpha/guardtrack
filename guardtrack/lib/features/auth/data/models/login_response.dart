import 'package:json_annotation/json_annotation.dart';
import '../../../../shared/models/user_model.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn; // seconds
  final String tokenType;

  const LoginResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
  });

  DateTime get tokenExpiresAt => DateTime.now().add(Duration(seconds: expiresIn));

  factory LoginResponse.fromJson(Map<String, dynamic> json) => 
      _$LoginResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
