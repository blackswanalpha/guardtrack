class AppConstants {
  // App Information
  static const String appName = 'GuardTrack';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Secure Arrival. Verified Presence.';
  
  // API Configuration
  static const String baseUrl = 'https://api.guardtrack.com';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String isFirstLaunchKey = 'is_first_launch';
  
  // Location Settings
  static const double defaultLocationAccuracy = 50.0; // meters
  static const Duration locationTimeout = Duration(seconds: 15);
  static const Duration locationUpdateInterval = Duration(seconds: 5);
  
  // Database
  static const String databaseName = 'guardtrack.db';
  static const int databaseVersion = 1;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int arrivalCodeLength = 6;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 48.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}
