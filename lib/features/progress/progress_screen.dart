import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/brand_gradient.dart';
import '../../app/semantic_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/models/quiz_attempt_record.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/status_badge.dart';
import '../modules/module_icons.dart';
import '../quizzes/quiz_models.dart';
import 'progress_models.dart';
import 'progress_providers.dart';

/// Learning dashboard driven by persisted lesson completions and submitted
/// quiz levels. It deliberately shows latest quiz attempts for performance
/// accuracy, with a compact recent activity history below.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(studyDashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'Could not load your progress',
          message: 'Your local learning record is safe. Please try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(studyDashboardProvider),
          tone: EmptyStateTone.error,
        ),
        data: (data) => _ProgressDashboard(data: data),
      ),
    );
  }
}

class _ProgressDashboard extends StatelessWidget {
  const _ProgressDashboard({required this.data});

  final StudyDashboard data;

  @override
  Widget build(BuildContext context) {
    final hasActivity =
        data.completedLessons > 0 || data.attemptedQuizLevels > 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        _OverviewHero(data: data),
        const SizedBox(height: AppSpacing.lg),
        _MetricGrid(data: data),
        const SizedBox(height: AppSpacing.xl),
        _LearningBreakdown(data: data),
        const SizedBox(height: AppSpacing.xl),
        _ModuleProgressSection(data: data),
        const SizedBox(height: AppSpacing.xl),
        _RecentQuizActivity(attempts: data.recentQuizAttempts),
        if (!hasActivity) ...[
          const SizedBox(height: AppSpacing.xl),
          _GetStartedPanel(),
        ],
      ],
    );
  }
}

class _OverviewHero extends StatelessWidget {
  const _OverviewHero({required this.data});

  final StudyDashboard data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = data.completedLessons > 0 || data.attemptedQuizLevels > 0;
    final title = !isActive
        ? 'Your learning dashboard'
        : data.lessonCompletion >= 1
        ? 'Course lessons complete'
        : 'Keep your momentum';
    final message = !isActive
        ? 'Complete lessons and submit quiz levels to build a clear picture of your learning.'
        : '${data.completedLessons} of ${data.totalLessons} lessons complete across ${data.startedModules} modules.';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DonutChart(
            value: data.lessonCompletion,
            center: '${(data.lessonCompletion * 100).round()}%',
            label: 'Lessons',
            color: theme.colorScheme.primary,
            size: 106,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    StatusBadge(
                      label:
                          '${data.completedModules}/${data.modules.length} modules complete',
                      icon: Icons.layers_rounded,
                      tone: BadgeTone.info,
                    ),
                    if (data.attemptedQuizLevels > 0)
                      StatusBadge(
                        label:
                            '${(data.quizAccuracy * 100).round()}% quiz accuracy',
                        icon: Icons.workspace_premium_outlined,
                        tone: BadgeTone.success,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.data});

