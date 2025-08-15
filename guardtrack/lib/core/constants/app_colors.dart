import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (from design document)
  static const Color primaryBlue = Color(0xFF002B5B);
  static const Color accentGreen = Color(0xFF28A745);
  static const Color warningAmber = Color(0xFFFFC107);
  static const Color backgroundGray = Color(0xFFF4F6F8);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFFFFFFFF);

  // Extended Color Palette
  static const Color primaryLight = Color(0xFF1E4A7A);
  static const Color primaryDark = Color(0xFF001A3D);
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF1B5E20);
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color warningDark = Color(0xFFF57C00);
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color errorLight = Color(0xFFFF5252);
  static const Color errorDark = Color(0xFFC62828);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Status Colors
  static const Color statusVerified = accentGreen;
  static const Color statusPending = warningAmber;
  static const Color statusRejected = errorRed;
  static const Color statusOffline = gray500;

  // Convenience aliases for commonly used colors
  static const Color successGreen = accentGreen;
  static const Color warningYellow = warningAmber;
  static const Color textSecondary = gray600;

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlue, primaryLight],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGreen, successLight],
  );

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
}
