import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Progress summary (FR-11). Module completion, completed lessons, scores and
/// attempts are shown once the progress store is in place.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: const FeaturePlaceholder(
        title: 'Your learning progress',
        icon: Icons.insights_rounded,
        description:
            'Module completion, quiz scores and attempts — stored on device.',
        showAppBar: false,
      ),
    );
  }
}
