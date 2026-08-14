import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/semantic_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/status_badge.dart';
import '../progress/progress_providers.dart';
import 'interview_data.dart';
import 'interview_models.dart';

class InterviewPracticeScreen extends ConsumerStatefulWidget {
  const InterviewPracticeScreen({
    super.key,
    required this.trackId,
    this.initialQuestionIndex = 0,
  });

  final String trackId;
  final int initialQuestionIndex;

  @override
  ConsumerState<InterviewPracticeScreen> createState() =>
      _InterviewPracticeScreenState();
}

class _InterviewPracticeScreenState
    extends ConsumerState<InterviewPracticeScreen> {
  late final InterviewTrack _track;
  late final Stopwatch _stopwatch;
  Timer? _ticker;
  final _responses = <String, String>{};
  final _revealedAnswers = <String>{};
  var _questionIndex = 0;
  var _completed = false;

  InterviewQuestion get _question => _track.questions[_questionIndex];

  @override
  void initState() {
    super.initState();
    _track =
        InterviewData.trackForId(widget.trackId) ?? InterviewData.mockInterview;
    _questionIndex = widget.initialQuestionIndex.clamp(
      0,
      _track.questions.length - 1,
    );
    _stopwatch = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _goToQuestion(int index) {
    setState(() => _questionIndex = index);
  }

  void _finishRound() {
    setState(() {
      _completed = true;
      _stopwatch.stop();
    });
    unawaited(
      ref
          .read(studyProgressProvider.notifier)
          .markInterviewTrackComplete(_track.id),
    );
  }

  void _restartRound() {
    setState(() {
      _questionIndex = 0;
      _completed = false;
      _responses.clear();
      _revealedAnswers.clear();
      _stopwatch
        ..reset()
        ..start();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return _InterviewRoundComplete(
        track: _track,
        elapsed: _formatDuration(_stopwatch.elapsed),
        responseCount: _responses.values
            .where((value) => value.trim().isNotEmpty)
            .length,
        reviewedCount: _revealedAnswers.length,
        onRestart: _restartRound,
      );
    }

    final theme = Theme.of(context);
    final progress = (_questionIndex + 1) / _track.questions.length;
    final reviewed = _revealedAnswers.contains(_question.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(_track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Center(
              child: StatusBadge(
                label: _formatDuration(_stopwatch.elapsed),
                icon: Icons.timer_outlined,
                tone: BadgeTone.neutral,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 800
                ? AppSpacing.xxl
                : AppSpacing.md;
            final contentWidth = constraints.maxWidth >= 1000
                ? 760.0
                : double.infinity;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        AppSpacing.sm,
                        horizontalPadding,
                        AppSpacing.xxxl,
                      ),
                      sliver: SliverList.list(
                        children: [
                          _RoundProgress(
                            current: _questionIndex + 1,
                            total: _track.questions.length,
                            progress: progress,
                          ),
                          AppSpacing.gapLg,
                          _QuestionPrompt(
                            question: _question,
                            questionNumber: _questionIndex + 1,
                          ),
                          AppSpacing.gapLg,
                          Text(
                            'Your response',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            key: ValueKey(_question.id),
                            initialValue: _responses[_question.id],
                            minLines: 5,
                            maxLines: 8,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              hintText: 'Write the key points you would say...',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                _responses[_question.id] = value,
                          ),
                          AppSpacing.gapMd,
                          OutlinedButton.icon(
                            onPressed: () => setState(
                              () => _revealedAnswers.add(_question.id),
                            ),
                            icon: Icon(
                              reviewed
                                  ? Icons.visibility_rounded
                                  : Icons.lightbulb_outline_rounded,
                            ),
                            label: Text(
                              reviewed
                                  ? 'Answer framework reviewed'
                                  : 'Reveal answer framework',
                            ),
                          ),
                          if (reviewed) ...[
                            AppSpacing.gapMd,
                            _AnswerFramework(question: _question),
                          ],
                          AppSpacing.gapXl,
                          _QuestionNavigation(
                            canGoBack: _questionIndex > 0,
                            isLast:
                                _questionIndex == _track.questions.length - 1,
                            onBack: () => _goToQuestion(_questionIndex - 1),
                            onNext: () => _goToQuestion(_questionIndex + 1),
                            onFinish: _finishRound,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoundProgress extends StatelessWidget {
  const _RoundProgress({
    required this.current,
    required this.total,
    required this.progress,
  });

  final int current;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Question $current of $total',
              style: theme.textTheme.titleSmall,
            ),
            const Spacer(),
            Text(
              '${(progress * 100).round()}%',
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        AppProgressBar(value: progress, showPercent: false),
      ],
    );
  }
}

class _QuestionPrompt extends StatelessWidget {
  const _QuestionPrompt({required this.question, required this.questionNumber});

  final InterviewQuestion question;
  final int questionNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: AppRadius.brMd,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: AppRadius.brSm,
                  ),
                  child: Text(
                    questionNumber.toString().padLeft(2, '0'),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('Interview prompt', style: theme.textTheme.labelMedium),
              ],
            ),
            AppSpacing.gapMd,
            Text(
              question.prompt,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            AppSpacing.gapMd,
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: question.focusPoints
                  .map(
                    (point) => StatusBadge(
                      label: point,
                      icon: Icons.check_circle_outline_rounded,
                      tone: BadgeTone.info,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerFramework extends StatelessWidget {
  const _AnswerFramework({required this.question});

  final InterviewQuestion question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semantic;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: semantic.successContainer,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: semantic.success.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fact_check_outlined, color: semantic.success),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Strong answer framework',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: semantic.onSuccessContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              question.suggestedAnswer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: semantic.onSuccessContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Follow-up: ${question.followUp}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: semantic.onSuccessContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionNavigation extends StatelessWidget {
  const _QuestionNavigation({
    required this.canGoBack,
    required this.isLast,
    required this.onBack,
    required this.onNext,
    required this.onFinish,
  });

  final bool canGoBack;
  final bool isLast;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: canGoBack ? onBack : null,
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Previous'),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: isLast ? onFinish : onNext,
          icon: Icon(
            isLast
                ? Icons.assignment_turned_in_rounded
                : Icons.arrow_forward_rounded,
          ),
          label: Text(isLast ? 'Finish round' : 'Next question'),
        ),
      ],
    );
  }
}

class _InterviewRoundComplete extends StatelessWidget {
  const _InterviewRoundComplete({
    required this.track,
    required this.elapsed,
    required this.responseCount,
    required this.reviewedCount,
    required this.onRestart,
  });

  final InterviewTrack track;
  final String elapsed;
  final int responseCount;
  final int reviewedCount;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semantic;
    return Scaffold(
      appBar: AppBar(title: const Text('Interview round complete')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppRadius.brLg,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.65,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: semantic.successContainer,
                        borderRadius: AppRadius.brMd,
                      ),
                      child: Icon(
                        Icons.verified_rounded,
                        color: semantic.success,
                      ),
                    ),
                    AppSpacing.gapLg,
                    Text(track.title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Round complete',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    AppSpacing.gapLg,
                    _SessionMetric(
                      icon: Icons.edit_note_rounded,
                      label: 'Responses drafted',
                      value: '$responseCount / ${track.questions.length}',
                    ),
                    _SessionMetric(
                      icon: Icons.fact_check_outlined,
                      label: 'Frameworks reviewed',
                      value: '$reviewedCount / ${track.questions.length}',
                    ),
                    _SessionMetric(
                      icon: Icons.timer_outlined,
                      label: 'Practice time',
                      value: elapsed,
                    ),
                    AppSpacing.gapLg,
                    FilledButton.icon(
                      onPressed: onRestart,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Practise again'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton.icon(
                      onPressed: () => context.go('/interview'),
                      icon: const Icon(Icons.work_outline_rounded),
                      label: const Text('Back to interview prep'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionMetric extends StatelessWidget {
  const _SessionMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconMd, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
