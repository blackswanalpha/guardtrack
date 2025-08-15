import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/navigation/presentation/pages/main_navigation_page.dart';
import 'features/admin/presentation/pages/admin_main_navigation_page.dart';
import 'features/attendance/presentation/bloc/check_in_bloc.dart';
import 'features/attendance/presentation/bloc/assigned_sites_bloc.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/attendance/domain/repositories/site_repository.dart';
import 'features/messaging/presentation/bloc/messaging_bloc.dart';
import 'shared/services/api_service.dart';
import 'shared/services/secure_storage_service.dart';
import 'shared/services/location_service.dart';
import 'shared/services/geofencing_service.dart';
import 'shared/services/attendance_service.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/check_in_notification_service.dart';
import 'shared/services/daily_report_service.dart';
import 'shared/services/messaging_service.dart';
import 'shared/services/auto_message_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification services
  await _initializeServices();

  runApp(const GuardTrackApp());
}

Future<void> _initializeServices() async {
  try {
    // Initialize check-in notification service
    final checkInNotificationService = CheckInNotificationService();
    await checkInNotificationService.initialize();

    // Initialize daily report service
    final dailyReportService = DailyReportService();
    await dailyReportService.initialize();

    // Send daily attendance report via email on app startup
    print('📧 Attempting to send daily attendance report via email...');
    await dailyReportService.sendDailyReportOnStartup();

    // Initialize and trigger auto-message service
    final autoMessageService = AutoMessageService();
    await autoMessageService.sendStartupMessage();

    print('GuardTrack services initialized successfully');
  } catch (e) {
    print('Failed to initialize GuardTrack services: $e');
  }
}

class GuardTrackApp extends StatelessWidget {
  const GuardTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiService>(
          create: (context) => ApiService(),
        ),
        RepositoryProvider<SecureStorageService>(
          create: (context) => SecureStorageService(),
        ),
        RepositoryProvider<LocationService>(
          create: (context) => LocationService(),
        ),
        RepositoryProvider<GeofencingService>(
          create: (context) => GeofencingService(),
        ),
        RepositoryProvider<AttendanceService>(
          create: (context) => AttendanceService(),
        ),
        RepositoryProvider<NotificationService>(
          create: (context) => NotificationService(),
        ),
        RepositoryProvider<CheckInNotificationService>(
          create: (context) => CheckInNotificationService(),
        ),
        RepositoryProvider<DailyReportService>(
          create: (context) => DailyReportService(),
        ),
        RepositoryProvider<MessagingService>(
          create: (context) => MessagingService(),
        ),
        RepositoryProvider<AutoMessageService>(
          create: (context) => AutoMessageService(),
        ),
        RepositoryProvider<SiteRepository>(
          create: (context) => SiteRepositoryImpl(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            apiService: context.read<ApiService>(),
            storageService: context.read<SecureStorageService>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AppStarted()),
          ),
          BlocProvider<DashboardBloc>(
            create: (context) => DashboardBloc(),
          ),
          BlocProvider<CheckInBloc>(
            create: (context) => CheckInBloc(
              locationService: context.read<LocationService>(),
              geofencingService: context.read<GeofencingService>(),
              attendanceService: context.read<AttendanceService>(),
              siteRepository: context.read<SiteRepository>(),
            ),
          ),
          BlocProvider<AssignedSitesBloc>(
            create: (context) => AssignedSitesBloc(
              siteRepository: context.read<SiteRepository>(),
            ),
          ),
          BlocProvider<AttendanceBloc>(
            create: (context) => AttendanceBloc(),
          ),
          BlocProvider<MessagingBloc>(
            create: (context) => MessagingBloc(
              messagingService: context.read<MessagingService>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          home: const AppNavigator(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const SplashScreen();
        } else if (state is AuthSuccess) {
          // Route based on user role
          if (state.user.user.isAdmin) {
            return AdminMainNavigationPage(user: state.user.user);
          } else {
            return MainNavigationPage(user: state.user.user);
          }
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF002B5B), Color(0xFF1E4A7A)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'GuardTrack',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Secure Arrival. Verified Presence.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