  final StudyDashboard data;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: wide ? 4 : 2,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: wide ? 1.65 : 1.38,
          children: [
            _MetricCard(
              value: '${data.completedLessons}/${data.totalLessons}',
              label: 'Lessons complete',
              icon: Icons.menu_book_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            _MetricCard(
              value: '${data.attemptedQuizLevels}/${data.totalQuizLevels}',
              label: 'Quiz levels attempted',
              icon: Icons.fact_check_rounded,
              color: semantic.info,
            ),
            _MetricCard(
              value: data.answeredQuizQuestions == 0
                  ? '-'
                  : '${(data.quizAccuracy * 100).round()}%',
              label: 'Latest quiz accuracy',
              icon: Icons.insights_rounded,
              color: semantic.success,
            ),
            _MetricCard(
              value: '${data.startedModules}/${data.modules.length}',
              label: 'Modules started',
              icon: Icons.explore_rounded,
              color: semantic.warning,
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 22, color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningBreakdown extends StatelessWidget {
  const _LearningBreakdown({required this.data});

  final StudyDashboard data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semantic;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart_outline_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text('Learning breakdown', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 480;
                final charts = [
                  _ChartMetric(
                    title: 'Lesson completion',
                    value: data.lessonCompletion,
                    center: '${data.completedLessons}/${data.totalLessons}',
                    caption: 'Lessons completed',
                    color: theme.colorScheme.primary,
                  ),
                  _ChartMetric(
                    title: 'Quiz coverage',
                    value: data.quizCoverage,
                    center:
                        '${data.attemptedQuizLevels}/${data.totalQuizLevels}',
                    caption: 'Levels attempted',
                    color: semantic.info,
                  ),
                  _ChartMetric(
                    title: 'Quiz accuracy',
                    value: data.quizAccuracy,
                    center: data.answeredQuizQuestions == 0
                        ? '-'
                        : '${(data.quizAccuracy * 100).round()}%',
                    caption: data.answeredQuizQuestions == 0
                        ? 'Submit a quiz to begin'
                        : '${data.correctQuizAnswers} correct / ${data.incorrectQuizAnswers} incorrect',
                    color: semantic.success,
                  ),
                ];

                if (wide) {
                  return Row(
                    children: [
                      Expanded(child: charts[0]),
                      _BreakdownDivider(vertical: true),
                      Expanded(child: charts[1]),
                      _BreakdownDivider(vertical: true),
                      Expanded(child: charts[2]),
                    ],
                  );
                }

                return Column(
                  children: [
                    charts[0],
                    const Divider(height: AppSpacing.xl),
                    charts[1],
                    const Divider(height: AppSpacing.xl),
                    charts[2],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownDivider extends StatelessWidget {
  const _BreakdownDivider({required this.vertical});

  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return vertical
        ? const SizedBox(
            height: 120,
            child: VerticalDivider(
              indent: AppSpacing.xs,
              endIndent: AppSpacing.xs,
            ),
          )
        : const Divider();
  }
}

class _ChartMetric extends StatelessWidget {
  const _ChartMetric({
    required this.title,
    required this.value,
    required this.center,
    required this.caption,
    required this.color,
  });

  final String title;
  final double value;
  final String center;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        _DonutChart(
          value: value,
          center: center,
          label: title,
          color: color,
          size: 104,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          caption,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ModuleProgressSection extends StatelessWidget {
  const _ModuleProgressSection({required this.data});

  final StudyDashboard data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.view_list_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.xs),
            Text('Module progress', style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Lesson completion and latest quiz levels in each module.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final module in data.modules) ...[
          _ModuleProgressCard(progress: module),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ModuleProgressCard extends StatelessWidget {
  const _ModuleProgressCard({required this.progress});

  final ModuleStudyProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semantic;
    final completed = progress.lessonCompletion >= 1;
    final accent = completed
        ? semantic.success
        : progress.isStarted
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/modules/${progress.module.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.13),
                      borderRadius: AppRadius.brMd,
                    ),
                    child: Icon(
                      moduleIcon(progress.module.iconKey),
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Module ${progress.module.order}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: accent,
                          ),
                        ),
                        Text(
                          progress.module.title,
                          style: theme.textTheme.titleSmall,
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
              const SizedBox(height: AppSpacing.md),
              AppProgressBar(
                value: progress.lessonCompletion,
                label:
                    '${progress.completedLessons}/${progress.totalLessons} lessons',
              ),
              const SizedBox(height: AppSpacing.sm),
              _ModuleQuizStatus(progress: progress),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleQuizStatus extends StatelessWidget {
  const _ModuleQuizStatus({required this.progress});

  final ModuleStudyProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attemptsByDifficulty = <String, QuizAttemptRecord>{
      for (final attempt in progress.quizAttempts)
        attempt.difficultyId: attempt,
    };

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final difficulty in QuizDifficulty.values)
          _LevelChip(
            difficulty: difficulty,
            attempt: attemptsByDifficulty[difficulty.id],
          ),
        if (progress.attemptedLevels == 0)
          Text(
            'No quiz levels submitted',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.difficulty, required this.attempt});

  final QuizDifficulty difficulty;
  final QuizAttemptRecord? attempt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semantic;
    final isAttempted = attempt != null;
    final accuracy = attempt?.accuracy ?? 0;
    final color = !isAttempted
        ? theme.colorScheme.onSurfaceVariant
        : accuracy >= 0.7
        ? semantic.success
        : semantic.warning;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isAttempted ? 0.13 : 0.08),
        borderRadius: AppRadius.brSm,
      ),
      child: Text(
        isAttempted
            ? '${difficulty.label} ${(accuracy * 100).round()}%'
            : '${difficulty.label} not attempted',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RecentQuizActivity extends StatelessWidget {
  const _RecentQuizActivity({required this.attempts});

  final List<QuizAttemptRecord> attempts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (attempts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Your submitted quiz levels will appear here.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.xs),
                Text('Recent quiz activity', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var index = 0; index < attempts.length; index++) ...[
              _AttemptRow(attempt: attempts[index]),
              if (index != attempts.length - 1) const Divider(),
            ],
          ],
        ),
      ),
    );
  }
}

class _AttemptRow extends StatelessWidget {
  const _AttemptRow({required this.attempt});

  final QuizAttemptRecord attempt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semantic;
    final highScore = attempt.accuracy >= 0.7;
    final color = highScore ? semantic.success : semantic.warning;
    final date = MaterialLocalizations.of(
      context,
    ).formatCompactDate(attempt.completedAt);

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: AppRadius.brMd,
          ),
          child: Icon(Icons.quiz_rounded, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Module ${_moduleNumber(attempt.moduleId)} - ${_difficultyLabel(attempt.difficultyId)}',
                style: theme.textTheme.labelLarge,
              ),
              Text(
                '$date | ${attempt.correct}/${attempt.total} correct',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${(attempt.accuracy * 100).round()}%',
          style: theme.textTheme.titleSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _GetStartedPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: AppRadius.brLg,
              ),
              child: Icon(
                Icons.rocket_launch_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start your record', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Open a module, complete a lesson, or attempt a quiz level.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Browse modules',
              onPressed: () => context.go('/modules'),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart({
    required this.value,
    required this.center,
    required this.label,
    required this.color,
    required this.size,
  });

  final double value;
  final String center;
  final String label;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (value.clamp(0.0, 1.0) * 100).round();
    return Semantics(
      label: '$label: $percent percent',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: _DonutPainter(
                value: value,
                color: color,
                trackColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            Text(
              center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.value,
    required this.color,
    required this.trackColor,
  });

  final double value;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = math.max(8.0, size.shortestSide * 0.11);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    paint.color = trackColor;
    canvas.drawCircle(center, radius, paint);

    final clamped = value.clamp(0.0, 1.0);
    if (clamped == 0) return;
    paint.color = color;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * clamped, false, paint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return value != oldDelegate.value ||
        color != oldDelegate.color ||
        trackColor != oldDelegate.trackColor;
  }
}

String _difficultyLabel(String difficultyId) {
  return QuizDifficulty.fromId(difficultyId)?.label ?? difficultyId;
}

String _moduleNumber(String moduleId) {
  const moduleNumbers = {
    'foundations': '1',
    'data_preprocessing': '2',
    'supervised_learning': '3',
    'regression': '4',
    'classification': '5',
    'unsupervised_learning': '6',
    'model_evaluation': '7',
    'feature_engineering': '8',
    'ensemble_methods': '9',
  };
  return moduleNumbers[moduleId] ?? moduleId;
}
