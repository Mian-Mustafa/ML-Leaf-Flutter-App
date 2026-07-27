import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Interview preparation (FR-10). Questions organised by category and
/// difficulty arrive in Phase 4.
class InterviewScreen extends StatelessWidget {
  const InterviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Interview prep',
      icon: Icons.work_outline_rounded,
      description: 'Browse interview questions by category and difficulty.',
    );
  }
}
