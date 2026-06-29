import 'dart:io';

import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/dio_client.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/chats/data/models/conversation_model.dart';
import 'package:app_doctor/features/chats/data/models/message_model.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/domain/entites/message.dart';
import 'package:dio/dio.dart';

class ChatRemoteDataSource {
  final DioClient _client;

  static final _timezonePattern = RegExp(r'(Z|[+-]\d{2}:\d{2})$');

  ChatRemoteDataSource(this._client);

  Future<ApiResponse<List<Conversation>>> getConversations({
    int limit = 10,
  }) async {
    try {
      final response = await _client.get<ApiResponse<List<ConversationModel>>>(
        '/conversations/user',
        queryParameters: {'limit': limit},
        fromJson: (json) => ApiResponse<List<ConversationModel>>.fromJson(
          json,
          (data) => _extractList(data)
              .map(
                (item) => ConversationModel.fromJson(
                  _normalizeConversationJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                ),
              )
              .toList(),
        ),
      );

      final items = response.data;
      if (response.isFailure || items == null) {
        return ApiResponse<List<Conversation>>(
          code: -1,
          message: response.message,
        );
      }

      return ApiResponse<List<Conversation>>.success(
        items.map((conversation) => conversation.toEntity()).toList(),
      );
    } catch (error, stackTrace) {
      return ApiResponse<List<Conversation>>.failure(error, stackTrace);
    }
  }

  Future<ApiResponse<Conversation>> createConversation({
    required String participantId,
    required String initialMessageText,
  }) async {
    final normalizedParticipantId = participantId.trim();
    if (normalizedParticipantId.isEmpty) {
      return const ApiResponse<Conversation>(
        code: -1,
        message: 'Patient id is missing. Cannot create conversation.',
      );
    }
    final effectiveLastMessage = initialMessageText.trim();
    if (effectiveLastMessage.isEmpty) {
      return const ApiResponse<Conversation>(
        code: -1,
        message:
            'Initial message is required when creating a new conversation.',
      );
    }

    try {
      final response = await _client.post<ApiResponse<ConversationModel>>(
        '/conversations',
        data: {
          'participants': [normalizedParticipantId],
          'last_message': {'text': effectiveLastMessage},
          'status': 'active',
        },
        fromJson: (json) => ApiResponse<ConversationModel>.fromJson(
          json,
          (data) => ConversationModel.fromJson(
            _normalizeConversationJson(Map<String, dynamic>.from(data as Map)),
          ),
        ),
      );

      if (response.isFailure || response.data == null) {
        return ApiResponse<Conversation>(code: -1, message: response.message);
      }

      return ApiResponse<Conversation>.success(response.data!.toEntity());
    } catch (error, stackTrace) {
      return ApiResponse<Conversation>.failure(error, stackTrace);
    }
  }

  Future<ApiResponse<Conversation>> getConversationById({
    required String conversationId,
  }) async {
    final normalizedConversationId = _sanitizeId(conversationId);
    if (normalizedConversationId.isEmpty) {
      return ApiResponse<Conversation>(
        code: -1,
        message: 'Conversation id is missing.',
      );
    }

    try {
      final response = await _client.get<ApiResponse<ConversationModel>>(
        '/conversations/conversation_by_id/$normalizedConversationId',
        fromJson: (json) => ApiResponse<ConversationModel>.fromJson(
          json,
          (data) => ConversationModel.fromJson(
            _normalizeConversationJson(Map<String, dynamic>.from(data as Map)),
          ),
        ),
      );

      if (response.isFailure || response.data == null) {
        return ApiResponse<Conversation>(code: -1, message: response.message);
      }

      return ApiResponse<Conversation>.success(response.data!.toEntity());
    } catch (error, stackTrace) {
      return ApiResponse<Conversation>.failure(error, stackTrace);
    }
  }

  Future<ApiResponse<PaginatedResponse<Message>>> getMessagesPage({
    required String conversationId,
    int limit = 10,
    String? cursor,
  }) async {
    final normalizedConversationId = _sanitizeId(conversationId);
    if (normalizedConversationId.isEmpty) {
      return const ApiResponse<PaginatedResponse<Message>>(
        code: -1,
        message: 'Conversation id is missing. Cannot load messages.',
      );
    }

    try {
      return await _loadMessagesPage(
        path: '/messages/conversation/$normalizedConversationId',
        limit: limit,
        cursor: cursor,
      );
    } catch (error, stackTrace) {
      return ApiResponse<PaginatedResponse<Message>>.failure(error, stackTrace);
    }
  }

