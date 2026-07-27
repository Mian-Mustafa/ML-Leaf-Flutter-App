import 'package:flutter/material.dart';

import 'empty_state_view.dart';

/// Temporary scaffold for features that are specified but not yet implemented.
/// Each Phase replaces these with the real screen. Built on [EmptyStateView] so
/// the placeholder already looks and reads like a real empty state.
class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    super.key,
    required this.title,
    required this.icon,
    this.description,
    this.showAppBar = true,
  });

  final String title;
  final IconData icon;
  final String? description;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final body = EmptyStateView(
      icon: icon,
      title: title,
      message: description ?? 'Coming soon.',
    );

    if (!showAppBar) return body;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
    );
  }
}
