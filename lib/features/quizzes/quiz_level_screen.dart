import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/widgets/empty_state_view.dart';
import '../modules/module.dart';
import '../modules/module_icons.dart';
import '../modules/module_providers.dart';

/// Difficulty selection for a single top-level quiz module. A selected level
/// opens the full assessment focused on that section.
class QuizLevelScreen extends ConsumerWidget {
  const QuizLevelScreen({super.key, required this.moduleId});

  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(modulesProvider);

    return modules.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: const Text('Quiz levels')),
        body: EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'Couldn\'t load module',
          message: 'The quiz levels could not be opened. Please try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(modulesProvider),
          tone: EmptyStateTone.error,
        ),
      ),
      data: (items) {
        Module? module;
        for (final item in items) {
          if (item.id == moduleId) {
            module = item;
            break;
          }
        }

        if (module == null) return const _MissingQuizModuleScreen();
        return _QuizLevelPicker(module: module);
      },
    );
  }
}

class _QuizLevelPicker extends StatelessWidget {
  const _QuizLevelPicker({required this.module});

  final Module module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(module.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 720
              ? AppSpacing.xl
              : AppSpacing.md;
          final crossAxisCount = constraints.maxWidth >= 1040
              ? 3
              : constraints.maxWidth >= 620
              ? 2
              : 1;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.lg,
                    horizontalPadding,
                    AppSpacing.md,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: AppRadius.brSm,
                        ),
                        child: Icon(
                          moduleIcon(module.iconKey),
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose your level',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Module ${module.order.toString().padLeft(2, '0')} assessment',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  AppSpacing.sm,
                  horizontalPadding,
                  AppSpacing.xxxl,
                ),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent: 188,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                  ),
                  itemCount: _quizLevels.length,
                  itemBuilder: (context, index) => _QuizLevelCard(
                    level: _quizLevels[index],
                    onTap: () => context.push(
                      '/quizzes/${module.id}/${_quizLevels[index].id}',
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuizLevelCard extends StatelessWidget {
  const _QuizLevelCard({required this.level, required this.onTap});

  final _QuizLevel level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface =
        Color.lerp(
          theme.colorScheme.surface,
          level.color,
          theme.brightness == Brightness.dark ? 0.18 : 0.075,
        ) ??
        theme.colorScheme.surface;

    return Semantics(
      label: '${level.label} quiz level',
      button: true,
      child: Material(
        color: surface,
        borderRadius: AppRadius.brSm,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brSm,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.brSm,
              border: Border.all(color: level.color.withValues(alpha: 0.42)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: level.color,
                          borderRadius: AppRadius.brSm,
                        ),
                        child: Icon(level.icon, color: Colors.white),
                      ),
                      const Spacer(),
                      Text(
                        level.number,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: level.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(level.label, style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    level.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: AppSizes.iconSm,
                        color: level.color,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        'Start assessment',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: level.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: AppSizes.iconSm,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MissingQuizModuleScreen extends StatelessWidget {
  const _MissingQuizModuleScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz levels')),
      body: EmptyStateView(
        icon: Icons.quiz_outlined,
        title: 'Module not found',
        message:
            'Return to the quiz library and select one of the main modules.',
        actionLabel: 'Back to quizzes',
        onAction: () => context.go('/quizzes'),
      ),
    );
  }
}

const _quizLevels = <_QuizLevel>[
  _QuizLevel(
    id: 'easy',
    number: 'LEVEL 01',
    label: 'Easy',
    description: 'Build confidence with core ideas.',
    icon: Icons.wb_sunny_outlined,
    color: Color(0xFF23824A),
  ),
  _QuizLevel(
    id: 'medium',
    number: 'LEVEL 02',
    label: 'Medium',
    description: 'Apply concepts across common cases.',
    icon: Icons.bolt_outlined,
    color: Color(0xFFC17B16),
  ),
  _QuizLevel(
    id: 'hard',
    number: 'LEVEL 03',
    label: 'Hard',
    description: 'Test deeper understanding and reasoning.',
    icon: Icons.local_fire_department_outlined,
    color: Color(0xFFB23B42),
  ),
];

class _QuizLevel {
  const _QuizLevel({
    required this.id,
    required this.number,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String id;
  final String number;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
}
