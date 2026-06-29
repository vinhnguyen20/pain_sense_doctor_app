import 'package:app_doctor/core/utils/entity_convertible.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:app_doctor/features/education/domain/entites/exercise_review.dart';

part 'exercise_review_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ExerciseReviewModel extends ExerciseReview
    with EntityConvertible<ExerciseReviewModel, ExerciseReview> {
  @override
  @JsonKey(name: 'id')
  final String id;

  @override
  @JsonKey(name: 'exercise_id')
  final String exerciseId;

  @override
  @JsonKey(name: 'user_id')
  final String userId;

  @override
  @JsonKey(name: 'seen_at')
  final DateTime seenAt;

  @override
  @JsonKey(name: 'rating_star')
  final int? ratingStar;

  @override
  @JsonKey(name: 'comment')
  final String? comment;

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const ExerciseReviewModel({
    required this.id,
    required this.exerciseId,
    required this.userId,
    required this.seenAt,
    this.ratingStar,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  }) : super(
         id: id,
         exerciseId: exerciseId,
         userId: userId,
         seenAt: seenAt,
         ratingStar: ratingStar,
         comment: comment,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  factory ExerciseReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseReviewModelToJson(this);

  factory ExerciseReviewModel.fromEntity(ExerciseReview entity) {
    return ExerciseReviewModel(
      id: entity.id,
      exerciseId: entity.exerciseId,
      userId: entity.userId,
      seenAt: entity.seenAt,
      ratingStar: entity.ratingStar,
      comment: entity.comment,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  ExerciseReview toEntity() {
    return ExerciseReview(
      id: id,
      exerciseId: exerciseId,
      userId: userId,
      seenAt: seenAt,
      ratingStar: ratingStar,
      comment: comment,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
