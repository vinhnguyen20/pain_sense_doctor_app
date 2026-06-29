import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/chats/domain/entites/message.dart';
import 'package:app_doctor/features/chats/domain/repository/conversation_repository.dart';

class GetMessagesPageUseCase {
  final ConversationRepository _repository;

  GetMessagesPageUseCase(this._repository);

  Future<ApiResponse<PaginatedResponse<Message>>> call({
    required String conversationId,
    int limit = 10,
    String? cursor,
  }) {
    return _repository.getMessagesPage(
      conversationId: conversationId,
      limit: limit,
      cursor: cursor,
    );
  }
}
