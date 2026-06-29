import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/domain/repository/conversation_repository.dart';

class GetConversationByIdUseCase {
  final ConversationRepository _repository;

  GetConversationByIdUseCase(this._repository);

  Future<ApiResponse<Conversation>> call({required String conversationId}) {
    return _repository.getConversationById(conversationId: conversationId);
  }
}
