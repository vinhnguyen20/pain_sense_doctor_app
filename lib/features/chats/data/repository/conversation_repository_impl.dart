import 'dart:io';

import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/chats/data/datasources/chat_remote_datasource.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/domain/entites/message.dart';
import 'package:app_doctor/features/chats/domain/repository/conversation_repository.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ChatRemoteDataSource remoteDataSource;

  ConversationRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResponse<List<Conversation>>> getConversations({int limit = 10}) {
    return remoteDataSource.getConversations(limit: limit);
  }

  @override
  Future<ApiResponse<Conversation>> createConversation({
    required String participantId,
    required String initialMessageText,
  }) {
    return remoteDataSource.createConversation(
      participantId: participantId,
      initialMessageText: initialMessageText,
    );
  }

  @override
  Future<ApiResponse<Conversation>> getConversationById({
    required String conversationId,
  }) {
    return remoteDataSource.getConversationById(conversationId: conversationId);
  }

  @override
  Future<ApiResponse<void>> markConversationAsRead({
    required String conversationId,
  }) {
    return remoteDataSource.markConversationAsRead(
      conversationId: conversationId,
    );
  }

  @override
  Future<ApiResponse<PaginatedResponse<Message>>> getMessagesPage({
    required String conversationId,
    int limit = 10,
    String? cursor,
  }) {
    return remoteDataSource.getMessagesPage(
      conversationId: conversationId,
      limit: limit,
      cursor: cursor,
    );
  }

  @override
  Future<ApiResponse<Message>> sendTextMessage({
    required String conversationId,
    required String text,
  }) {
    return remoteDataSource.sendTextMessage(
      conversationId: conversationId,
      text: text,
    );
  }

  @override
  Future<ApiResponse<Message>> uploadMessageFile({
    required String conversationId,
    required File file,
    required String messageType,
    String? caption,
  }) {
    return remoteDataSource.uploadMessageFile(
      conversationId: conversationId,
      file: file,
      messageType: messageType,
      caption: caption,
    );
  }
}
