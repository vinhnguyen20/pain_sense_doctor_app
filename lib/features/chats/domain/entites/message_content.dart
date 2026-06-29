import 'package:equatable/equatable.dart';

class MessageContent extends Equatable {
  final String? text;
  final String? imageUrl;
  final String? videoUrl;
  final String? videoPlayerType;
  final String? videoThumbnail;
  final String? appointmentId;
  final String? userExerciseId;

  const MessageContent({
    this.text,
    this.imageUrl,
    this.videoUrl,
    this.videoPlayerType,
    this.videoThumbnail,
    this.appointmentId,
    this.userExerciseId,
  });

  @override
  List<Object?> get props => [
    text,
    imageUrl,
    videoUrl,
    videoPlayerType,
    videoThumbnail,
    appointmentId,
    userExerciseId,
  ];

  factory MessageContent.fromMap(Map<String, dynamic> map) => MessageContent(
    text: map['text'],
    imageUrl: map['image_url'],
    videoUrl: map['video_url'],
    videoPlayerType: map['video_player_type'],
    videoThumbnail: map['video_thumbnail'],
    appointmentId: map['appointment_id'],
    userExerciseId: map['user_exercise_id'],
  );
}
