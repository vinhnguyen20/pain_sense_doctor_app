import 'package:app_doctor/features/survey/data/models/survey_definition_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses and orders survey questions and options from the API', () {
    final survey = SurveyDefinitionModel.fromJson({
      'id': 'survey-id',
      'title': 'Back Pain Assessment',
      'questions': [
        {
          'id': 'question-id',
          'type': 'checkbox',
          'title': 'How severe is your pain?',
          'is_required': true,
          'options': [
            {'id': 'option-2', 'content': 'High', 'position_display': 2},
            {'id': 'option-1', 'content': 'Low', 'position_display': 1},
          ],
        },
      ],
    });

    expect(survey.id, 'survey-id');
    expect(survey.questions.single.id, 'question-id');
    expect(survey.questions.single.isRequired, isTrue);
    expect(survey.questions.single.options.map((option) => option.id), [
      'option-1',
      'option-2',
    ]);
  });

  test('serializes selected option ids using user-survey schema', () {
    const response = UserSurveyResponseModel(
      questionId: 'question-id',
      selectedOptionIds: ['option-id'],
    );

    expect(response.toJson(), {
      'question_id': 'question-id',
      'selected_option_ids': ['option-id'],
    });
  });
}
