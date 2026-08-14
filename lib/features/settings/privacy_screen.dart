import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';

/// Privacy policy (FR-15, plan section 25.3). This in-app text must match the
/// published privacy-policy URL and the Play Data Safety declaration.
/// This offline build stores learner state only on the device and does not
/// transmit user data off-device.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _sections = <(String, String)>[
    (
      'Scope of this policy',
      'This policy applies to ${AppInfo.fullTitle} (ML Leaf), version '
          '${AppInfo.versionName}.',
    ),
    (
      'Information handled on your device',
      'ML Leaf stores learning-progress information locally on your device so '
          'the app can work: completed lessons, bookmarks, quiz attempts and '
          'scores, interview-track completion, and app settings such as theme '
          'and onboarding status. Interview responses are used only during the '
          'active practice session and are not saved.',
    ),
    (
      'Collection, use, and sharing',
      'ML Leaf does not create user accounts and does not collect, transmit, '
          'sell, rent, or share your learning data or personal information. No '
          'such data is sent to us or to third parties. The locally stored '
          'information is used only to provide the app\'s learning, progress, '
          'bookmark, quiz, interview, and settings features.',
    ),
    (
      'Permissions, advertising, and analytics',
      'The release version of ML Leaf does not request access to your location, '
          'camera, microphone, contacts, photos, files, or other sensitive device '
          'data. It does not include advertising, analytics, or crash-reporting '
          'services.',
    ),
    (
      'Data retention and deletion',
      'Local study data remains on your device until you delete it. To remove '
          'it, use Settings > Reset study data. You can also remove the app from '
          'your device. ML Leaf has no account or server-side profile to delete.',
    ),
    (
      'Children\'s privacy',
      'ML Leaf does not collect personal information from users of any age. '
          'Because no personal information is transmitted to us, we cannot use '
          'it to identify or contact a child.',
    ),
    (
      'Changes to this policy',
      'We will update this policy before introducing any new data practice, '
          'such as accounts, network services, analytics, advertising, or device '
          'permissions. Material changes will be communicated through an app '
          'update and the published privacy-policy page.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy policy')),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Privacy policy', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Last updated: August 15, 2026',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            for (final (title, body) in _sections) ...[
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              Text(body, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 18),
            ],
            Text(
              'Contact: ${AppInfo.supportEmail}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
