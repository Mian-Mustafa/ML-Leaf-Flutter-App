import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/semantic_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/empty_state_view.dart';
import '../progress/progress_providers.dart';
import 'quiz_models.dart';
import 'quiz_providers.dart';

/// Full assessment and reviewed-result view for one main module quiz bank.
/// Correct options are not used by the UI until the learner submits.
class QuizAssessmentScreen extends ConsumerStatefulWidget {
  const QuizAssessmentScreen({
    super.key,
    required this.moduleId,
    required this.startingLevelId,
  });

  final String moduleId;
  final String startingLevelId;

  @override
  ConsumerState<QuizAssessmentScreen> createState() =>
      _QuizAssessmentScreenState();
}

class _QuizAssessmentScreenState extends ConsumerState<QuizAssessmentScreen> {
  final Map<String, int> _answers = {};
  LevelQuizResult? _result;

  void _selectAnswer(QuizQuestion question, int optionIndex) {
    if (_result != null) return;
    setState(() => _answers[question.id] = optionIndex);
  }

  Future<void> _submit(QuizBank bank, QuizDifficulty difficulty) async {
    final questions = bank.questionsFor(difficulty);
    final unanswered = questions.length - _answers.length;
    if (unanswered > 0) return;

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Submit ${difficulty.label} quiz?'),
        content: Text(
          'Your ${difficulty.label.toLowerCase()} answers will be scored and '
          'the review will become available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue answering'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (shouldSubmit != true || !mounted) return;

    final result = LevelQuizResult.evaluate(
      difficulty: difficulty,
      questions: questions,
      answers: _answers,
    );
    await ref
        .read(studyProgressProvider.notifier)
        .recordQuizAttempt(moduleId: widget.moduleId, result: result);
    if (!mounted) return;
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final quizBank = ref.watch(quizBankProvider(widget.moduleId));

    return quizBank.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: const Text('Assessment')),
        body: EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'Couldn\'t load assessment',
          message: 'The question bank could not be opened. Please try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(quizBankProvider(widget.moduleId)),
          tone: EmptyStateTone.error,
        ),
      ),
      data: (bank) {
        if (bank == null) return const _QuizUnavailableScreen();
        final difficulty =
            QuizDifficulty.fromId(widget.startingLevelId) ??
            QuizDifficulty.easy;
        return _AssessmentShell(
          bank: bank,
          difficulty: difficulty,
          questions: bank.questionsFor(difficulty),
          answers: _answers,
          result: _result,
          onSelectAnswer: _selectAnswer,
          onSubmit: () => _submit(bank, difficulty),
        );
      },
    );
  }
}

class _AssessmentShell extends StatelessWidget {
  const _AssessmentShell({
    required this.bank,
    required this.difficulty,
    required this.questions,
    required this.answers,
    required this.result,
    required this.onSelectAnswer,
    required this.onSubmit,
  });

  final QuizBank bank;
  final QuizDifficulty difficulty;
  final List<QuizQuestion> questions;
  final Map<String, int> answers;
  final LevelQuizResult? result;
  final void Function(QuizQuestion question, int optionIndex) onSelectAnswer;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final questionCount = questions.length;
    final answeredCount = answers.length;
    final remainingCount = questionCount - answeredCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${bank.title} - ${difficulty.label} quiz',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          _AssessmentStatus(
            difficulty: difficulty,
            answeredCount: answeredCount,
            totalCount: questionCount,
            result: result,
          ),
          Expanded(
            child: _QuizSection(
              difficulty: difficulty,
              questions: questions,
              answers: answers,
              result: result,
              onSelectAnswer: onSelectAnswer,
            ),
          ),
        ],
      ),
      bottomNavigationBar: result == null
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: FilledButton.icon(
                onPressed: remainingCount == 0 ? onSubmit : null,
                icon: const Icon(Icons.assignment_turned_in_outlined),
                label: Text(
                  remainingCount == 0
                      ? 'Submit ${difficulty.label} quiz'
                      : 'Answer $remainingCount more to submit',
                ),
              ),
            )
          : null,
    );
  }
}

