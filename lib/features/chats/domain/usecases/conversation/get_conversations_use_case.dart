import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/domain/repository/conversation_repository.dart';

class GetConversationsUseCase {
  final ConversationRepository _repository;

  GetConversationsUseCase(this._repository);

  Future<ApiResponse<List<Conversation>>> call({int limit = 10}) {
    return _repository.getConversations(limit: limit);
  }
}
