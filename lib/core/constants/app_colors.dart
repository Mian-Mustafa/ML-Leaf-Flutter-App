import 'package:flutter/material.dart';

/// MLleaf colour system, taken from the design system in the documentation plan
/// (section 13.3). Colour must never be the only signal for correctness,
/// completion or error state — always pair it with text or an icon.
abstract final class AppColors {
  // Brand greens
  static const Color primaryGreen = Color(0xFF1F825C);
  static const Color darkGreen = Color(0xFF155F45);
  static const Color lightGreen = Color(0xFFE9F7F1);

  // Light surfaces
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF7FAF8);

  // Dark surfaces (dark equivalents of the light palette)
  static const Color surfaceDark = Color(0xFF12211B);
  static const Color backgroundDark = Color(0xFF0C1712);
  static const Color darkGreenContainer = Color(0xFF1B3A2C);

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFB3261E);
  static const Color warning = Color(0xFFA46400);

  // Neutral text
  static const Color textPrimaryLight = Color(0xFF13221C);
  static const Color textSecondaryLight = Color(0xFF4A5B53);
  static const Color textPrimaryDark = Color(0xFFE7F0EB);
  static const Color textSecondaryDark = Color(0xFFA7B7AF);
}
