import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/auth_user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/admin_login_request.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AdminLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String? twoFactorCode;
  final bool rememberMe;

  const AdminLoginRequested({
    required this.email,
    required this.password,
    this.twoFactorCode,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, twoFactorCode, rememberMe];
}

class LogoutRequested extends AuthEvent {}

class TokenRefreshRequested extends AuthEvent {}

class AuthStatusChanged extends AuthEvent {
  final AuthUser? user;

  const AuthStatusChanged(this.user);

  @override
  List<Object?> get props => [user];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthUser user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;
  final AuthFailureType type;

  const AuthFailure(this.message, {this.type = AuthFailureType.general});

  @override
  List<Object?> get props => [message, type];
}

enum AuthFailureType {
  general,
  invalidCredentials,
  networkError,
  serverError,
  validationError,
  twoFactorRequired,
  twoFactorInvalid,
  accountLocked,
  accountInactive,
  sessionExpired,
  permissionDenied,
}

// Helper class for generating user-friendly error messages
class AuthErrorMessages {
  static String getActionableMessage(
      AuthFailureType type, String originalMessage) {
    switch (type) {
      case AuthFailureType.invalidCredentials:
        return '$originalMessage\n\nTip: Double-check your email and password. If you forgot your password, use the "Forgot Password" option.';
      case AuthFailureType.networkError:
        return '$originalMessage\n\nTip: Check your internet connection and try again.';
      case AuthFailureType.serverError:
        return '$originalMessage\n\nTip: Our servers are experiencing issues. Please try again in a few minutes.';
      case AuthFailureType.validationError:
        return originalMessage; // Validation messages are already specific
      case AuthFailureType.twoFactorInvalid:
        return '$originalMessage\n\nTip: Check your authenticator app or SMS for the latest code.';
      case AuthFailureType.accountLocked:
        return '$originalMessage\n\nTip: Contact your administrator to unlock your account.';
      case AuthFailureType.accountInactive:
        return '$originalMessage\n\nTip: Your account may need activation. Contact support for assistance.';
      case AuthFailureType.sessionExpired:
        return '$originalMessage\n\nTip: Your session has expired for security reasons. Please login again.';
      case AuthFailureType.permissionDenied:
        return '$originalMessage\n\nTip: You don\'t have the required permissions. Contact your administrator.';
      default:
        return originalMessage;
    }
  }
}

