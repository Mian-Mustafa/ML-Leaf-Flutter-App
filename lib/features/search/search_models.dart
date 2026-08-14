import 'package:flutter/material.dart';

enum SearchFilter {
  all('All content', Icons.search_rounded),
  lessons('Lessons', Icons.menu_book_outlined),
  modules('Modules', Icons.layers_outlined),
  quizzes('Quizzes', Icons.quiz_outlined),
  interview('Interview', Icons.record_voice_over_outlined);

  const SearchFilter(this.label, this.icon);

  final String label;
  final IconData icon;
}

enum SearchResultType {
  module('Module', Icons.layers_outlined),
  lesson('Lesson', Icons.menu_book_outlined),
  quiz('Quiz question', Icons.quiz_outlined),
  interview('Interview prompt', Icons.record_voice_over_outlined);

  const SearchResultType(this.label, this.icon);

  final String label;
  final IconData icon;
}

class StudySearchResult {
  const StudySearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.excerpt,
    required this.moduleId,
    this.lessonId,
    this.difficultyId,
    this.trackId,
    this.questionIndex,
  });

  final SearchResultType type;
  final String title;
  final String subtitle;
  final String excerpt;
  final String moduleId;
  final String? lessonId;
  final String? difficultyId;
  final String? trackId;
  final int? questionIndex;
}
