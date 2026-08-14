class InterviewQuestion {
  const InterviewQuestion({
    required this.id,
    required this.prompt,
    required this.moduleIds,
    required this.focusPoints,
    required this.suggestedAnswer,
    required this.followUp,
  });

  final String id;
  final String prompt;
  final List<String> moduleIds;
  final List<String> focusPoints;
  final String suggestedAnswer;
  final String followUp;
}

class InterviewTrack {
  const InterviewTrack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.moduleIds,
    required this.questions,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<String> moduleIds;
  final List<InterviewQuestion> questions;
}
