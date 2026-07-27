import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Search (FR-06). Indexed search over lessons, algorithms and interview
/// questions is added with the content layer.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const FeaturePlaceholder(
        title: 'Search everything',
        icon: Icons.search_rounded,
        description:
            'Find lessons, algorithms and interview questions by keyword.',
        showAppBar: false,
      ),
    );
  }
}
