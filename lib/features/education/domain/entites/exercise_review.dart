import 'package:equatable/equatable.dart';

class ExerciseReview extends Equatable {
  final String id;
  final String exerciseId;
  final String userId;
  final DateTime seenAt;
  final int? ratingStar;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ExerciseReview({
    required this.id,
    required this.exerciseId,
    required this.userId,
    required this.seenAt,
    this.ratingStar,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    exerciseId,
    userId,
    seenAt,
    ratingStar,
    comment,
    createdAt,
    updatedAt,
  ];
}
