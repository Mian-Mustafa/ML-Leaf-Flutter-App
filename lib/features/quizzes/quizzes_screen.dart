import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/status_badge.dart';
import '../modules/module.dart';
import '../modules/module_icons.dart';
import '../modules/module_providers.dart';

/// Quiz catalogue organised strictly by the app's top-level learning modules.
/// Lesson and submodule content is intentionally not displayed on this screen.
class QuizzesScreen extends ConsumerWidget {
  const QuizzesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(modulesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quizzes')),
      body: modules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'Couldn\'t load quiz modules',
          message: 'The quiz module catalogue could not be opened. Please try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(modulesProvider),
          tone: EmptyStateTone.error,
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateView(
              icon: Icons.quiz_outlined,
              title: 'No quiz modules yet',
              message: 'Quiz modules will appear here.',
            );
          }

          return _QuizModuleCatalog(modules: items);
        },
      ),
    );
  }
}

class _QuizModuleCatalog extends StatelessWidget {
  const _QuizModuleCatalog({required this.modules});

  final List<Module> modules;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = switch (constraints.maxWidth) {
          >= 1180 => 3,
          >= 720 => 2,
          _ => 1,
        };
        final horizontalPadding =
            constraints.maxWidth >= 720 ? AppSpacing.xl : AppSpacing.md;
        final cardHeight = constraints.maxWidth < 720 ? 166.0 : 174.0;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.46 : 0.58,
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: AppRadius.brSm,
                        ),
                        child: Icon(
                          Icons.quiz_rounded,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quiz library',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Main module practice',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(
                        label: '${modules.length} modules',
                        icon: Icons.layers_outlined,
                        tone: BadgeTone.info,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppSpacing.lg,
                horizontalPadding,
                AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Main modules',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      '01 - ${modules.length.toString().padLeft(2, '0')}',
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                AppSpacing.xxxl,
              ),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisExtent: cardHeight,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                ),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  return _QuizModuleCard(module: modules[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuizModuleCard extends StatelessWidget {
  const _QuizModuleCard({required this.module});

  final Module module;

  static const _accentColors = <Color>[
    Color(0xFF18776F),
    Color(0xFF2466A3),
    Color(0xFF6357A6),
    Color(0xFFC4621E),
    Color(0xFFC2376B),
    Color(0xFF2C7D4C),
    Color(0xFF1E778B),
    Color(0xFF9A6A14),
    Color(0xFF5B5F68),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _accentColors[(module.order - 1) % _accentColors.length];
    final surface = Color.lerp(
          theme.colorScheme.surface,
          accent,
          theme.brightness == Brightness.dark ? 0.17 : 0.055,
        ) ??
        theme.colorScheme.surface;

    return Semantics(
      label: 'Quiz module ${module.order}: ${module.title}',
      button: true,
      child: Material(
        color: surface,
        borderRadius: AppRadius.brSm,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/quizzes/${module.id}'),
          borderRadius: AppRadius.brSm,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.brSm,
              border: Border.all(color: accent.withValues(alpha: 0.38)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  left: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(AppRadius.sm),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md + 4,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.13),
                              borderRadius: AppRadius.brSm,
                            ),
                            child: Text(
                              module.order.toString().padLeft(2, '0'),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(moduleIcon(module.iconKey), color: accent),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        module.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Expanded(
                        child: Text(
                          module.summary,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.quiz_outlined,
                            size: AppSizes.iconSm,
                            color: accent,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            'Choose level',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: accent,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
