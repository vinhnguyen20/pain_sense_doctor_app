import 'package:equatable/equatable.dart';
import 'message_content.dart';

enum MessageType { text, image, video, appointment, exerciseAssignment }

enum MessageStatus { sent, delivered, read }

class Message extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final DateTime sentAt;
  final List<String> readByIds;
  final String status;
  final String type;
  final MessageContent content;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.sentAt,
    required this.readByIds,
    required this.status,
    required this.type,
    required this.content,
  });

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    DateTime? sentAt,
    List<String>? readByIds,
    String? status,
    String? type,
    MessageContent? content,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      sentAt: sentAt ?? this.sentAt,
      readByIds: readByIds ?? this.readByIds,
      status: status ?? this.status,
      type: type ?? this.type,
      content: content ?? this.content,
    );
  }

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    sentAt,
    readByIds,
    status,
    type,
    content,
  ];
}
