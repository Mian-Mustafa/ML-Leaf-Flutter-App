import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_info.dart';
import '../core/providers/app_providers.dart';
import 'router.dart';
import 'theme.dart';

/// Root application widget. Wires the design-system themes and router, and
/// reacts to the persisted theme-mode preference (FR-12).
class MLleafApp extends ConsumerWidget {
  const MLleafApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
