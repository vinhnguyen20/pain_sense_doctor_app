import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/domain/repository/conversation_repository.dart';

class CreateConversationUseCase {
  final ConversationRepository _repository;

  CreateConversationUseCase(this._repository);

  Future<ApiResponse<Conversation>> call({
    required String participantId,
    required String initialMessageText,
  }) {
    return _repository.createConversation(
      participantId: participantId,
      initialMessageText: initialMessageText,
    );
  }
}
