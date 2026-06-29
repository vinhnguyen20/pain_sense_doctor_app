import 'dart:io';

import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/domain/entites/message.dart';

abstract class ConversationRepository {
  Future<ApiResponse<List<Conversation>>> getConversations({int limit});

  Future<ApiResponse<Conversation>> createConversation({
    required String participantId,
    required String initialMessageText,
  });

  Future<ApiResponse<Conversation>> getConversationById({
    required String conversationId,
  });

  Future<ApiResponse<void>> markConversationAsRead({
    required String conversationId,
  });

  Future<ApiResponse<PaginatedResponse<Message>>> getMessagesPage({
    required String conversationId,
    int limit,
    String? cursor,
  });

  Future<ApiResponse<Message>> sendTextMessage({
    required String conversationId,
    required String text,
  });

  Future<ApiResponse<Message>> uploadMessageFile({
    required String conversationId,
    required File file,
    required String messageType,
    String? caption,
  });
}