  Future<ApiResponse<PaginatedResponse<Message>>> _loadMessagesPage({
    required String path,
    required int limit,
    String? cursor,
  }) async {
    final response = await _client
        .get<ApiResponse<PaginatedResponse<MessageModel>>>(
          path,
          queryParameters: {
            'limit': limit,
            if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          },
          fromJson: (json) {
            final normalized = _normalizePaginatedMessagesJson(
              Map<String, dynamic>.from(json as Map),
            );

            return ApiResponse.fromPaginatedJson<MessageModel>(
              normalized,
              (item) => MessageModel.fromJson(
                _normalizeMessageJson(Map<String, dynamic>.from(item as Map)),
              ),
            );
          },
        );

    final page = response.data;
    if (response.isFailure || page == null) {
      return ApiResponse<PaginatedResponse<Message>>(
        code: -1,
        message: response.message,
      );
    }

    return ApiResponse<PaginatedResponse<Message>>.success(
      PaginatedResponse<Message>(
        items: page.items.map((message) => message.toEntity()).toList(),
        nextCursor: page.nextCursor,
        limit: page.limit,
      ),
    );
  }

  Future<ApiResponse<Message>> sendTextMessage({
    required String conversationId,
    required String text,
  }) async {
    final normalizedConversationId = _sanitizeId(conversationId);
    if (normalizedConversationId.isEmpty) {
      return ApiResponse<Message>(
        code: -1,
        message: 'Conversation id is missing.',
      );
    }

    try {
      final response = await _client.post<ApiResponse<MessageModel>>(
        '/messages',
        data: {
          'conversation_id': normalizedConversationId,
          'type': 'text',
          'content': {'text': text},
        },
        fromJson: (json) => ApiResponse<MessageModel>.fromJson(
          json,
          (data) => MessageModel.fromJson(
            _normalizeMessageJson(Map<String, dynamic>.from(data as Map)),
          ),
        ),
      );

      if (response.isFailure || response.data == null) {
        return ApiResponse<Message>(code: -1, message: response.message);
      }

      return ApiResponse<Message>.success(response.data!.toEntity());
    } catch (error, stackTrace) {
      return ApiResponse<Message>.failure(error, stackTrace);
    }
  }

