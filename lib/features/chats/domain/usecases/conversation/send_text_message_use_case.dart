import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/chats/domain/entites/message.dart';
import 'package:app_doctor/features/chats/domain/repository/conversation_repository.dart';

class SendTextMessageUseCase {
  final ConversationRepository _repository;

  SendTextMessageUseCase(this._repository);

  Future<ApiResponse<Message>> call({
    required String conversationId,
    required String text,
  }) {
    return _repository.sendTextMessage(
      conversationId: conversationId,
      text: text,
    );
  }
}
