import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/domain/entites/message.dart';

sealed class ChatWsEvent {
  const ChatWsEvent();
}

final class ChatWsConnected extends ChatWsEvent {
  final String? userId;
  const ChatWsConnected({this.userId});
}

final class ChatWsReconnecting extends ChatWsEvent {
  const ChatWsReconnecting();
}

final class ChatWsDisconnected extends ChatWsEvent {
  final String? error;
  final bool isAuthError;
  const ChatWsDisconnected({this.error, this.isAuthError = false});
}

final class ChatWsMessageReceived extends ChatWsEvent {
  final Message message;
  const ChatWsMessageReceived(this.message);
}

final class ChatWsConversationUpdated extends ChatWsEvent {
  final Conversation conversation;
  const ChatWsConversationUpdated(this.conversation);
}

final class ChatWsMessageRead extends ChatWsEvent {
  final String conversationId;
  final String readerId;
  const ChatWsMessageRead({
    required this.conversationId,
    required this.readerId,
  });
}
