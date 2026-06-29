import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/domain/entites/last_message.dart';
import 'package:app_doctor/features/chats/domain/entites/un_read_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'conversation_model.g.dart';

@JsonSerializable()
class LastMessageModel extends LastMessage {
  @override
  @JsonKey(name: 'sent_at')
  final DateTime sentAt;

  @override
  @JsonKey(name: 'send_by')
  final String sendBy;

  const LastMessageModel({
    required super.text,
    required this.sentAt,
    required this.sendBy,
  }) : super(sentAt: sentAt, sendBy: sendBy);

  factory LastMessageModel.fromJson(Map<String, dynamic> json) =>
      _$LastMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$LastMessageModelToJson(this);

  factory LastMessageModel.fromEntity(LastMessage entity) {
    return LastMessageModel(
      text: entity.text,
      sentAt: entity.sentAt,
      sendBy: entity.sendBy,
    );
  }

  LastMessage toEntity() =>
      LastMessage(text: text, sentAt: sentAt, sendBy: sendBy);
}

@JsonSerializable()
class UnReadInfoModel extends UnReadInfo {
  @override
  @JsonKey(name: 'user_id')
  final String userId;

  @override
  @JsonKey(name: 'last_read_at')
  final DateTime? lastReadAt;

  const UnReadInfoModel({
    required this.userId,
    required super.count,
    this.lastReadAt,
  }) : super(userId: userId, lastReadAt: lastReadAt);

  factory UnReadInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UnReadInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$UnReadInfoModelToJson(this);

  factory UnReadInfoModel.fromEntity(UnReadInfo entity) {
    return UnReadInfoModel(
      userId: entity.userId,
      count: entity.count,
      lastReadAt: entity.lastReadAt,
    );
  }

  UnReadInfo toEntity() {
    return UnReadInfo(userId: userId, count: count, lastReadAt: lastReadAt);
  }
}

@JsonSerializable(explicitToJson: true)
class ConversationModel extends Conversation {
  @override
  @JsonKey(name: 'id')
  final String id;

  @override
  @JsonKey(name: 'participants')
  final List<String> participants;

  @override
  @JsonKey(name: 'last_message')
  final LastMessageModel? lastMessage;

  @override
  @JsonKey(name: 'unread_info')
  final List<UnReadInfoModel> unreadInfo;

  @override
  @JsonKey(name: 'unread_count_doctor')
  final int unreadCountDoctor;

  @override
  @JsonKey(name: 'unread_count_patient')
  final int unreadCountPatient;

  const ConversationModel({
    required this.id,
    required super.name,
    required this.participants,
    this.lastMessage,
    required this.unreadInfo,
    required super.status,
    required this.unreadCountDoctor,
    required this.unreadCountPatient,
  }) : super(
         id: id,
         participants: participants,
         lastMessage: lastMessage,
         unreadInfo: unreadInfo,
         unreadCountDoctor: unreadCountDoctor,
         unreadCountPatient: unreadCountPatient,
       );

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  factory ConversationModel.fromEntity(Conversation entity) {
    return ConversationModel(
      id: entity.id,
      name: entity.name,
      participants: entity.participants,
      lastMessage: entity.lastMessage != null
          ? LastMessageModel.fromEntity(entity.lastMessage!)
          : null,
      status: entity.status,
      unreadCountDoctor: entity.unreadCountDoctor,
      unreadCountPatient: entity.unreadCountPatient,
      unreadInfo: entity.unreadInfo
          .map((e) => UnReadInfoModel.fromEntity(e))
          .toList(),
    );
  }

  Conversation toEntity() {
    return Conversation(
      id: id,
      name: name,
      participants: participants,
      lastMessage: lastMessage?.toEntity(),
      status: status,
      unreadCountDoctor: unreadCountDoctor,
      unreadCountPatient: unreadCountPatient,
      unreadInfo: unreadInfo.map((e) => e.toEntity()).toList(),
    );
  }
}