class _AssessmentStatus extends StatelessWidget {
  const _AssessmentStatus({
    required this.difficulty,
    required this.answeredCount,
    required this.totalCount,
    required this.result,
  });

  final QuizDifficulty difficulty;
  final int answeredCount;
  final int totalCount;
  final LevelQuizResult? result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semantic;
    final completed = result != null;
    final label = completed
        ? '${difficulty.label} quiz submitted'
        : '${difficulty.label}: $answeredCount of $totalCount answers selected';
    final icon = completed ? Icons.fact_check_rounded : Icons.edit_note_rounded;
    final foreground = completed
        ? semantic.onSuccessContainer
        : theme.colorScheme.onPrimaryContainer;
    final background = completed
        ? semantic.successContainer
        : theme.colorScheme.primaryContainer;

    return Container(
      width: double.infinity,
      color: background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(color: foreground),
            ),
          ),
          if (completed)
            Text(
              'Review mode',
              style: theme.textTheme.labelMedium?.copyWith(color: foreground),
            ),
        ],
      ),
    );
  }
}

class _QuizSection extends StatelessWidget {
  const _QuizSection({
    required this.difficulty,
    required this.questions,
    required this.answers,
    required this.result,
    required this.onSelectAnswer,
  });

  final QuizDifficulty difficulty;
  final List<QuizQuestion> questions;
  final Map<String, int> answers;
  final LevelQuizResult? result;
  final void Function(QuizQuestion question, int optionIndex) onSelectAnswer;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xxxl,
      ),
      itemCount: questions.length + (result == null ? 0 : 1),
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (index < questions.length) {
          final question = questions[index];
          return _QuestionCard(
            difficulty: difficulty,
            question: question,
            selectedOption: answers[question.id],
            result: result,
            onSelectAnswer: onSelectAnswer,
          );
        }

        return _LevelScoreSummary(difficulty: difficulty, score: result!.score);
      },
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.difficulty,
    required this.question,
    required this.selectedOption,
    required this.result,
    required this.onSelectAnswer,
  });

  final QuizDifficulty difficulty;
  final QuizQuestion question;
  final int? selectedOption;
  final LevelQuizResult? result;
  final void Function(QuizQuestion question, int optionIndex) onSelectAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final submitted = result != null;
    final isCorrect = submitted && result!.isCorrect(question);
    final reviewColor = !submitted
        ? theme.colorScheme.outlineVariant
        : isCorrect
        ? context.semantic.success
        : theme.colorScheme.error;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.brSm,
        border: Border.all(
          color: reviewColor.withValues(alpha: submitted ? 0.7 : 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
                    'Q${question.number.toString().padLeft(3, '0')}',
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  difficulty.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (submitted)
                  _ReviewLabel(correct: isCorrect, color: reviewColor),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(question.prompt, style: theme.textTheme.titleSmall),
            if (question.figureAsset case final figureAsset?) ...[
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: AppRadius.brSm,
                child: Image.asset(
                  figureAsset,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  semanticLabel: 'Figure for question ${question.number}',
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            for (var index = 0; index < question.options.length; index++) ...[
              _AnswerOption(
                label: String.fromCharCode(65 + index),
                text: question.options[index],
                optionIndex: index,
                selectedOption: selectedOption,
                question: question,
                result: result,
                onSelect: () => onSelectAnswer(question, index),
              ),
              if (index != question.options.length - 1)
                const SizedBox(height: AppSpacing.xs),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewLabel extends StatelessWidget {
  const _ReviewLabel({required this.correct, required this.color});

  final bool correct;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: AppSizes.iconSm,
          color: color,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          correct ? 'Correct' : 'Incorrect',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.label,
    required this.text,
    required this.optionIndex,
    required this.selectedOption,
    required this.question,
    required this.result,
    required this.onSelect,
  });

  final String label;
  final String text;
  final int optionIndex;
  final int? selectedOption;
  final QuizQuestion question;
  final LevelQuizResult? result;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final submitted = result != null;
    final isSelected = selectedOption == optionIndex;
    final isCorrectOption = question.correctOption == optionIndex;
    final isCorrectAnswer = submitted && result!.isCorrect(question);

    final _OptionReviewState state;
    if (!submitted) {
      state = _OptionReviewState.neutral;
    } else if (isCorrectAnswer && isSelected) {
      state = _OptionReviewState.correct;
    } else if (isSelected && !isCorrectOption) {
      state = _OptionReviewState.incorrect;
    } else if (isCorrectOption) {
      state = _OptionReviewState.answerKey;
    } else {
      state = _OptionReviewState.neutral;
    }

    final palette = _optionPalette(context, state, isSelected);
    final icon = switch (state) {
      _OptionReviewState.correct => Icons.check_circle_rounded,
      _OptionReviewState.incorrect => Icons.cancel_rounded,
      _OptionReviewState.answerKey => Icons.verified_rounded,
      _OptionReviewState.neutral =>
        isSelected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_off_rounded,
    };
    final reviewLabel = switch (state) {
      _OptionReviewState.correct => 'Selected correctly',
      _OptionReviewState.incorrect => 'Selected answer is incorrect',
      _OptionReviewState.answerKey => 'Correct answer',
      _OptionReviewState.neutral => null,
    };

    return Semantics(
      button: !submitted,
      selected: isSelected,
      label:
          'Option $label: $text${reviewLabel == null ? '' : '. $reviewLabel'}',
      child: Material(
        color: palette.background,
        borderRadius: AppRadius.brSm,
        child: InkWell(
          onTap: submitted ? null : onSelect,
          borderRadius: AppRadius.brSm,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: AppRadius.brSm,
              border: Border.all(color: palette.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: AppSizes.iconSm, color: palette.foreground),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    '$label. $text',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.foreground,
                      fontWeight: state == _OptionReviewState.neutral
                          ? null
                          : FontWeight.w600,
                    ),
                  ),
                ),
                if (reviewLabel != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    reviewLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: palette.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _OptionReviewState { neutral, correct, incorrect, answerKey }

class _OptionPalette {
  const _OptionPalette({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;
}

_OptionPalette _optionPalette(
  BuildContext context,
  _OptionReviewState state,
  bool selected,
) {
  final theme = Theme.of(context);
  final semantic = context.semantic;
  final neutralBackground = selected
      ? theme.colorScheme.surfaceContainerHighest
      : theme.colorScheme.surface;
  final neutralForeground = theme.colorScheme.onSurface;

  return switch (state) {
    _OptionReviewState.neutral => _OptionPalette(
      background: neutralBackground,
      border: theme.colorScheme.outlineVariant,
      foreground: neutralForeground,
    ),
    _OptionReviewState.correct => _OptionPalette(
      background: semantic.successContainer,
      border: semantic.success,
      foreground: semantic.onSuccessContainer,
    ),
    _OptionReviewState.incorrect => _OptionPalette(
      background: theme.colorScheme.errorContainer,
      border: theme.colorScheme.error,
      foreground: theme.colorScheme.onErrorContainer,
    ),
    _OptionReviewState.answerKey => _OptionPalette(
      background: Color.alphaBlend(
        const Color(0xFF1967D2).withValues(alpha: 0.18),
        theme.colorScheme.surface,
      ),
      border: const Color(0xFF1967D2),
      foreground: const Color(0xFF1552A1),
    ),
  };
}

class _LevelScoreSummary extends StatelessWidget {
  const _LevelScoreSummary({required this.difficulty, required this.score});

  final QuizDifficulty difficulty;
  final QuizScore score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semantic;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: semantic.successContainer,
        borderRadius: AppRadius.brSm,
        border: Border.all(color: semantic.success.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(Icons.assignment_turned_in_rounded, color: semantic.success),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${difficulty.label} Score: ${score.correct}/${score.total}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: semantic.onSuccessContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${score.correct} correct | ${score.incorrect} incorrect',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: semantic.onSuccessContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizUnavailableScreen extends StatelessWidget {
  const _QuizUnavailableScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assessment')),
      body: const EmptyStateView(
        icon: Icons.quiz_outlined,
        title: 'Assessment coming soon',
        message: 'Questions for this module have not been added yet.',
      ),
    );
  }
}
