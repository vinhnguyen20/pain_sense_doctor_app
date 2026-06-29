import 'dart:convert';

import 'package:app_doctor/features/chats/data/models/message_model.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation_cache.dart';
import 'package:app_doctor/features/chats/domain/entites/message.dart';
import 'package:app_doctor/features/chats/domain/repository/chat_cache_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatCacheRepositoryImpl implements ChatCacheRepository {
  static const String _cacheKeyPrefix = 'chat_room_cache_v1';
  static const int _maxMessagesPerConversation = 180;

  final SharedPreferences _prefs;

  ChatCacheRepositoryImpl(this._prefs);

  String _keyFor(String conversationId) =>
      '$_cacheKeyPrefix:${conversationId.trim()}';

  @override
  Future<ConversationCache?> readConversation(String conversationId) async {
    final raw = _prefs.getString(_keyFor(conversationId));
    if (raw == null || raw.isEmpty) return null;

    try {
      final json = jsonDecode(raw);
      if (json is! Map) return null;
      final map = Map<String, dynamic>.from(json);

      final rawMessages = map['messages'];
      if (rawMessages is! List) return null;

      final messages = <Message>[];
      for (final item in rawMessages) {
        if (item is! Map) continue;
        try {
          messages.add(
            MessageModel.fromJson(Map<String, dynamic>.from(item)).toEntity(),
          );
        } catch (_) {}
      }
      messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));

      final updatedAtRaw = map['updated_at']?.toString() ?? '';
      final updatedAt =
          DateTime.tryParse(updatedAtRaw)?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final nextCursorRaw = map['next_cursor']?.toString() ?? '';
      final connectedUserIdRaw = map['connected_user_id']?.toString() ?? '';

      return ConversationCache(
        messages: messages,
        nextCursor: nextCursorRaw.isEmpty ? null : nextCursorRaw,
        hasMore: map['has_more'] == true,
        updatedAt: updatedAt,
        connectedUserId: connectedUserIdRaw.isEmpty ? null : connectedUserIdRaw,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveConversation({
    required String conversationId,
    required List<Message> messages,
    required bool hasMore,
    String? nextCursor,
    String? connectedUserId,
  }) async {
    final capped = messages.length > _maxMessagesPerConversation
        ? messages.sublist(messages.length - _maxMessagesPerConversation)
        : messages;

    final map = <String, dynamic>{
      'version': 1,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
      'has_more': hasMore,
      'next_cursor': nextCursor ?? '',
      'connected_user_id': connectedUserId ?? '',
      'messages': capped
          .map((m) => MessageModel.fromEntity(m).toJson())
          .toList(),
    };

    await _prefs.setString(_keyFor(conversationId), jsonEncode(map));
  }

  @override
  Future<void> clearConversation(String conversationId) async {
    await _prefs.remove(_keyFor(conversationId));
  }
}
