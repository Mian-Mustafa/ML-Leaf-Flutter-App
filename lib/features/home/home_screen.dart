import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/brand_gradient.dart';
import '../../core/constants/app_info.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_badge.dart';
import '../progress/progress_providers.dart';

/// Home screen (FR-03): the best next study actions without overwhelming the
/// learner. The progress snapshot reflects lessons, quizzes, and interview
/// practice from the shared learner state.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const _HomeHeader(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: const Column(
                    children: [
                      _ContinueLearningCard(),
                      AppSpacing.gapMd,
                      _ProgressSnapshotCard(),
                      AppSpacing.gapXl,
                      SectionHeader('Study tools'),
                      _ToolsGrid(),
                    ],
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      pinned: true,
      expandedHeight: 148,
      actions: [
        IconButton(
          tooltip: 'Bookmarks',
          icon: const Icon(Icons.bookmark_outline_rounded),
          onPressed: () => context.push('/bookmarks'),
        ),
      ],
      title: const Text(AppInfo.appName),
      flexibleSpace: FlexibleSpaceBar(
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: BrandGradient.surface(theme.brightness),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                64,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back', style: theme.textTheme.bodySmall),
                  Text(
                    'Ready to grow your ML skills?',
                    style: theme.textTheme.titleMedium,
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

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Phase 1: no last-opened lesson yet, so we show the "start" state.
    return AppCard(
      onTap: () => context.go('/modules'),
      accentColor: theme.colorScheme.primary,
      semanticLabel: 'Start learning. Opens modules.',
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.play_arrow_rounded,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Start learning', style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  'Pick a module and open your first lesson.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _ProgressSnapshotCard extends ConsumerWidget {
  const _ProgressSnapshotCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dashboard = ref.watch(studyDashboardProvider).valueOrNull;
    final completion = dashboard?.combinedCompletion ?? 0;
    final isComplete = completion >= 1;
    final hasStarted = completion > 0;

    return AppCard(
      onTap: () => context.go('/progress'),
      semanticLabel:
          'Your progress: ${(completion * 100).round()} percent complete across modules, quizzes, and interviews. Opens the progress screen.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Your progress', style: theme.textTheme.titleSmall),
              const Spacer(),
              StatusBadge(
                label: isComplete
                    ? 'Complete'
                    : hasStarted
                    ? 'In progress'
                    : 'Just started',
                icon: isComplete
                    ? Icons.verified_rounded
                    : hasStarted
                    ? Icons.trending_up_rounded
                    : Icons.eco_rounded,
                tone: isComplete
                    ? BadgeTone.success
                    : hasStarted
                    ? BadgeTone.info
                    : BadgeTone.info,
              ),
            ],
          ),
          AppSpacing.gapMd,
          AppProgressBar(
            value: completion,
            label: 'Modules, quizzes & interviews',
          ),
        ],
      ),
    );
  }
}

class _ToolsGrid extends StatelessWidget {
  const _ToolsGrid();

  @override
  Widget build(BuildContext context) {
    const tools = [
      (_ToolTile(
        label: 'Modules',
        icon: Icons.grid_view_rounded,
        route: '/modules',
        go: true,
      )),
      (_ToolTile(
        label: 'Quizzes',
        icon: Icons.quiz_outlined,
        route: '/quizzes',
      )),
      (_ToolTile(
        label: 'Flashcards',
        icon: Icons.style_outlined,
        route: '/flashcards',
      )),
      (_ToolTile(
        label: 'Interview',
        icon: Icons.work_outline_rounded,
        route: '/interview',
      )),
      (_ToolTile(
        label: 'Search',
        icon: Icons.search_rounded,
        route: '/search',
        go: true,
      )),
      (_ToolTile(
        label: 'Progress',
        icon: Icons.insights_rounded,
        route: '/progress',
        go: true,
      )),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1060
            ? 4
            : width >= 700
            ? 3
            : 2;
        final childAspectRatio = width >= 1060
            ? 3.1
            : width >= 700
            ? 2.6
            : 2.4;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: childAspectRatio,
          children: tools,
        );
      },
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.label,
    required this.icon,
    required this.route,
    this.go = false,
  });

  final String label;
  final IconData icon;
  final String route;

  /// Whether the destination is a bottom-nav branch (`go`) or a pushed
  /// full-screen route (`push`).
  final bool go;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      semanticLabel: 'Open $label',
      onTap: () => go ? context.go(route) : context.push(route),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    );
  }
}