class AuthUnauthenticated extends AuthState {}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<AdminLoginRequested>(_onAdminLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<TokenRefreshRequested>(_onTokenRefreshRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Check if user is already authenticated
      final result = await _authRepository.getCurrentUser();

      result.fold(
        (failure) {
          // No current user or error getting user - emit unauthenticated
          emit(AuthUnauthenticated());
        },
        (authUser) {
          if (authUser != null) {
            // User is authenticated
            emit(AuthSuccess(authUser));
          } else {
            // No current user
            emit(AuthUnauthenticated());
          }
        },
      );
    } catch (e) {
      emit(AuthFailure('Failed to initialize app: $e',
          type: AuthFailureType.general));
    }
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Validate input before making API call
      if (!_isValidEmailOrPhone(event.email)) {
        emit(AuthFailure('Please enter a valid email address or phone number.',
            type: AuthFailureType.validationError));
        return;
      }

      if (!_isValidPassword(event.password)) {
        emit(AuthFailure(
            'Password must be at least ${AppConstants.minPasswordLength} characters long.',
            type: AuthFailureType.validationError));
        return;
      }

      // TODO: Replace with actual repository call when API is ready
      // For now, use mock implementation for development

      // Mock successful regular user login
      final mockUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: event.email,
        firstName: _extractFirstName(event.email),
        lastName: 'User',
        role: UserRole.guard,
        isActive: true,
        createdAt: DateTime.now(),
        assignedSiteIds: const ['site_1', 'site_2'], // Mock assigned sites
      );

      final authUser = AuthUser(
        user: mockUser,
        accessToken:
            'mock_user_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken:
            'mock_user_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        tokenExpiresAt: DateTime.now().add(const Duration(hours: 4)),
      );

      // Save the mock user to storage so they stay logged in
      final saveResult = await _authRepository.saveAuthUser(authUser);
      saveResult.fold(
        (failure) {
          // If saving fails, still emit success but log the issue
          debugPrint(
              'Warning: Failed to save user to storage: ${failure.message}');
        },
        (_) {
          // Successfully saved to storage
        },
      );

      // Debug logging
      debugPrint(
          'Regular login successful - User: ${authUser.user.email}, Role: ${authUser.user.role}, IsAdmin: ${authUser.user.isAdmin}');

      emit(AuthSuccess(authUser));
    } catch (e) {
      emit(AuthFailure(
          'Login failed. Please check your connection and try again.',
          type: AuthFailureType.networkError));
    }
  }

  void _onAdminLoginRequested(
      AdminLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Validate input before making API call
      if (!_isValidAdminEmail(event.email)) {
        emit(AuthFailure('Please enter a valid admin email address.',
            type: AuthFailureType.validationError));
        return;
      }

      if (!_isValidPassword(event.password)) {
        emit(AuthFailure(
            'Password must be at least ${AppConstants.minPasswordLength} characters long.',
            type: AuthFailureType.validationError));
        return;
      }

      // Validate 2FA code if provided
      if (event.twoFactorCode != null &&
          !_isValid2FACode(event.twoFactorCode!)) {
        emit(AuthFailure('Invalid 2FA code. Please enter a valid 6-digit code.',
            type: AuthFailureType.twoFactorInvalid));
        return;
      }

      // All validation passed, proceed with mock admin login
      // TODO: Replace with actual repository call when admin API is ready

      // Mock successful admin login
      final mockAdminUser = UserModel(
        id: 'admin_1',
        email: event.email,
        firstName: 'Admin',
        lastName: 'User',
        role: UserRole.admin,
        isActive: true,
        createdAt: DateTime.now(),
        assignedSiteIds: const [], // Admins have access to all sites
      );

      final authUser = AuthUser(
        user: mockAdminUser,
        accessToken: 'mock_admin_access_token',
        refreshToken: 'mock_admin_refresh_token',
        tokenExpiresAt: DateTime.now()
            .add(const Duration(hours: 8)), // Longer session for admins
      );

      // Save the mock admin user to storage so they stay logged in
      final saveResult = await _authRepository.saveAuthUser(authUser);
      saveResult.fold(
        (failure) {
          // If saving fails, still emit success but log the issue
          // TODO: Replace with proper logging framework
          debugPrint(
              'Warning: Failed to save admin user to storage: ${failure.message}');
        },
        (_) {
          // Successfully saved to storage
        },
      );

      // Debug logging
      debugPrint(
          'Admin login successful - User: ${authUser.user.email}, Role: ${authUser.user.role}, IsAdmin: ${authUser.user.isAdmin}');

      emit(AuthSuccess(authUser));
    } catch (e) {
      emit(const AuthFailure(
          'Admin login failed. Please check your connection and try again.',
          type: AuthFailureType.networkError));
    }
  }

  // Helper methods for validation
  bool _isValidEmailOrPhone(String input) {
    // Check if it's an email
    if (input.contains('@')) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      return emailRegex.hasMatch(input);
    } else {
      // Check if it's a phone number
      final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
      return phoneRegex.hasMatch(input);
    }
  }

  bool _isValidAdminEmail(String email) {
    // Accept any valid email format for admin login
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= AppConstants.minPasswordLength;
  }

  bool _isValid2FACode(String code) {
    // Mock 2FA validation - accept any 6-digit code for now
    return code.length == 6 && RegExp(r'^\d{6}$').hasMatch(code);
  }

  void _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Call repository to logout
      final result = await _authRepository.logout();

      result.fold(
        (failure) {
          // Even if logout fails on server, clear local data
          emit(AuthUnauthenticated());
        },
        (_) {
          emit(AuthUnauthenticated());
        },
      );
    } catch (e) {
      // Even if logout fails, clear local authentication state
      emit(AuthUnauthenticated());
    }
  }

  void _onTokenRefreshRequested(
      TokenRefreshRequested event, Emitter<AuthState> emit) async {
    try {
      // Call repository to refresh token
      final result = await _authRepository.refreshToken();

      result.fold(
        (failure) {
          // Token refresh failed - logout user immediately
          emit(AuthFailure('Session expired. Please login again.',
              type: AuthFailureType.sessionExpired));
          // Immediately emit unauthenticated state
          emit(AuthUnauthenticated());
        },
        (authUser) {
          // Token refreshed successfully
          emit(AuthSuccess(authUser));
        },
      );
    } catch (e) {
      emit(const AuthFailure('Token refresh failed. Please login again.',
          type: AuthFailureType.networkError));
      // Immediately emit unauthenticated state
      emit(AuthUnauthenticated());
    }
  }

  void _onAuthStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthSuccess(event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  // Helper methods
  String _extractFirstName(String email) {
    // Extract first name from email (before @ symbol)
    final username = email.split('@').first;
    // Capitalize first letter and remove numbers/special chars
    final cleanName = username.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    if (cleanName.isEmpty) return 'User';
    return cleanName[0].toUpperCase() + cleanName.substring(1).toLowerCase();
  }
}
