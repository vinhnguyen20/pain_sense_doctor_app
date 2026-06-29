import 'package:app_doctor/features/chats/domain/repository/chat_cache_repository.dart';

class ClearCachedConversationUseCase {
  final ChatCacheRepository _repository;

  ClearCachedConversationUseCase(this._repository);

  Future<void> call(String conversationId) {
    return _repository.clearConversation(conversationId);
  }
}
