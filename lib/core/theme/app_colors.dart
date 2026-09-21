import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background
  static const Color background = Color(0xFF1A1A2E);
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color surface = Color(0xFF2C2C3E);
  static const Color surfaceLight = Color(0xFF3A3A4E);

  // Primary (Emergency Red)
  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color primaryLight = Color(0xFFE53935);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color textMuted = Color(0xFF6E6E80);

  // Glass effect
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFD32F2F), Color(0xFFB71C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2C2C3E), Color(0xFF1E1E30)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
