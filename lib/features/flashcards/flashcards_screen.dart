import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Flashcards (FR-09). Front/back revision cards with a difficult-card review
/// mode arrive in Phase 4.
class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      title: 'Flashcards',
      icon: Icons.style_outlined,
      description: 'Revise concepts quickly with front-and-back cards.',
    );
  }
}
