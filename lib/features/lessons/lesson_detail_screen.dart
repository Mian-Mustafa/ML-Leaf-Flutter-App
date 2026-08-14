import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/brand_gradient.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/bookmark_button.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/status_badge.dart';
import '../bookmarks/bookmark_providers.dart';
import '../progress/progress_providers.dart';
import 'lesson.dart';
import 'lesson_providers.dart';
import 'widgets/lesson_content_view.dart';

/// Lesson reader (FR-05): gradient hero, structured content, key points,
/// completion and bookmark, plus a scroll-linked reading-progress bar.
/// Completion and bookmarks persist locally on the device.
class LessonDetailScreen extends ConsumerStatefulWidget {
  const LessonDetailScreen({
    super.key,
    required this.moduleId,
    required this.lessonId,
  });

  final String moduleId;
  final String lessonId;

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  final _scrollController = ScrollController();
  final _readProgress = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    _readProgress.value = max <= 0
        ? 0
        : (_scrollController.offset / max).clamp(0.0, 1.0);
  }

  Future<void> _toggleBookmark() async {
    final wasSaved = ref
        .read(bookmarkedLessonIdsProvider)
        .contains(widget.lessonId);
    await ref
        .read(bookmarkedLessonIdsProvider.notifier)
        .toggle(widget.lessonId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasSaved ? 'Bookmark removed.' : 'Lesson saved to bookmarks.',
        ),
      ),
    );
  }

  Future<void> _toggleCompletion() async {
    final wasCompleted = ref
        .read(studyProgressProvider)
        .completedLessonIds
        .contains(widget.lessonId);
    await ref
        .read(studyProgressProvider.notifier)
        .toggleLessonCompletion(widget.lessonId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasCompleted ? 'Lesson marked as incomplete.' : 'Lesson completed.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _readProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lessonAsync = ref.watch(
      lessonProvider((moduleId: widget.moduleId, lessonId: widget.lessonId)),
    );
    final bookmarked = ref
        .watch(bookmarkedLessonIdsProvider)
        .contains(widget.lessonId);
    final completed = ref
        .watch(studyProgressProvider)
        .completedLessonIds
        .contains(widget.lessonId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson'),
        actions: [BookmarkButton(saved: bookmarked, onToggle: _toggleBookmark)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: ValueListenableBuilder<double>(
            valueListenable: _readProgress,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 3,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
        ),
      ),
      body: lessonAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'Couldn\'t open this lesson',
          message: 'The lesson content could not be loaded.',
          tone: EmptyStateTone.error,
        ),
        data: (lesson) {
          if (lesson == null) {
            return const EmptyStateView(
              icon: Icons.search_off_rounded,
              title: 'Lesson not found',
              message: 'This lesson does not exist.',
            );
          }
          return _LessonBody(
            lesson: lesson,
            scrollController: _scrollController,
            completed: completed,
            onToggleComplete: _toggleCompletion,
          );
        },
      ),
    );
  }
}

class _LessonBody extends StatelessWidget {
  const _LessonBody({
    required this.lesson,
    required this.scrollController,
    required this.completed,
    required this.onToggleComplete,
  });

  final Lesson lesson;
  final ScrollController scrollController;
  final bool completed;
  final VoidCallback onToggleComplete;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        _LessonHero(lesson: lesson),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LessonContentView(blocks: lesson.content),
              if (lesson.keyPoints.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                _KeyPoints(points: lesson.keyPoints),
              ],
              if (lesson.commonMistakes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _CommonMistakes(items: lesson.commonMistakes),
              ],
              const SizedBox(height: AppSpacing.xl),
              _CompleteButton(completed: completed, onToggle: onToggleComplete),
            ],
          ),
        ),
      ],
    );
  }
}

class _LessonHero extends StatelessWidget {
  const _LessonHero({required this.lesson});
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (BadgeTone tone, IconData icon) = switch (lesson.difficulty) {
      Difficulty.beginner => (BadgeTone.success, Icons.eco_rounded),
      Difficulty.intermediate => (BadgeTone.info, Icons.trending_up_rounded),
      Difficulty.advanced => (BadgeTone.warning, Icons.whatshot_rounded),
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: BrandGradient.surface(theme.brightness),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lesson ${lesson.order}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(lesson.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            lesson.summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              StatusBadge(
                label: lesson.difficulty.label,
                icon: icon,
                tone: tone,
              ),
              StatusBadge(
                label: '${lesson.readingMinutes} min read',
                icon: Icons.schedule_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompleteButton extends StatelessWidget {
  const _CompleteButton({required this.completed, required this.onToggle});
  final bool completed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onToggle,
        icon: Icon(
          completed
              ? Icons.check_circle_rounded
              : Icons.check_circle_outline_rounded,
        ),
        label: Text(completed ? 'Completed' : 'Mark as complete'),
        style: completed
            ? FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              )
            : null,
      ),
    );
  }
}

class _KeyPoints extends StatelessWidget {
  const _KeyPoints({required this.points});
  final List<String> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: AppRadius.brLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.key_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Key points', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final point in points)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(point, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CommonMistakes extends StatelessWidget {
  const _CommonMistakes({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.brLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Common mistakes', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: theme.textTheme.bodyMedium),
                  Expanded(
                    child: Text(item, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
