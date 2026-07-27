import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Quizzes hub (FR-08). Topic-based multiple-choice quizzes with scoring,
/// explanations and score history arrive in Phase 4.
class QuizzesScreen extends StatelessWidget {
  const QuizzesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Quizzes',
      icon: Icons.quiz_outlined,
      description: 'Test your understanding with topic quizzes.',
    );
  }
}
