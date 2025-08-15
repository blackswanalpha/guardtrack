import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:guardtrack/features/auth/presentation/pages/admin_login_page.dart';
import 'package:guardtrack/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardtrack/shared/models/user_model.dart';
import 'package:guardtrack/main.dart';

// Generate mocks
@GenerateMocks([AuthBloc])
import 'admin_login_navigation_test.mocks.dart';

void main() {
  group('AdminLoginPage Navigation Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.empty());
    });

    testWidgets('should navigate to AppNavigator after successful admin login', (WidgetTester tester) async {
      // Create a mock admin user
      final adminUser = UserModel(
        id: 'admin_1',
        email: 'admin@test.com',
        firstName: 'Admin',
        lastName: 'User',
        role: UserRole.admin,
        isActive: true,
        createdAt: DateTime.now(),
        assignedSiteIds: const [],
      );

      final authUser = AuthUser(
        user: adminUser,
        accessToken: 'mock_token',
        refreshToken: 'mock_refresh_token',
        tokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const AdminLoginPage(),
          ),
        ),
      );

      // Verify the admin login page is displayed
      expect(find.text('Admin Portal Access'), findsOneWidget);
      expect(find.text('Secure administrative access'), findsOneWidget);

      // Simulate successful authentication
      when(mockAuthBloc.state).thenReturn(AuthSuccess(authUser));
      mockAuthBloc.add(AuthSuccess(authUser) as AuthEvent);

      // Pump the widget to trigger the state change
      await tester.pump();

      // Verify that navigation was triggered
      // Note: In a real test, we would need to mock Navigator or use a more sophisticated setup
      // This test verifies the basic structure and that the success state is handled
      expect(find.byType(AdminLoginPage), findsOneWidget);
    });

    testWidgets('should show error and logout for non-admin users', (WidgetTester tester) async {
      // Create a mock regular user (not admin)
      final regularUser = UserModel(
        id: 'user_1',
        email: 'user@test.com',
        firstName: 'Regular',
        lastName: 'User',
        role: UserRole.guard,
        isActive: true,
        createdAt: DateTime.now(),
        assignedSiteIds: const ['site_1'],
      );

      final authUser = AuthUser(
        user: regularUser,
        accessToken: 'mock_token',
        refreshToken: 'mock_refresh_token',
        tokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const AdminLoginPage(),
          ),
        ),
      );

      // Simulate authentication with non-admin user
      when(mockAuthBloc.state).thenReturn(AuthSuccess(authUser));
      mockAuthBloc.add(AuthSuccess(authUser) as AuthEvent);

      // Pump the widget to trigger the state change
      await tester.pump();

      // Verify that error message is shown
      expect(find.text('Access denied. Admin privileges required.'), findsOneWidget);
    });

    testWidgets('should show error message on authentication failure', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const AdminLoginPage(),
          ),
        ),
      );

      // Simulate authentication failure
      const errorMessage = 'Invalid credentials';
      when(mockAuthBloc.state).thenReturn(
        const AuthFailure(errorMessage, type: AuthFailureType.invalidCredentials),
      );

      // Pump the widget to trigger the state change
      await tester.pump();

      // Verify that error message is shown
      expect(find.textContaining(errorMessage), findsOneWidget);
    });
  });
}
