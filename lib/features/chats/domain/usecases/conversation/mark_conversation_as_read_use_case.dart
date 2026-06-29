import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/chats/domain/repository/conversation_repository.dart';

class MarkConversationAsReadUseCase {
  final ConversationRepository _repository;

  MarkConversationAsReadUseCase(this._repository);

  Future<ApiResponse<void>> call({required String conversationId}) {
    return _repository.markConversationAsRead(conversationId: conversationId);
  }
}
