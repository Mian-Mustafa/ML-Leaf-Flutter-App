import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/brand_gradient.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_badge.dart';
import '../modules/module.dart';
import '../modules/module_icons.dart';
import '../modules/module_providers.dart';

/// Flashcards are organised by main learning module. Lesson-level content is
/// deliberately not included in this selector.
class FlashcardsScreen extends ConsumerWidget {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(modulesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: modules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'Couldn\'t load modules',
          message:
              'The flashcard module list could not be opened. Please try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(modulesProvider),
          tone: EmptyStateTone.error,
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateView(
              icon: Icons.style_outlined,
              title: 'No modules yet',
              message: 'Flashcard modules will appear here.',
            );
          }

          return _FlashcardModuleCatalog(modules: items);
        },
      ),
    );
  }
}

class _FlashcardModuleCatalog extends StatelessWidget {
  const _FlashcardModuleCatalog({required this.modules});

  final List<Module> modules;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = switch (constraints.maxWidth) {
          >= 1120 => 3,
          >= 700 => 2,
          _ => 1,
        };
        final horizontalPadding =
            constraints.maxWidth >= 700 ? AppSpacing.xl : AppSpacing.md;
        const cardHeight = 176.0;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: BrandGradient.surface(theme.brightness),
                ),
                child: SizedBox(
                  height: 132,
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
                            borderRadius: AppRadius.brMd,
                          ),
                          child: Icon(
                            Icons.style_rounded,
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
                                'Study sets',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              StatusBadge(
                                label: '${modules.length} main modules',
                                icon: Icons.view_module_rounded,
                                tone: BadgeTone.info,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                child: SectionHeader(
                  'Main modules',
                  action: StatusBadge(
                    label: '${modules.length} modules',
                    icon: Icons.layers_outlined,
                    tone: BadgeTone.neutral,
                  ),
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
                  return _FlashcardModuleCard(module: modules[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FlashcardModuleCard extends StatelessWidget {
  const _FlashcardModuleCard({required this.module});

  final Module module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: () => context.push('/flashcards/${module.id}'),
      semanticLabel: 'Open flashcard views for ${module.title}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: AppRadius.brMd,
                ),
                child: Icon(
                  moduleIcon(module.iconKey),
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.brSm,
                ),
                child: Text(
                  'Module ${module.order}',
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            module.title,
            style: theme.textTheme.titleSmall,
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
        ],
      ),
    );
  }
}
