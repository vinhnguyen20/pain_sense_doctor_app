import 'package:app_doctor/features/chats/domain/entites/message_content.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_content_model.g.dart';

@JsonSerializable()
class MessageContentModel extends MessageContent {
  const MessageContentModel({
    super.text,
    super.imageUrl,
    super.videoUrl,
    super.videoPlayerType,
    super.videoThumbnail,
    super.appointmentId,
    super.userExerciseId,
  });

  @JsonKey(name: 'image_url')
  @override
  String? get imageUrl => super.imageUrl;

  @JsonKey(name: 'video_url')
  @override
  String? get videoUrl => super.videoUrl;

  @JsonKey(name: 'video_player_type')
  @override
  String? get videoPlayerType => super.videoPlayerType;

  @JsonKey(name: 'video_thumbnail')
  @override
  String? get videoThumbnail => super.videoThumbnail;

  @JsonKey(name: 'appointment_id')
  @override
  String? get appointmentId => super.appointmentId;

  @JsonKey(name: 'user_exercise_id')
  @override
  String? get userExerciseId => super.userExerciseId;

  factory MessageContentModel.fromJson(Map<String, dynamic> json) =>
      _$MessageContentModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageContentModelToJson(this);

  factory MessageContentModel.fromEntity(MessageContent entity) {
    return MessageContentModel(
      text: entity.text,
      imageUrl: entity.imageUrl,
      videoUrl: entity.videoUrl,
      videoPlayerType: entity.videoPlayerType,
      videoThumbnail: entity.videoThumbnail,
      appointmentId: entity.appointmentId,
      userExerciseId: entity.userExerciseId,
    );
  }

  MessageContent toEntity() {
    return MessageContent(
      text: text,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      videoPlayerType: videoPlayerType,
      videoThumbnail: videoThumbnail,
      appointmentId: appointmentId,
      userExerciseId: userExerciseId,
    );
  }
}
