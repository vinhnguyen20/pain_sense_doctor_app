import 'package:app_doctor/features/chats/domain/entites/conversation_cache.dart';
import 'package:app_doctor/features/chats/domain/entites/message.dart';

abstract class ChatCacheRepository {
  Future<ConversationCache?> readConversation(String conversationId);

  Future<void> saveConversation({
    required String conversationId,
    required List<Message> messages,
    required bool hasMore,
    String? nextCursor,
    String? connectedUserId,
  });

  Future<void> clearConversation(String conversationId);
}
