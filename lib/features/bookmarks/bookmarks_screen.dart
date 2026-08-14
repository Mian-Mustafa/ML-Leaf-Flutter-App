import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/brand_gradient.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/bookmark_button.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/status_badge.dart';
import '../lessons/lesson.dart';
import '../modules/module.dart';
import '../modules/module_icons.dart';
import 'bookmark_providers.dart';

/// A persistent, grouped library of saved lessons.
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(bookmarkedLessonIdsProvider);
    final bookmarks = ref.watch(bookmarkedLessonsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          if (savedIds.isNotEmpty)
            IconButton(
              tooltip: 'Clear all bookmarks',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _confirmClear(context, ref),
            ),
        ],
      ),
      body: bookmarks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'Could not load bookmarks',
          message: 'Your saved lessons are still safe. Please try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(bookmarkedLessonsProvider),
          tone: EmptyStateTone.error,
        ),
        data: (items) {
          if (savedIds.isEmpty) {
            return EmptyStateView(
              icon: Icons.bookmark_outline_rounded,
              title: 'No saved lessons yet',
              message:
                  'Save a lesson to create a quick-return study list here.',
              actionLabel: 'Browse modules',
              onAction: () => context.go('/modules'),
            );
          }

          if (items.isEmpty) {
            return EmptyStateView(
              icon: Icons.bookmark_remove_outlined,
              title: 'Saved lessons are unavailable',
              message:
                  'These bookmarks refer to lessons that are no longer in this version of the course.',
              actionLabel: 'Clear saved lessons',
              onAction: () =>
                  ref.read(bookmarkedLessonIdsProvider.notifier).clear(),
            );
          }

          return _BookmarksList(items: items);
        },
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all bookmarks?'),
        content: const Text(
          'This removes your saved lessons from this device. You can bookmark them again at any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(bookmarkedLessonIdsProvider.notifier).clear();
    }
  }
}

class _BookmarksList extends StatelessWidget {
  const _BookmarksList({required this.items});

  final List<BookmarkedLesson> items;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<BookmarkedLesson>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.module.id, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        _BookmarksHero(count: items.length),
        const SizedBox(height: AppSpacing.xl),
        for (final group in grouped.values) ...[
          _ModuleLabel(module: group.first.module, count: group.length),
          const SizedBox(height: AppSpacing.xs),
          for (final item in group) ...[
            _BookmarkTile(item: item),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _BookmarksHero extends StatelessWidget {
  const _BookmarksHero({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = count == 1 ? '1 lesson saved' : '$count lessons saved';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: BrandGradient.surface(theme.brightness),
        borderRadius: AppRadius.brXl,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: AppRadius.brLg,
            ),
            child: Icon(
              Icons.bookmarks_rounded,
              color: theme.colorScheme.onPrimaryContainer,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your study shelf', style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  'Keep the concepts you want to revisit close at hand.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                StatusBadge(
                  label: label,
                  icon: Icons.bookmark_rounded,
                  tone: BadgeTone.info,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleLabel extends StatelessWidget {
  const _ModuleLabel({required this.module, required this.count});

  final Module module;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = count == 1 ? '1 saved lesson' : '$count saved lessons';

    return Row(
      children: [
        Icon(
          moduleIcon(module.iconKey),
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            'Module ${module.order}: ${module.title}',
            style: theme.textTheme.titleSmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _BookmarkTile extends ConsumerWidget {
  const _BookmarkTile({required this.item});

  final BookmarkedLesson item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = item.lesson;
    final theme = Theme.of(context);
    final (BadgeTone tone, IconData icon) = switch (lesson.difficulty) {
      Difficulty.beginner => (BadgeTone.success, Icons.eco_rounded),
      Difficulty.intermediate => (BadgeTone.info, Icons.trending_up_rounded),
      Difficulty.advanced => (BadgeTone.warning, Icons.whatshot_rounded),
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.xs,
          AppSpacing.sm,
        ),
        onTap: () => context.push('/lessons/${lesson.moduleId}/${lesson.id}'),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: AppRadius.brMd,
          ),
          child: Icon(
            Icons.menu_book_rounded,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(lesson.title, style: theme.textTheme.titleSmall),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xxs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xxs,
                children: [
                  StatusBadge(
                    label: lesson.difficulty.label,
                    icon: icon,
                    tone: tone,
                  ),
                  StatusBadge(
                    label: '${lesson.readingMinutes} min',
                    icon: Icons.schedule_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: BookmarkButton(
          saved: true,
          onToggle: () =>
              ref.read(bookmarkedLessonIdsProvider.notifier).remove(lesson.id),
        ),
      ),
    );
  }
}
