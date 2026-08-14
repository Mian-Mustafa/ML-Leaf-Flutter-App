import 'package:flutter_test/flutter_test.dart';
import 'package:mlleaf/features/interview/interview_data.dart';

void main() {
  test('interview tracks cover every course module with unique prompts', () {
    final prompts = InterviewData.tracks.expand((track) => track.questions);
    final promptList = prompts.toList();
    final coveredModuleIds = InterviewData.tracks
        .expand((track) => track.moduleIds)
        .toSet();

    expect(InterviewData.tracks, hasLength(5));
    expect(promptList, hasLength(30));
    expect(promptList.map((question) => question.id).toSet(), hasLength(30));
    expect(
      coveredModuleIds,
      containsAll(<String>{
        'foundations',
        'data_preprocessing',
        'supervised_learning',
        'regression',
        'classification',
        'unsupervised_learning',
        'model_evaluation',
        'feature_engineering',
        'ensemble_methods',
      }),
    );
    expect(InterviewData.mockInterview.questions, hasLength(10));
    expect(
      InterviewData.mockInterview.questions
          .map((question) => question.id)
          .toSet(),
      hasLength(10),
    );
    for (final question in promptList) {
      expect(question.focusPoints.length, greaterThanOrEqualTo(3));
      expect(question.suggestedAnswer, isNotEmpty);
      expect(question.followUp, isNotEmpty);
    }
  });
}
