import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/brand_gradient.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/status_badge.dart';
import '../modules/module.dart';
import '../modules/module_icons.dart';
import '../modules/module_providers.dart';
import 'lesson.dart';
import 'lesson_providers.dart';

/// Lesson list for a module (key screen "Lesson list", FR-04).
///
/// Presented as a vertical **learning path** (numbered, connected timeline) to
/// visually distinguish a module's interior from the module catalogue and to
/// reinforce the intended study sequence.
class LessonListScreen extends ConsumerWidget {
  const LessonListScreen({super.key, required this.moduleId});

  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final module = ref.watch(moduleByIdProvider(moduleId));
    final lessonsAsync = ref.watch(lessonsByModuleProvider(moduleId));

    return Scaffold(
      appBar: AppBar(title: Text(module?.title ?? 'Lessons')),
      body: lessonsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'Couldn\'t load lessons',
          message: 'Please try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(lessonsByModuleProvider(moduleId)),
          tone: EmptyStateTone.error,
        ),
        data: (lessons) {
          if (lessons.isEmpty) {
            return EmptyStateView(
              icon: Icons.menu_book_outlined,
              title: 'Lessons coming soon',
              message: module == null
                  ? 'This module has no lessons yet.'
                  : 'Lessons for "${module.title}" are on the way.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
            children: [
              if (module != null)
                _ModuleHero(module: module, lessons: lessons),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs, left: 4),
                child: Text('Learning path',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              for (var i = 0; i < lessons.length; i++)
                _PathTile(
                  lesson: lessons[i],
                  isFirst: i == 0,
                  isLast: i == lessons.length - 1,
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Gradient module summary card at the top of the learning path.
class _ModuleHero extends StatelessWidget {
  const _ModuleHero({required this.module, required this.lessons});

  final Module module;
  final List<Lesson> lessons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalMinutes =
        lessons.fold<int>(0, (sum, l) => sum + l.readingMinutes);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: BrandGradient.surface(theme.brightness),
        borderRadius: AppRadius.brXl,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: BrandGradient.brand,
                  borderRadius: AppRadius.brLg,
                ),
                child: Icon(moduleIcon(module.iconKey),
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Module ${module.order}',
                        style: theme.textTheme.labelMedium
                            ?.copyWith(color: theme.colorScheme.primary)),
                    Text(module.title, style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(module.summary, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              StatusBadge(
                label: '${lessons.length} lessons',
                icon: Icons.menu_book_outlined,
                tone: BadgeTone.info,
              ),
              StatusBadge(
                label: '~$totalMinutes min',
                icon: Icons.schedule_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const AppProgressBar(value: 0, label: 'Your progress'),
        ],
      ),
    );
  }
}

/// One node on the learning-path timeline: a numbered marker joined by a
/// connecting rail, beside a tappable lesson card.
class _PathTile extends StatelessWidget {
  const _PathTile({
    required this.lesson,
    required this.isFirst,
    required this.isLast,
  });

  final Lesson lesson;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = theme.colorScheme.outlineVariant;

    final (BadgeTone tone, IconData icon) = switch (lesson.difficulty) {
      Difficulty.beginner => (BadgeTone.success, Icons.eco_rounded),
      Difficulty.intermediate => (BadgeTone.info, Icons.trending_up_rounded),
      Difficulty.advanced => (BadgeTone.warning, Icons.whatshot_rounded),
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline rail with the numbered node.
          SizedBox(
            width: 36,
            child: Column(
              children: [
                SizedBox(
                  height: 6,
                  child: Center(
                    child: Container(
                      width: 2,
                      color: isFirst ? Colors.transparent : line,
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: theme.colorScheme.primary, width: 1.5),
                  ),
                  child: Text('${lesson.order}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      )),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 2,
                      color: isLast ? Colors.transparent : line,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Lesson card.
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context
                      .push('/lessons/${lesson.moduleId}/${lesson.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(lesson.title,
                                  style: theme.textTheme.titleSmall),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: theme.colorScheme.onSurfaceVariant),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lesson.summary,
                          style: theme.textTheme.bodySmall,
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
                                tone: tone),
                            StatusBadge(
                              label: '${lesson.readingMinutes} min',
                              icon: Icons.schedule_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
