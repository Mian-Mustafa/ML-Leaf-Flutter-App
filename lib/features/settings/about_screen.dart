import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';

/// About screen (FR-15): product identity, version, developer contact and
/// copyright. Content must match the released build and store listing.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                Icon(Icons.eco_rounded,
                    size: 72, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(AppInfo.fullTitle,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text('Version ${AppInfo.versionName}',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(AppInfo.tagline, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 12),
          Text(
            AppInfo.brandIdea,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const Divider(height: 40),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.mail_outline_rounded),
            title: const Text('Contact'),
            subtitle: const Text(AppInfo.supportEmail),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.copyright_rounded),
            title: const Text('Copyright'),
            subtitle: const Text(AppInfo.copyright),
          ),
        ],
      ),
    );
  }
}
