import 'dart:async';
import 'dart:io';

import 'package:app_doctor/core/services/auth/token_service.dart';
import 'package:app_doctor/features/chats/data/datasources/chat_ws_datasource.dart';
import 'package:app_doctor/features/chats/data/models/chat_ws_event.dart';
import 'package:app_doctor/features/chats/domain/entites/message.dart';
import 'package:app_doctor/features/chats/presentation/provider/chat_providers.dart';
import 'package:app_doctor/features/auth/presentation/provider/auth_notifier.dart';
import 'package:app_doctor/features/chats/presentation/provider/conversation_notifier.dart';
import 'package:app_doctor/features/user/presentation/provider/user_notifier.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatRoomState {
  final List<Message> messages;
  final bool isLoadingHistory;
  final bool isLoadingMoreHistory;
  final String? nextHistoryCursor;
  final bool hasMoreHistory;
  final bool isConnectingWs;
  final bool isWsConnected;
  final bool isSending;
  final String? connectedUserId;
  final String? error;

  const ChatRoomState({
    this.messages = const [],
    this.isLoadingHistory = false,
    this.isLoadingMoreHistory = false,
    this.nextHistoryCursor,
    this.hasMoreHistory = false,
    this.isConnectingWs = false,
    this.isWsConnected = false,
    this.isSending = false,
    this.connectedUserId,
    this.error,
  });

  ChatRoomState copyWith({
    List<Message>? messages,
    bool? isLoadingHistory,
    bool? isLoadingMoreHistory,
    String? nextHistoryCursor,
    bool? hasMoreHistory,
    bool? isConnectingWs,
    bool? isWsConnected,
    bool? isSending,
    String? connectedUserId,
    String? error,
    bool clearError = false,
    bool clearHistoryCursor = false,
  }) {
    return ChatRoomState(
      messages: messages ?? this.messages,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isLoadingMoreHistory: isLoadingMoreHistory ?? this.isLoadingMoreHistory,
      nextHistoryCursor: clearHistoryCursor
          ? null
          : nextHistoryCursor ?? this.nextHistoryCursor,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      isConnectingWs: isConnectingWs ?? this.isConnectingWs,
      isWsConnected: isWsConnected ?? this.isWsConnected,
      isSending: isSending ?? this.isSending,
      connectedUserId: connectedUserId ?? this.connectedUserId,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ChatRoomSession {
  final String conversationId;
  final String patientId;

  const ChatRoomSession({
    required this.conversationId,
    required this.patientId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatRoomSession &&
        other.conversationId == conversationId &&
        other.patientId == patientId;
  }

  @override
  int get hashCode => Object.hash(conversationId, patientId);
}

final chatRoomProvider = NotifierProvider.autoDispose
    .family<ChatRoomNotifier, ChatRoomState, ChatRoomSession>(
      ChatRoomNotifier.new,
    );

class ChatRoomNotifier extends Notifier<ChatRoomState> {
  static const int _historyPageSize = 20;
  static const Duration _cacheTtl = Duration(seconds: 30);
  static const Duration _cacheWriteDebounce = Duration(milliseconds: 350);

  String _conversationId;
  final String _patientId;

  ChatWsDataSource? _wsDs;
  StreamSubscription<ChatWsEvent>? _wsSubscription;
  Timer? _cacheDebounceTimer;
  bool _isDisposed = false;
  DateTime? _lastHydratedCacheAt;

  ChatRoomNotifier(ChatRoomSession session)
    : _conversationId = session.conversationId.trim(),
      _patientId = session.patientId.trim();

  @override
  ChatRoomState build() {
    ref.onDispose(() {
      _isDisposed = true;
      _wsSubscription?.cancel();
      _cacheDebounceTimer?.cancel();
      _wsDs?.dispose();
    });

    Future.microtask(_initialize);
    return const ChatRoomState();
  }

  Future<void> _initialize() async {
    if (_conversationId.isEmpty) {
      if (_patientId.isNotEmpty) {
        final existing = await ref
            .read(conversationsProvider.notifier)
            .getConversationWithParticipant(participantId: _patientId);
        if (existing != null && existing.id.trim().isNotEmpty) {
          _conversationId = existing.id.trim();
        }
      }
      if (_conversationId.isEmpty) {
        return;
      }
    }

    final hydrated = await _hydrateFromCache();
    if (!hydrated || !_isCacheFresh()) {
      await loadHistory();
    }
    await _connectWs();
    await markAsRead();
  }

  Future<void> _refreshLatestMessage() async {
    if (_conversationId.isEmpty) return;
    if (_isDisposed || !ref.mounted) return;

    final response = await ref
        .read(getMessagesPageUseCaseProvider)
        .call(conversationId: _conversationId, limit: _historyPageSize);
    if (_isDisposed || !ref.mounted) return;
    if (response.isFailure || response.data == null) return;

    final items = response.data!.items;
    if (items.isEmpty) return;

    final messages = [...state.messages];
    for (final item in items) {
      final index = messages.indexWhere((m) => m.id == item.id);
      if (index >= 0) {
        messages[index] = item;
      } else {
        messages.add(item);
      }
    }
    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    state = state.copyWith(messages: messages);
    _schedulePersistCache();
  }

  Future<void> loadHistory() async {
    if (_conversationId.isEmpty) return;
    if (state.isLoadingHistory) return;

    state = state.copyWith(
      isLoadingHistory: true,
      isLoadingMoreHistory: false,
      clearError: true,
    );

    final response = await ref
        .read(getMessagesPageUseCaseProvider)
        .call(conversationId: _conversationId, limit: _historyPageSize);

    if (response.isSuccess && response.data != null) {
      final page = response.data!;
      final sorted = [...page.items]
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
      state = state.copyWith(
        messages: _resolveMessagesForDisplay(sorted),
        isLoadingHistory: false,
        isLoadingMoreHistory: false,
        nextHistoryCursor: page.nextCursor,
        hasMoreHistory: page.hasMore,
      );
      _schedulePersistCache();
      return;
    }

    state = state.copyWith(
      isLoadingHistory: false,
      isLoadingMoreHistory: false,
      error: state.messages.isEmpty ? response.message : null,
    );
  }

  Future<void> loadOlderMessages() async {
    if (_conversationId.isEmpty) return;
    if (state.isLoadingHistory || state.isLoadingMoreHistory) return;
    if (!state.hasMoreHistory) return;

    final cursor = state.nextHistoryCursor;
    if (cursor == null || cursor.isEmpty) {
      state = state.copyWith(hasMoreHistory: false);
      return;
    }

    state = state.copyWith(isLoadingMoreHistory: true, clearError: true);

    final response = await ref
        .read(getMessagesPageUseCaseProvider)
        .call(
          conversationId: _conversationId,
          limit: _historyPageSize,
          cursor: cursor,
        );

    if (response.isFailure || response.data == null) {
      state = state.copyWith(
        isLoadingMoreHistory: false,
        error: response.message,
      );
      return;
    }

    final page = response.data!;
    final older = [...page.items]..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    state = state.copyWith(
      messages: _mergeSortedWithoutDuplicates(older, state.messages),
      isLoadingMoreHistory: false,
      nextHistoryCursor: page.nextCursor,
      hasMoreHistory: page.hasMore,
    );
    _schedulePersistCache();
  }

  Future<void> sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    state = state.copyWith(isSending: true, clearError: true);

    if (_conversationId.isEmpty) {
      if (_patientId.isEmpty) {
        state = state.copyWith(
          isSending: false,
          error: 'Patient information is missing',
        );
        return;
      }

      final createdConv = await ref
          .read(conversationsProvider.notifier)
          .createConversationAndSendFirstMessage(
            participantId: _patientId,
            firstMessage: trimmed,
          );

      if (createdConv != null && createdConv.id.trim().isNotEmpty) {
        _conversationId = createdConv.id.trim();
        await loadHistory();
        unawaited(_connectWs());
        state = state.copyWith(isSending: false);
        return;
      }

      final convError = ref.read(conversationsProvider).error;
      state = state.copyWith(
        isSending: false,
        error: convError ?? 'Failed to start conversation',
      );
      return;
    }

    if (!state.isWsConnected && !state.isConnectingWs) {
      unawaited(_connectWs());
    }

    final response = await ref
        .read(sendTextMessageUseCaseProvider)
        .call(conversationId: _conversationId, text: trimmed);

    if (response.isSuccess && response.data != null) {
      _appendOrUpdateMessage(response.data!);
      state = state.copyWith(isSending: false);
      return;
    }

    state = state.copyWith(isSending: false, error: response.message);
  }

  Future<void> sendImage({required File file, String? caption}) async {
    if (state.isSending) return;

    state = state.copyWith(isSending: true, clearError: true);

    if (_conversationId.isEmpty) {
      if (_patientId.isEmpty) {
        state = state.copyWith(
          isSending: false,
          error: 'Patient information is missing',
        );
        return;
      }

      final createRes = await ref
          .read(createConversationUseCaseProvider)
          .call(
            participantId: _patientId,
            initialMessageText: caption ?? 'Sent an image',
          );

      if (createRes.isFailure || createRes.data == null) {
        state = state.copyWith(
          isSending: false,
          error: createRes.message,
        );
        return;
      }

      final createdConv = createRes.data!;
      _conversationId = createdConv.id.trim();
      ref.read(conversationsProvider.notifier).upsertConversation(createdConv);
      unawaited(_connectWs());
    }

    if (!state.isWsConnected && !state.isConnectingWs) {
      unawaited(_connectWs());
    }

    final response = await ref
        .read(uploadMessageFileUseCaseProvider)
        .call(
          conversationId: _conversationId,
          file: file,
          messageType: 'image',
          caption: caption,
        );

    if (response.isSuccess && response.data != null) {
      _appendOrUpdateMessage(response.data!);
      state = state.copyWith(isSending: false);
      return;
    }

    state = state.copyWith(isSending: false, error: response.message);
  }

  Future<void> markAsRead() async {
    if (_conversationId.isEmpty) return;

    final response = await ref
        .read(markConversationAsReadUseCaseProvider)
        .call(conversationId: _conversationId);

    if (response.isFailure) {
      state = state.copyWith(error: response.message);
      return;
    }

    final currentMainUserId = ref.read(userProvider).user?.id ?? '';
    final currentChatUserId = state.connectedUserId ?? '';
    final readerId = currentMainUserId.isNotEmpty
        ? currentMainUserId
        : currentChatUserId;
    if (readerId.isNotEmpty) {
      _markIncomingMessagesAsReadForCurrentUser(
        readerId: readerId,
        currentUserIds: _buildCurrentUserIds(),
      );
    }
  }

  Future<void> _connectWs() async {
    if (_conversationId.isEmpty) return;
    if (_isDisposed || !ref.mounted) return;
    if (state.isConnectingWs || state.isWsConnected) return;

    state = state.copyWith(isConnectingWs: true, clearError: true);

    final chatDs = ref.read(chatRemoteDataSourceProvider);

    _wsDs?.dispose();
    _wsDs = ChatWsDataSource(
      conversationId: _conversationId,
      getAccessToken: () =>
          ref.read(tokenServiceProvider.notifier).getAccessToken(),
      parseMessage: chatDs.parseMessage,
      parseConversation: chatDs.parseConversation,
    );

    _wsSubscription?.cancel();
    _wsSubscription = _wsDs?.events.listen(_handleWsEvent, onError: (_) {});
    await _wsDs?.connect();
  }

  void _handleWsEvent(ChatWsEvent event) {
    if (_isDisposed || !ref.mounted) return;

    debugPrint(
      '[DOCTOR_WS] EVENT RECEIVED: ${event.runtimeType} | disposed=$_isDisposed | mounted=${ref.mounted}',
    );

    switch (event) {
      case ChatWsConnected(:final userId):
        debugPrint('[WS_CHAT] Connected userId=$userId');
        state = state.copyWith(
          isConnectingWs: false,
          isWsConnected: true,
          connectedUserId: userId,
        );
        _schedulePersistCache();

      case ChatWsMessageReceived(:final message):
        debugPrint(
          '[WS_CHAT] Message received id=${message.id} convId=${message.conversationId} currentConvId=$_conversationId',
        );
        if (message.conversationId.isEmpty ||
            message.conversationId == _conversationId) {
          debugPrint('[WS_CHAT] Appending message');
          _appendOrUpdateMessage(message);
        } else {
          debugPrint('[WS_CHAT] Message IGNORED - conv mismatch');
        }

      case ChatWsConversationUpdated(:final conversation):
        debugPrint('[WS_CHAT] ConversationUpdated id=${conversation.id}');
        ref
            .read(conversationsProvider.notifier)
            .upsertConversation(conversation);
        unawaited(_refreshLatestMessage());

      case ChatWsDisconnected(:final error, :final isAuthError):
        debugPrint(
          '[WS_CHAT] Disconnected error=$error isAuthError=$isAuthError',
        );
        state = state.copyWith(
          isConnectingWs: false,
          isWsConnected: false,
          error: error ?? state.error,
        );
        if (isAuthError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(authProvider.notifier).forceLogout();
          });
        }

      case ChatWsReconnecting():
        debugPrint('[WS_CHAT] Reconnecting...');
        state = state.copyWith(isConnectingWs: true, isWsConnected: false);

      case ChatWsMessageRead(:final readerId):
        debugPrint('[WS_CHAT] MessageRead readerId=$readerId');
        _markIncomingMessagesAsReadForCurrentUser(
          readerId: readerId,
          currentUserIds: _buildCurrentUserIds(),
        );
    }
  }

  void disconnectWs({bool shouldUpdateState = true}) {
    _wsSubscription?.cancel();
    _wsDs?.disconnect();
    if (shouldUpdateState && ref.mounted) {
      state = state.copyWith(isConnectingWs: false, isWsConnected: false);
    }
  }

  bool _isCacheFresh() {
    final cachedAt = _lastHydratedCacheAt;
    if (cachedAt == null) return false;
    return DateTime.now().difference(cachedAt) < _cacheTtl;
  }

  Future<bool> _hydrateFromCache() async {
    try {
      final cache = await ref
          .read(readCachedConversationUseCaseProvider)
          .call(_conversationId);
      if (cache == null || cache.messages.isEmpty) return false;

      _lastHydratedCacheAt = cache.updatedAt;
      state = state.copyWith(
        messages: cache.messages,
        nextHistoryCursor: cache.nextCursor,
        hasMoreHistory: cache.hasMore,
        connectedUserId: cache.connectedUserId,
        clearError: true,
      );
      return true;
    } catch (error) {
      debugPrint('[WS_CHAT][$_conversationId] hydrate cache failed: $error');
      return false;
    }
  }

  void _schedulePersistCache() {
    if (_isDisposed || !ref.mounted) return;
    _cacheDebounceTimer?.cancel();
    _cacheDebounceTimer = Timer(_cacheWriteDebounce, _persistCacheNow);
  }

  Future<void> _persistCacheNow() async {
    if (_isDisposed || !ref.mounted) return;
    final currentMessages = state.messages;
    try {
      if (currentMessages.isEmpty) {
        await ref
            .read(clearCachedConversationUseCaseProvider)
            .call(_conversationId);
        return;
      }
      await ref
          .read(saveCachedConversationUseCaseProvider)
          .call(
            conversationId: _conversationId,
            messages: currentMessages,
            hasMore: state.hasMoreHistory,
            nextCursor: state.nextHistoryCursor,
            connectedUserId: state.connectedUserId,
          );
      _lastHydratedCacheAt = DateTime.now();
    } catch (error) {
      debugPrint('[WS_CHAT][$_conversationId] persist cache failed: $error');
    }
  }

  void _appendOrUpdateMessage(Message message) {
    final items = [...state.messages];
    final index = items.indexWhere((item) => item.id == message.id);
    if (index >= 0) {
      items[index] = message;
    } else {
      items.add(message);
    }
    items.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    state = state.copyWith(messages: items);
    _schedulePersistCache();

    ref.read(conversationsProvider.notifier).updateLastMessage(
      conversationId: _conversationId,
      message: message,
      patientId: _patientId,
    );
  }

  List<Message> _mergeSortedWithoutDuplicates(
    List<Message> older,
    List<Message> current,
  ) {
    final map = <String, Message>{};
    for (final m in [...older, ...current]) {
      map[m.id] = m;
    }
    return map.values.toList()..sort((a, b) => a.sentAt.compareTo(b.sentAt));
  }

  List<Message> _resolveMessagesForDisplay(List<Message> serverMessages) {
    if (serverMessages.isNotEmpty) return serverMessages;
    if (state.messages.isEmpty) return const [];
    return state.messages
        .where((m) => !_isSyntheticConversationStarter(m))
        .toList();
  }

  bool _isSyntheticConversationStarter(Message message) {
    final text = (message.content.text ?? '').trim().toLowerCase();
    return message.type.trim().toLowerCase() == 'text' &&
        text == 'conversation started';
  }

  void _markIncomingMessagesAsReadForCurrentUser({
    required String readerId,
    required Set<String> currentUserIds,
  }) {
    final readerNormalized = (readerId);
    if (readerNormalized.isEmpty ||
        !currentUserIds.contains(readerNormalized)) {
      return;
    }

    var hasChanges = false;
    final updated = state.messages.map((message) {
      final sender = (message.senderId);
      if (currentUserIds.contains(sender)) return message;
      final alreadyRead = message.readByIds.any(
        (id) => (id) == readerNormalized,
      );
      if (alreadyRead) return message;
      hasChanges = true;
      return message.copyWith(readByIds: [...message.readByIds, readerId]);
    }).toList();

    if (!hasChanges) return;
    state = state.copyWith(messages: updated);
    _schedulePersistCache();
  }

  Set<String> _buildCurrentUserIds() {
    final mainId = ref.read(userProvider).user?.id;
    final chatId = state.connectedUserId;
    return {
      if (mainId != null && mainId.isNotEmpty) mainId,
      if (chatId != null && chatId.isNotEmpty) chatId,
    };
  }
}
