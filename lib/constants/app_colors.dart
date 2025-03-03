import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52D5);
  static const Color primaryLight = Color(0xFF8F88FF);

  // Secondary colors
  static const Color secondary = Color(0xFF00BFA6);
  static const Color secondaryDark = Color(0xFF00A896);
  static const Color secondaryLight = Color(0xFF33CFBC);

  // Neutral colors
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFAAAAAA);

  // Action colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB300);
  static const Color info = Color(0xFF2196F3);

  // Credit system colors
  static const Color credits = Color(0xFFFFD700);
  static const Color timer = Color(0xFF64B5F6);

  // Message bubbles
  static const Color userBubble = primary;
  static const Color botBubble = Color(0xFFEEEEEE);
  static const Color userText = Colors.white;
  static const Color botText = textPrimary;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
