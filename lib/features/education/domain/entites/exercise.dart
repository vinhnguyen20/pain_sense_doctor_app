import 'package:equatable/equatable.dart';

class Exercise extends Equatable {
  final String id;
  final String title;
  final String description;
  final int durationSeconds;
  final String level;
  final List<String> benefits;
  final List<ExerciseMedia> media;
  final int viewCount;
  final double avgRatings;
  final int totalReviews;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;

  const Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.durationSeconds,
    required this.level,
    required this.benefits,
    required this.media,
    required this.viewCount,
    required this.avgRatings,
    required this.totalReviews,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    durationSeconds,
    level,
    benefits,
    media,
    viewCount,
    avgRatings,
    totalReviews,
    note,
    createdAt,
    updatedAt,
    createdBy,
  ];
}

enum ExerciseMediaType {
  image,
  videoServer,
  videoYoutube,
  unknown;

  static ExerciseMediaType fromString(String value) {
    switch (value) {
      case 'image':
        return ExerciseMediaType.image;
      case 'video_server':
        return ExerciseMediaType.videoServer;
      case 'video_youtube':
        return ExerciseMediaType.videoYoutube;
      default:
        return ExerciseMediaType.unknown;
    }
  }
}

class ExerciseMedia extends Equatable {
  final String id;
  final ExerciseMediaType type;
  final String title;
  final String url;
  final String? thumbnailUrl;
  final int position;
  final int? durationSeconds;
  final String? posturePositionRequired;
  final String? altText;
  final DateTime? createdAt;
  final String? createdBy;

  const ExerciseMedia({
    required this.id,
    required this.type,
    required this.title,
    required this.url,
    this.thumbnailUrl,
    required this.position,
    this.durationSeconds,
    this.posturePositionRequired,
    this.altText,
    this.createdAt,
    this.createdBy,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    url,
    thumbnailUrl,
    position,
    durationSeconds,
    posturePositionRequired,
    altText,
    createdAt,
    createdBy,
  ];
}
