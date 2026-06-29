import 'package:app_doctor/core/utils/entity_convertible.dart';
import 'package:app_doctor/features/education/domain/entites/exercise.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ExerciseModel extends Exercise
    with EntityConvertible<ExerciseModel, Exercise> {
  @JsonKey(name: 'duration_seconds')
  @override
  final int durationSeconds;

  @JsonKey(name: 'view_count')
  @override
  final int viewCount;

  @JsonKey(name: 'avg_ratings')
  @override
  final double avgRatings;

  @JsonKey(name: 'total_reviews')
  @override
  final int totalReviews;

  @JsonKey(name: 'created_at')
  @override
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  @override
  final DateTime? updatedAt;

  @JsonKey(name: 'created_by')
  @override
  final String? createdBy;

  @override
  final List<ExerciseMediaModel> media;

  const ExerciseModel({
    required super.id,
    required super.title,
    required super.description,
    required this.durationSeconds,
    required super.level,
    required super.benefits,
    required this.media,
    required this.viewCount,
    required this.avgRatings,
    required this.totalReviews,
    super.note,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  }) : super(
         durationSeconds: durationSeconds,
         viewCount: viewCount,
         avgRatings: avgRatings,
         totalReviews: totalReviews,
         media: media,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdBy: createdBy,
       );

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseModelToJson(this);

  @override
  Exercise toEntity() {
    return Exercise(
      id: id,
      title: title,
      description: description,
      durationSeconds: durationSeconds,
      level: level,
      benefits: benefits,
      media: media.map((e) => e.toEntity()).toList(),
      viewCount: viewCount,
      avgRatings: avgRatings,
      totalReviews: totalReviews,
      note: note,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ExerciseModel.fromEntity(Exercise entity) {
    return ExerciseModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      durationSeconds: entity.durationSeconds,
      level: entity.level,
      benefits: entity.benefits,
      media: entity.media.map((e) => ExerciseMediaModel.fromEntity(e)).toList(),
      viewCount: entity.viewCount,
      avgRatings: entity.avgRatings,
      totalReviews: entity.totalReviews,
      note: entity.note,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ExerciseMediaModel extends ExerciseMedia
    with EntityConvertible<ExerciseMediaModel, ExerciseMedia> {
  @JsonKey(name: 'type', fromJson: ExerciseMediaType.fromString)
  @override
  final ExerciseMediaType type;

  @JsonKey(name: 'thumbnail_url')
  @override
  final String? thumbnailUrl;

  @JsonKey(name: 'duration_seconds')
  @override
  final int? durationSeconds;

  @JsonKey(name: 'posture_position_required')
  @override
  final String? posturePositionRequired;

  @JsonKey(name: 'alt_text')
  @override
  final String? altText;

  @JsonKey(name: 'created_at')
  @override
  final DateTime? createdAt;

  @JsonKey(name: 'created_by')
  @override
  final String? createdBy;

  const ExerciseMediaModel({
    required super.id,
    required this.type,
    required super.title,
    required super.url,
    this.thumbnailUrl,
    required super.position,
    this.durationSeconds,
    this.posturePositionRequired,
    this.altText,
    this.createdAt,
    this.createdBy,
  }) : super(
         type: type,
         thumbnailUrl: thumbnailUrl,
         durationSeconds: durationSeconds,
         posturePositionRequired: posturePositionRequired,
         altText: altText,
         createdAt: createdAt,
         createdBy: createdBy,
       );

  factory ExerciseMediaModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseMediaModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseMediaModelToJson(this);

  factory ExerciseMediaModel.fromEntity(ExerciseMedia entity) {
    return ExerciseMediaModel(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      url: entity.url,
      thumbnailUrl: entity.thumbnailUrl,
      position: entity.position,
      durationSeconds: entity.durationSeconds,
      posturePositionRequired: entity.posturePositionRequired,
      altText: entity.altText,
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
    );
  }

  @override
  ExerciseMedia toEntity() {
    return ExerciseMedia(
      id: id,
      type: type,
      title: title,
      url: url,
      thumbnailUrl: thumbnailUrl,
      position: position,
      durationSeconds: durationSeconds,
      posturePositionRequired: posturePositionRequired,
      altText: altText,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}
