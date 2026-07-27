import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'core/providers/app_providers.dart';
import 'core/services/preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise local storage. All startup work is offline (FR-01, FR-13).
  await Hive.initFlutter();
  final preferences = await PreferencesService.create();

  runApp(
    ProviderScope(
      overrides: [
        preferencesServiceProvider.overrideWithValue(preferences),
      ],
      child: const MLleafApp(),
    ),
  );
}
