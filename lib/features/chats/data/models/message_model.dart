import 'package:app_doctor/features/chats/domain/entites/message.dart';
import 'package:json_annotation/json_annotation.dart';
import 'message_content_model.dart';

part 'message_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MessageModel extends Message {
  @override
  @JsonKey(name: '_id')
  final String id;

  @override
  @JsonKey(name: 'content')
  final MessageContentModel content;

  const MessageModel({
    required this.id,
    required super.conversationId,
    required super.senderId,
    required super.sentAt,
    required super.readByIds,
    required super.status,
    required super.type,
    required this.content,
  }) : super(id: id, content: content);

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  factory MessageModel.fromEntity(Message entity) {
    return MessageModel(
      id: entity.id,
      conversationId: entity.conversationId,
      senderId: entity.senderId,
      sentAt: entity.sentAt,
      readByIds: entity.readByIds,
      status: entity.status,
      type: entity.type,
      content: MessageContentModel.fromEntity(entity.content),
    );
  }
  Message toEntity() {
    return Message(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      sentAt: sentAt,
      readByIds: readByIds,
      status: status,
      type: type,
      content: content.toEntity(),
    );
  }

  bool get isMine => senderId == 'currentUserId';
}