  Future<ApiResponse<Message>> uploadMessageFile({
    required String conversationId,
    required File file,
    required String messageType,
    String? caption,
  }) async {
    final normalizedConversationId = _sanitizeId(conversationId);

    try {
      final formData = FormData.fromMap({
        'component': 'image',
        'files': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final uploadResponse = await _client.post<dynamic>(
        '/messages/upload-files',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final rawData = uploadResponse is Map
          ? uploadResponse['data']
          : uploadResponse?.data;
      final urls = rawData is List ? rawData : null;
      final imageUrl = urls?.isNotEmpty == true
          ? urls!.first?.toString()
          : null;

      if (imageUrl == null || imageUrl.isEmpty) {
        return const ApiResponse<Message>(
          code: -1,
          message: 'Upload failed: no file URL returned',
        );
      }

      final response = await _client.post<ApiResponse<MessageModel>>(
        '/messages',
        data: {
          'conversation_id': normalizedConversationId,
          'type': messageType,
          'content': {
            if (caption != null && caption.trim().isNotEmpty)
              'text': caption.trim(),
            'image_url': imageUrl,
          },
        },
        fromJson: (json) => ApiResponse<MessageModel>.fromJson(
          json,
          (data) => MessageModel.fromJson(
            _normalizeMessageJson(Map<String, dynamic>.from(data as Map)),
          ),
        ),
      );

      if (response.isFailure || response.data == null) {
        return ApiResponse<Message>(code: -1, message: response.message);
      }

      return ApiResponse<Message>.success(response.data!.toEntity());
    } catch (error, stackTrace) {
      return ApiResponse<Message>.failure(error, stackTrace);
    }
  }

  Future<ApiResponse<void>> markConversationAsRead({
    required String conversationId,
  }) async {
    final normalizedConversationId = _sanitizeId(conversationId);

    try {
      await _client.post<dynamic>(
        '/messages/conversation/$normalizedConversationId/read',
      );
      return ApiResponse<void>.success(null);
    } catch (error, stackTrace) {
      return ApiResponse<void>.failure(error, stackTrace);
    }
  }

  Message parseMessage(Map<String, dynamic> raw) {
    final model = MessageModel.fromJson(_normalizeMessageJson(raw));
    return model.toEntity();
  }

  Conversation parseConversation(Map<String, dynamic> raw) {
    final model = ConversationModel.fromJson(_normalizeConversationJson(raw));
    return model.toEntity();
  }

  Map<String, dynamic> _normalizeConversationJson(Map<String, dynamic> source) {
    final normalized = Map<String, dynamic>.from(source);
    normalized['id'] = _sanitizeId(normalized['id']);

    final rawLastMessage = normalized['last_message'];
    if (rawLastMessage is Map) {
      final lastMessage = Map<String, dynamic>.from(rawLastMessage);
      final sentAt = lastMessage['sent_at'];
      if (sentAt == null) {
        normalized['last_message'] = null;
      } else {
        normalized['last_message'] = {
          ...lastMessage,
          'send_by': lastMessage['send_by'] ?? lastMessage['sent_by'] ?? '',
          'text': lastMessage['text'] ?? '',
        };
      }
    } else {
      normalized['last_message'] = null;
    }

    normalized['unread_info'] = normalized['unread_info'] ?? <dynamic>[];
    normalized['unread_count_doctor'] = normalized['unread_count_doctor'] ?? 0;
    normalized['unread_count_patient'] =
        normalized['unread_count_patient'] ?? 0;
    normalized['status'] = normalized['status'] ?? 'active';
    normalized['name'] = normalized['name'] ?? 'Conversation';
    final participantsRaw = normalized['participants'];
    if (participantsRaw is List) {
      normalized['participants'] = participantsRaw
          .map((item) => _sanitizeId(item?.toString()))
          .where((item) => item.isNotEmpty)
          .toList();
    } else {
      normalized['participants'] = <dynamic>[];
    }

    return normalized;
  }

  Map<String, dynamic> _normalizeMessageJson(Map<String, dynamic> source) {
    final normalized = Map<String, dynamic>.from(source);

    final content = normalized['content'];
    final contentMap = content is Map
        ? Map<String, dynamic>.from(content)
        : <String, dynamic>{};
    normalized['content'] = contentMap;

    final rawConversationId =
        normalized['conversationId'] ?? normalized['conversation_id'] ?? '';
    final conversationId = _sanitizeId(rawConversationId?.toString());
    normalized['conversationId'] = conversationId;

    final rawSenderId = normalized['senderId'] ?? normalized['sender_id'] ?? '';
    final senderId = _sanitizeId(rawSenderId?.toString());
    normalized['senderId'] = senderId;

    final sentAt = normalized['sentAt'] ?? normalized['sent_at'];
    final sentAtStr = _normalizeSentAtToUtcIso(sentAt);
    normalized['sentAt'] = sentAtStr;

    final rawId = normalized['_id'] ?? normalized['id'];
    final computedId = rawId?.toString().trim().isNotEmpty == true
        ? _sanitizeId(rawId.toString())
        : 'ws_${conversationId}_${senderId}_${sentAtStr}_${contentMap.hashCode}';
    normalized['_id'] = computedId;

    final rawReadByIds =
        normalized['readByIds'] ?? normalized['read_by_ids'] ?? <dynamic>[];
    if (rawReadByIds is List) {
      normalized['readByIds'] = rawReadByIds
          .map((item) => _sanitizeId(item?.toString()))
          .where((item) => item.isNotEmpty)
          .toList();
    } else {
      normalized['readByIds'] = <String>[];
    }

    normalized['status'] = normalized['status'] ?? 'sent';
    normalized['type'] = _normalizeMessageType(normalized['type']);

    return normalized;
  }

  Map<String, dynamic> _normalizePaginatedMessagesJson(
    Map<String, dynamic> source,
  ) {
    final normalized = Map<String, dynamic>.from(source);
    final rawData = normalized['data'];

    if (rawData is Map) {
      final data = Map<String, dynamic>.from(rawData);
      data['items'] = data['items'] ?? <dynamic>[];
      data['next_cursor'] = data['next_cursor'] ?? '';
      data['limit'] = data['limit'] ?? 10;
      normalized['data'] = data;
    }

    return normalized;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final items = map['items'];
      if (items is List) return items;
    }

    return const [];
  }

  String _sanitizeId(String? raw) {
    return raw?.trim() ?? '';
  }

  String _normalizeMessageType(dynamic rawType) {
    final type = rawType?.toString().trim().toLowerCase() ?? 'text';
    if (type == 'exerciseassignment' || type == 'exercise-assignment') {
      return 'exercise_assignment';
    }
    return type.isEmpty ? 'text' : type;
  }

  String _normalizeSentAtToUtcIso(dynamic rawSentAt) {
    if (rawSentAt is DateTime) {
      return rawSentAt.toUtc().toIso8601String();
    }

    final raw = rawSentAt?.toString().trim() ?? '';
    if (raw.isEmpty) {
      return DateTime.now().toUtc().toIso8601String();
    }

    final hasTimezone = _timezonePattern.hasMatch(raw);
    final normalizedInput = hasTimezone ? raw : '${raw}Z';
    final parsed = DateTime.tryParse(normalizedInput);
    return (parsed ?? DateTime.now().toUtc()).toUtc().toIso8601String();
  }
}
