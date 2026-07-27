import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import 'semantic_colors.dart';

/// Central theme definition implementing the MLleaf design system
/// (documentation plan sections 13.3–13.4).
///
/// Typography scale from the plan:
///  - Screen title: 24–28 sp
///  - Section heading: 18–22 sp
///  - Body text: 15–17 sp (1.4–1.6 line height)
///  - Caption / metadata: 12–14 sp
///  - Button label: 14–16 sp
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: brightness,
    ).copyWith(
      primary: isLight ? AppColors.primaryGreen : AppColors.lightGreen,
      onPrimary: isLight ? Colors.white : AppColors.darkGreen,
      primaryContainer:
          isLight ? AppColors.lightGreen : AppColors.darkGreenContainer,
      onPrimaryContainer:
          isLight ? AppColors.darkGreen : AppColors.lightGreen,
      surface: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
      error: isLight ? AppColors.error : const Color(0xFFF2B8B5),
    );

    final onSurface =
        isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark;
    final onSurfaceMuted =
        isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark;

    final textTheme = _textTheme(onSurface, onSurfaceMuted);
    final shadow = (isLight ? AppColors.darkGreen : Colors.black)
        .withValues(alpha: isLight ? 0.06 : 0.25);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isLight ? AppColors.backgroundLight : AppColors.backgroundDark,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      extensions: [isLight ? SemanticColors.light : SemanticColors.dark],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor:
            isLight ? AppColors.backgroundLight : AppColors.backgroundDark,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 3,
        surfaceTintColor: colorScheme.primary,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
        shadowColor: shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brLg,
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, AppSizes.minTouchTarget),
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, AppSizes.minTouchTarget),
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, AppSizes.minTouchTarget),
          textStyle: textTheme.labelLarge,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shadowColor: shadow,
        elevation: 3,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: AppSizes.iconMd,
            color: selected
                ? colorScheme.onPrimaryContainer
                : onSurfaceMuted,
          );
        }),
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
        height: 68,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        space: 1,
      ),
      chipTheme: ChipThemeData(
        labelStyle: textTheme.labelMedium,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brSm),
      ),
      dialogTheme: DialogThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brXl),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: 10,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _FadeUpwardsSharedAxis(),
        },
      ),
    );
  }

  static TextTheme _textTheme(Color onSurface, Color muted) {
    return TextTheme(
      // Screen title (24–28 sp)
      headlineSmall: TextStyle(
        fontSize: 26,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: onSurface,
      ),
      // Section heading (18–22 sp)
      titleMedium: TextStyle(
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      // Body text (15–17 sp, generous line height)
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: onSurface),
      bodyMedium: TextStyle(fontSize: 15, height: 1.5, color: onSurface),
      // Caption / metadata (12–14 sp)
      bodySmall: TextStyle(fontSize: 13, height: 1.4, color: muted),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: muted,
      ),
      // Button label (14–16 sp)
      labelLarge: const TextStyle(
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// A gentle fade + upward slide shared-axis transition for pushed routes.
/// Keeps navigation feeling immediate (short distance, fast curve).
class _FadeUpwardsSharedAxis extends PageTransitionsBuilder {
  const _FadeUpwardsSharedAxis();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
