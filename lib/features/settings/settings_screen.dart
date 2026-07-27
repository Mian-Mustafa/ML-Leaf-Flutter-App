import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_info.dart';
import '../../core/providers/app_providers.dart';

/// Settings (FR-12, FR-14, FR-15): theme control, data reset and trust
/// information. Theme switching is fully wired in Phase 1; reset acts on
/// preferences now and will extend to Hive study data in Phase 2.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SectionLabel('Appearance', theme),
          RadioGroup<ThemeMode>(
            groupValue: mode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).set(value);
              }
            },
            child: const Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  title: Text('System default'),
                  secondary: Icon(Icons.brightness_auto_outlined),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  title: Text('Light'),
                  secondary: Icon(Icons.light_mode_outlined),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  title: Text('Dark'),
                  secondary: Icon(Icons.dark_mode_outlined),
                ),
              ],
            ),
          ),
          const Divider(),
          _SectionLabel('Data', theme),
          ListTile(
            leading: const Icon(Icons.restart_alt_rounded),
            title: const Text('Reset study data'),
            subtitle:
                const Text('Clear progress, quiz history, bookmarks and cards'),
            onTap: () => _confirmReset(context, ref),
          ),
          const Divider(),
          _SectionLabel('About', theme),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy policy'),
            onTap: () => context.push('/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About ML Leaf'),
            onTap: () => context.push('/about'),
          ),
          ListTile(
            leading: const Icon(Icons.tag_rounded),
            title: const Text('Version'),
            trailing: Text(AppInfo.versionName, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset study data?'),
        content: const Text(
          'This permanently deletes your progress, quiz history, bookmarks '
          'and flashcard status on this device. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    // Phase 1: clears preferences only. Hive study boxes are cleared here in
    // Phase 2 once the progress store exists.
    await ref.read(preferencesServiceProvider).clear();
    ref.invalidate(themeModeProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your study data has been reset.')),
      );
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.theme);
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium
            ?.copyWith(color: theme.colorScheme.primary, letterSpacing: 0.8),
      ),
    );
  }
}
