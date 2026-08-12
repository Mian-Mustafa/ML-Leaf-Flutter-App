import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlleaf/features/quizzes/quiz_models.dart';
import 'package:mlleaf/features/quizzes/quiz_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final moduleId in [
    'foundations',
    'data_preprocessing',
    'supervised_learning',
    'regression',
    'classification',
    'unsupervised_learning',
    'model_evaluation',
    'feature_engineering',
    'ensemble_methods',
  ]) {
    test('$moduleId has 30 easy, 30 medium and 40 hard MCQs', () async {
      final bank = await QuizRepository(
        loader: rootBundle.loadString,
      ).loadForModule(moduleId);

      expect(bank, isNotNull);
      expect(bank!.questionsFor(QuizDifficulty.easy), hasLength(30));
      expect(bank.questionsFor(QuizDifficulty.medium), hasLength(30));
      expect(bank.questionsFor(QuizDifficulty.hard), hasLength(40));
      expect(bank.allQuestions, hasLength(100));
      expect(
        bank.allQuestions.map((question) => question.id).toSet(),
        hasLength(100),
      );
      expect(
        bank.allQuestions.map((question) => question.prompt).toSet(),
        hasLength(100),
      );
      for (final question in bank.allQuestions) {
        expect(question.options, hasLength(4));
        expect(question.correctOption, inInclusiveRange(0, 3));
      }

      if (moduleId == 'supervised_learning') {
        expect(
          bank.allQuestions.where((question) => question.figureAsset != null),
          hasLength(9),
        );
      }
      if (moduleId == 'regression') {
        expect(
          bank.allQuestions.where((question) => question.figureAsset != null),
          hasLength(9),
        );
      }
      if (moduleId == 'classification') {
        expect(
          bank.allQuestions.where((question) => question.figureAsset != null),
          hasLength(12),
        );
      }
      if (moduleId == 'unsupervised_learning') {
        expect(
          bank.allQuestions.where((question) => question.figureAsset != null),
          hasLength(10),
        );
      }
      if (moduleId == 'model_evaluation') {
        expect(
          bank.allQuestions.where((question) => question.figureAsset != null),
          hasLength(10),
        );
      }
      if (moduleId == 'feature_engineering') {
        expect(
          bank.allQuestions.where((question) => question.figureAsset != null),
          hasLength(9),
        );
      }
      if (moduleId == 'ensemble_methods') {
        expect(
          bank.allQuestions.where((question) => question.figureAsset != null),
          hasLength(10),
        );
      }
    });
  }

  for (final moduleId in [
    'foundations',
    'data_preprocessing',
    'supervised_learning',
    'regression',
    'classification',
    'unsupervised_learning',
    'model_evaluation',
    'feature_engineering',
    'ensemble_methods',
  ]) {
    test('$moduleId difficulty levels are scored independently', () async {
      final path = 'assets/content/quizzes/$moduleId.json';
      final raw = await rootBundle.loadString(path);
      final bank = QuizBank.fromJson(
        json.decode(raw) as Map<String, dynamic>,
        path,
      );
      for (final difficulty in QuizDifficulty.values) {
        final questions = bank.questionsFor(difficulty);
        final answers = <String, int>{
          for (final question in questions) question.id: question.correctOption,
        };
        final result = LevelQuizResult.evaluate(
          difficulty: difficulty,
          questions: questions,
          answers: answers,
        );

        expect(result.difficulty, difficulty);
        expect(result.score.correct, questions.length);
        expect(result.score.incorrect, 0);
      }
    });
  }
}
