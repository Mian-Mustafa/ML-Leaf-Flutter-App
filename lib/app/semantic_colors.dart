import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Semantic status colours exposed through the theme so widgets can read them
/// with `Theme.of(context).extension<SemanticColors>()`. Each role has an
/// "on" and a soft "container" variant for accessible foreground/background
/// pairs in both light and dark modes (design system §13.3).
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.success,
    required this.onSuccessContainer,
    required this.successContainer,
    required this.warning,
    required this.onWarningContainer,
    required this.warningContainer,
    required this.info,
    required this.infoContainer,
  });

  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color info;
  final Color infoContainer;

  static const light = SemanticColors(
    success: AppColors.success,
    successContainer: Color(0xFFD7F0D8),
    onSuccessContainer: Color(0xFF11431A),
    warning: AppColors.warning,
    warningContainer: Color(0xFFFBE7C6),
    onWarningContainer: Color(0xFF4A2E00),
    info: AppColors.primaryGreen,
    infoContainer: AppColors.lightGreen,
  );

  static const dark = SemanticColors(
    success: Color(0xFF7FD98A),
    successContainer: Color(0xFF1E3A24),
    onSuccessContainer: Color(0xFFD7F0D8),
    warning: Color(0xFFE6B366),
    warningContainer: Color(0xFF3E2E12),
    onWarningContainer: Color(0xFFFBE7C6),
    info: AppColors.lightGreen,
    infoContainer: AppColors.darkGreenContainer,
  );

  @override
  SemanticColors copyWith({
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? infoContainer,
  }) {
    return SemanticColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
    );
  }

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
    );
  }
}

/// Convenience access to semantic colours.
extension SemanticColorsX on BuildContext {
  SemanticColors get semantic =>
      Theme.of(this).extension<SemanticColors>() ?? SemanticColors.light;
}
