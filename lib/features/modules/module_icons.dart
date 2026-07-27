import 'package:flutter/material.dart';

/// Maps a module's logical [iconKey] to a concrete Material icon. Keeping the
/// mapping in the UI layer lets content JSON stay free of Flutter types.
IconData moduleIcon(String key) {
  switch (key) {
    case 'foundations':
      return Icons.school_outlined;
    case 'data':
      return Icons.dataset_outlined;
    case 'supervised':
      return Icons.checklist_rounded;
    case 'regression':
      return Icons.show_chart_rounded;
    case 'classification':
      return Icons.category_outlined;
    case 'unsupervised':
      return Icons.bubble_chart_outlined;
    case 'evaluation':
      return Icons.fact_check_outlined;
    case 'features':
      return Icons.tune_rounded;
    case 'ensemble':
      return Icons.account_tree_outlined;
    case 'neural':
      return Icons.hub_outlined;
    default:
      return Icons.menu_book_outlined;
  }
}
