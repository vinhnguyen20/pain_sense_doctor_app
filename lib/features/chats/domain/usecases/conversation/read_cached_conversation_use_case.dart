import 'package:app_doctor/features/chats/domain/entites/conversation_cache.dart';
import 'package:app_doctor/features/chats/domain/repository/chat_cache_repository.dart';

class ReadCachedConversationUseCase {
  final ChatCacheRepository _repository;

  ReadCachedConversationUseCase(this._repository);

  Future<ConversationCache?> call(String conversationId) {
    return _repository.readConversation(conversationId);
  }
}
