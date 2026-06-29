import 'package:app_doctor/features/chats/domain/entites/message.dart';
import 'package:app_doctor/features/chats/domain/repository/chat_cache_repository.dart';

class SaveCachedConversationUseCase {
  final ChatCacheRepository _repository;

  SaveCachedConversationUseCase(this._repository);

  Future<void> call({
    required String conversationId,
    required List<Message> messages,
    required bool hasMore,
    String? nextCursor,
    String? connectedUserId,
  }) {
    return _repository.saveConversation(
      conversationId: conversationId,
      messages: messages,
      hasMore: hasMore,
      nextCursor: nextCursor,
      connectedUserId: connectedUserId,
    );
  }
}
