class SurveyDefinitionModel {
  final String id;
  final String title;
  final String? description;
  final List<SurveyQuestionModel> questions;

  const SurveyDefinitionModel({
    required this.id,
    required this.title,
    this.description,
    required this.questions,
  });

  factory SurveyDefinitionModel.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'];
    return SurveyDefinitionModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      questions: rawQuestions is List
          ? rawQuestions
                .whereType<Map>()
                .map(
                  (item) => SurveyQuestionModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class SurveyQuestionModel {
  final String id;
  final String type;
  final String title;
  final bool isRequired;
  final List<SurveyOptionModel> options;

  const SurveyQuestionModel({
    required this.id,
    required this.type,
    required this.title,
    required this.isRequired,
    required this.options,
  });

  factory SurveyQuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final options = rawOptions is List
        ? rawOptions
              .whereType<Map>()
              .map(
                (item) =>
                    SurveyOptionModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <SurveyOptionModel>[];
    options.sort((a, b) => a.positionDisplay.compareTo(b.positionDisplay));

    return SurveyQuestionModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      isRequired: json['is_required'] == true,
      options: options,
    );
  }
}

class SurveyOptionModel {
  final String id;
  final String content;
  final int positionDisplay;

  const SurveyOptionModel({
    required this.id,
    required this.content,
    required this.positionDisplay,
  });

  factory SurveyOptionModel.fromJson(Map<String, dynamic> json) {
    final rawPosition = json['position_display'];
    return SurveyOptionModel(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      positionDisplay: rawPosition is num
          ? rawPosition.toInt()
          : int.tryParse(rawPosition?.toString() ?? '') ?? 0,
    );
  }
}

class UserSurveyResponseModel {
  final String questionId;
  final List<String> selectedOptionIds;

  const UserSurveyResponseModel({
    required this.questionId,
    required this.selectedOptionIds,
  });

  Map<String, dynamic> toJson() => {
    'question_id': questionId,
    'selected_option_ids': selectedOptionIds,
  };
}
