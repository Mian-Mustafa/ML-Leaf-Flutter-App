import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/brand_gradient.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_badge.dart';
import '../modules/module.dart';
import '../modules/module_icons.dart';
import '../modules/module_providers.dart';
import 'interview_data.dart';
import 'interview_models.dart';

class InterviewScreen extends ConsumerWidget {
  const InterviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(modulesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Interview prep')),
      body: modules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'Couldn\'t load interview tracks',
          message: 'The course module catalogue could not be opened.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(modulesProvider),
          tone: EmptyStateTone.error,
        ),
        data: (items) => _InterviewHub(modules: items),
      ),
    );
  }
}

class _InterviewHub extends StatelessWidget {
  const _InterviewHub({required this.modules});

  final List<Module> modules;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final questionCount = InterviewData.tracks.fold<int>(
      0,
      (count, track) => count + track.questions.length,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 800
            ? AppSpacing.xl
            : AppSpacing.md;
        final crossAxisCount = constraints.maxWidth >= 1100
            ? 3
            : constraints.maxWidth >= 700
            ? 2
            : 1;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: BrandGradient.surface(theme.brightness),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.16),
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.xl,
                    horizontalPadding,
                    AppSpacing.lg,
                  ),
                  child: _InterviewHero(
                    moduleCount: modules.length,
                    questionCount: questionCount,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppSpacing.xl,
                horizontalPadding,
                AppSpacing.sm,
              ),
              sliver: const SliverToBoxAdapter(
                child: SectionHeader('Practice tracks'),
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
                  mainAxisExtent: 220,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                ),
                itemCount: InterviewData.tracks.length,
                itemBuilder: (context, index) => _InterviewTrackCard(
                  track: InterviewData.tracks[index],
                  modules: modules,
                  accent: _trackAccents[index],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InterviewHero extends StatelessWidget {
  const _InterviewHero({
    required this.moduleCount,
    required this.questionCount,
  });

  final int moduleCount;
  final int questionCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: AppRadius.brMd,
              ),
              child: Icon(
                Icons.record_voice_over_outlined,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Machine Learning interview',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Build concise, technically sound answers across the ML curriculum.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.gapLg,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            StatusBadge(
              label: '$moduleCount modules',
              icon: Icons.layers_outlined,
              tone: BadgeTone.info,
            ),
            StatusBadge(
              label: '$questionCount practice prompts',
              icon: Icons.forum_outlined,
              tone: BadgeTone.neutral,
            ),
            const StatusBadge(
              label: '10-question mock',
              icon: Icons.timer_outlined,
              tone: BadgeTone.warning,
            ),
          ],
        ),
        AppSpacing.gapLg,
        FilledButton.icon(
          onPressed: () => context.push('/interview/mock'),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start mock interview'),
        ),
      ],
    );
  }
}

class _InterviewTrackCard extends StatelessWidget {
  const _InterviewTrackCard({
    required this.track,
    required this.modules,
    required this.accent,
  });

  final InterviewTrack track;
  final List<Module> modules;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface =
        Color.lerp(
          theme.colorScheme.surface,
          accent,
          theme.brightness == Brightness.dark ? 0.17 : 0.055,
        ) ??
        theme.colorScheme.surface;
    final coveredModules = modules
        .where((module) => track.moduleIds.contains(module.id))
        .toList(growable: false);

    return Semantics(
      button: true,
      label: 'Open ${track.title} interview practice',
      child: Material(
        color: surface,
        borderRadius: AppRadius.brSm,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/interview/${track.id}'),
          borderRadius: AppRadius.brSm,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.brSm,
              border: Border.all(color: accent.withValues(alpha: 0.42)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          borderRadius: AppRadius.brSm,
                        ),
                        child: Icon(_trackIcon(track.id), color: accent),
                      ),
                      const Spacer(),
                      Text(
                        '${track.questions.length} prompts',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(track.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    track.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: coveredModules
                        .map(
                          (module) => Tooltip(
                            message: module.title,
                            child: Icon(
                              moduleIcon(module.iconKey),
                              size: AppSizes.iconSm,
                              color: accent,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline_rounded,
                        size: AppSizes.iconSm,
                        color: accent,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        'Start practice',
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
          ),
        ),
      ),
    );
  }
}

const _trackAccents = <Color>[
  Color(0xFF18776F),
  Color(0xFF2466A3),
  Color(0xFF6357A6),
  Color(0xFFC4621E),
  Color(0xFFC2376B),
];

IconData _trackIcon(String id) {
  return switch (id) {
    'foundations' => Icons.school_outlined,
    'data-readiness' => Icons.dataset_outlined,
    'model-selection' => Icons.account_tree_outlined,
    'evaluation' => Icons.fact_check_outlined,
    'ensembles' => Icons.hub_outlined,
    _ => Icons.work_outline_rounded,
  };
}
