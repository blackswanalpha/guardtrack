import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:guardtrack/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardtrack/features/auth/domain/entities/auth_user.dart';
import 'package:guardtrack/shared/models/user_model.dart';

// Simple test to debug what states are emitted
void debugTest() async {
  final authBloc = AuthBloc();

  print('Starting debug test...');

  authBloc.stream.listen((state) {
    print('State emitted: ${state.runtimeType} - $state');
  });

  authBloc.add(const AdminLoginRequested(
    email: 'admin@example.com',
    password: 'password123',
    rememberMe: false,
  ));

  await Future.delayed(const Duration(seconds: 3));
  authBloc.close();
}

void main() {
  group('AuthBloc Admin Login Tests', () {
    late AuthBloc authBloc;

    setUp(() {
      authBloc = AuthBloc();
    });

    tearDown(() {
      authBloc.close();
    });

    group('AdminLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthSuccess] when admin login is successful without 2FA',
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const AdminLoginRequested(
            email: 'admin@example.com',
            password: 'password123',
            rememberMe: false,
          ),
        ),
        wait: const Duration(seconds: 3), // Wait for async operation
        expect: () => [
          AuthLoading(),
          isA<AuthSuccess>().having(
            (state) => state.user.user.role,
            'user role',
            UserRole.admin,
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthSuccess] when admin login is successful with valid 2FA',
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const AdminLoginRequested(
            email: 'admin@example.com',
            password: 'password123',
            twoFactorCode: '123456',
            rememberMe: false,
          ),
        ),
        expect: () => [
          AuthLoading(),
          isA<AuthSuccess>().having(
            (state) => state.user.user.role,
            'user role',
            UserRole.admin,
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when admin login fails with invalid email',
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const AdminLoginRequested(
            email: 'invalid-email',
            password: 'password123',
            rememberMe: false,
          ),
        ),
        expect: () => [
          AuthLoading(),
          isA<AuthFailure>()
              .having((state) => state.type, 'failure type',
                  AuthFailureType.validationError)
              .having((state) => state.message, 'message',
                  contains('valid admin email')),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when admin login fails with short password',
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const AdminLoginRequested(
            email: 'admin@example.com',
            password: '123',
            rememberMe: false,
          ),
        ),
        expect: () => [
          AuthLoading(),
          isA<AuthFailure>()
              .having((state) => state.type, 'failure type',
                  AuthFailureType.validationError)
              .having(
                  (state) => state.message, 'message', contains('at least')),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when admin login fails with invalid 2FA code',
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const AdminLoginRequested(
            email: 'admin@example.com',
            password: 'password123',
            twoFactorCode: '12345', // Invalid - only 5 digits
            rememberMe: false,
          ),
        ),
        expect: () => [
          AuthLoading(),
          isA<AuthFailure>()
              .having((state) => state.type, 'failure type',
                  AuthFailureType.twoFactorInvalid)
              .having((state) => state.message, 'message',
                  contains('Invalid 2FA code')),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when admin login fails with non-numeric 2FA code',
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const AdminLoginRequested(
            email: 'admin@example.com',
            password: 'password123',
            twoFactorCode: 'abcdef', // Invalid - not numeric
            rememberMe: false,
          ),
        ),
        expect: () => [
          AuthLoading(),
          isA<AuthFailure>()
              .having((state) => state.type, 'failure type',
                  AuthFailureType.twoFactorInvalid)
              .having((state) => state.message, 'message',
                  contains('Invalid 2FA code')),
        ],
      );
    });

    group('Regular LoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthSuccess] when regular login is successful with email',
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const LoginRequested(
            email: 'user@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [
          AuthLoading(),
          isA<AuthSuccess>().having(
            (state) => state.user.user.role,
            'user role',
            UserRole.guard,
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthSuccess] when regular login is successful with phone',
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const LoginRequested(
            email: '+1234567890',
            password: 'password123',
          ),
        ),
        expect: () => [
          AuthLoading(),
          isA<AuthSuccess>().having(
            (state) => state.user.user.role,
            'user role',
            UserRole.guard,
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when regular login fails with invalid email/phone',
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const LoginRequested(
            email: 'invalid-input',
            password: 'password123',
          ),
        ),
        expect: () => [
          AuthLoading(),
          isA<AuthFailure>()
              .having((state) => state.type, 'failure type',
                  AuthFailureType.validationError)
              .having((state) => state.message, 'message',
                  contains('valid email address or phone')),
        ],
      );
    });
  });
}
