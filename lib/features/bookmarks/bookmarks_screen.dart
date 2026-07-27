import 'package:flutter/material.dart';

import '../../core/widgets/empty_state_view.dart';

/// Bookmarks (FR-07). Saved lessons and interview questions appear here; shown
/// as a proper empty state until the content layer supplies saved items.
class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: const EmptyStateView(
        icon: Icons.bookmark_outline_rounded,
        title: 'No bookmarks yet',
        message:
            'Tap the bookmark icon on any lesson or question to save it here '
            'for quick access.',
      ),
    );
  }
}
