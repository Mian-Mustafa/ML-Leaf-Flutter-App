import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Leaf-inspired brand gradients. Kept subtle so text stays readable and the
/// interface remains "readable before decorative" (design principle §13.2).
abstract final class BrandGradient {
  /// Soft tint for header backdrops behind on-surface text.
  static LinearGradient surface(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isLight
          ? const [AppColors.lightGreen, AppColors.backgroundLight]
          : const [AppColors.darkGreenContainer, AppColors.backgroundDark],
    );
  }

  /// Stronger brand fill for the splash / hero medallion.
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryGreen, AppColors.darkGreen],
  );
}
