import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';

/// Privacy policy (FR-15, plan section 25.3). This in-app text must match the
/// published privacy-policy URL and the Play Data Safety declaration.
/// Version 1.0 baseline: no personal data is collected; everything stays local.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _sections = <(String, String)>[
    (
      'Data we collect',
      'ML Leaf does not collect any personal data. There is no account, and the '
          'app does not send your learning activity to any server.',
    ),
    (
      'Local storage',
      'Your progress, bookmarks, quiz scores and settings are stored only on '
          'your device using the app\'s local storage.',
    ),
    (
      'Third-party services',
      'Version 1.0 includes no advertising or analytics SDKs and shares no data '
          'with third parties.',
    ),
    (
      'Children\'s privacy',
      'ML Leaf is an educational reference and does not knowingly collect '
          'information from anyone.',
    ),
    (
      'Deleting your data',
      'You can clear all study data at any time from Settings → Reset study '
          'data, or by uninstalling the app.',
    ),
    (
      'Policy updates',
      'Material changes will be communicated through an app update and the '
          'published privacy policy.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy policy')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(AppInfo.appName, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Effective date: to be set at release',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 20),
          for (final (title, body) in _sections) ...[
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 18),
          ],
          Text('Contact: ${AppInfo.supportEmail}',
              style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
