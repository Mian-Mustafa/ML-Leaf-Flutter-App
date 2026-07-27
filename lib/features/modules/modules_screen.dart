import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_badge.dart';
import '../lessons/lesson_providers.dart';
import 'module.dart';
import 'module_icons.dart';
import 'module_providers.dart';

/// Module browsing (FR-04): browse all modules and see their contents and
/// completion status. Lesson counts and progress fill in with the content and
/// progress layers; module headlines are live now.
class ModulesScreen extends ConsumerWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(modulesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Modules')),
      body: modules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'Couldn\'t load modules',
          message: 'The learning modules could not be opened. Please try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(modulesProvider),
          tone: EmptyStateTone.error,
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateView(
              icon: Icons.grid_view_rounded,
              title: 'No modules yet',
              message: 'Learning modules will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: items.length + 1,
            separatorBuilder: (_, _) => AppSpacing.gapSm,
            itemBuilder: (context, i) {
              if (i == 0) return const _CatalogHeader();
              return _ModuleCard(module: items[i - 1]);
            },
          );
        },
      ),
    );
  }
}

/// Catalogue banner distinguishing the module list (the "shelf") from the
/// timeline path shown inside a module.
class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('Learning modules'),
          Text(
            'A guided path from foundations to core algorithms. '
            'Tap a module to open its lessons.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends ConsumerWidget {
  const _ModuleCard({required this.module});

  final Module module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lessonCount = ref.watch(lessonCountProvider(module.id));
    return AppCard(
      onTap: () => context.go('/modules/${module.id}'),
      semanticLabel: 'Open module ${module.title}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: AppRadius.brMd,
                ),
                child: Icon(moduleIcon(module.iconKey),
                    color: theme.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(module.title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      module.summary,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
          AppSpacing.gapMd,
          Row(
            children: [
              if (lessonCount != null && lessonCount > 0)
                StatusBadge(
                  label: '$lessonCount lessons',
                  icon: Icons.menu_book_outlined,
                  tone: BadgeTone.info,
                )
              else
                const StatusBadge(
                  label: 'Not started',
                  icon: Icons.radio_button_unchecked,
                ),
              const Spacer(),
              Text('Module ${module.order}',
                  style: theme.textTheme.labelMedium),
            ],
          ),
          if (lessonCount != null && lessonCount > 0) ...[
            AppSpacing.gapMd,
            const AppProgressBar(value: 0, showPercent: true),
          ],
        ],
      ),
    );
  }
}
