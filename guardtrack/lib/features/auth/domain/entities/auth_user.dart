import 'package:equatable/equatable.dart';
import '../../../../shared/models/user_model.dart';

class AuthUser extends Equatable {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final DateTime tokenExpiresAt;

  const AuthUser({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenExpiresAt,
  });

  bool get isTokenExpired => DateTime.now().isAfter(tokenExpiresAt);
  
  bool get isTokenExpiringSoon {
    final now = DateTime.now();
    final fiveMinutesFromNow = now.add(const Duration(minutes: 5));
    return tokenExpiresAt.isBefore(fiveMinutesFromNow);
  }

  AuthUser copyWith({
    UserModel? user,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) {
    return AuthUser(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
    );
  }

  @override
  List<Object?> get props => [user, accessToken, refreshToken, tokenExpiresAt];
}
