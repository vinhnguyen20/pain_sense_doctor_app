import 'dart:io';

import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/chats/domain/entites/message.dart';
import 'package:app_doctor/features/chats/domain/repository/conversation_repository.dart';

class UploadMessageFileUseCase {
  final ConversationRepository _repository;

  UploadMessageFileUseCase(this._repository);

  Future<ApiResponse<Message>> call({
    required String conversationId,
    required File file,
    required String messageType,
    String? caption,
  }) {
    return _repository.uploadMessageFile(
      conversationId: conversationId,
      file: file,
      messageType: messageType,
      caption: caption,
    );
  }
}
