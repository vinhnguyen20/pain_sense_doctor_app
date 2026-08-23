import 'dart:async';
import 'dart:collection';

import 'package:app_doctor/core/services/auth/token_service.dart';
import 'package:app_doctor/features/chats/data/datasources/chat_ws_datasource.dart';
import 'package:app_doctor/features/chats/data/models/chat_ws_event.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/domain/entites/last_message.dart';
import 'package:app_doctor/features/chats/domain/entites/message.dart';
import 'package:app_doctor/features/chats/domain/entites/un_read_info.dart';
import 'package:app_doctor/features/chats/presentation/provider/chat_providers.dart';
import 'package:app_doctor/features/user/presentation/provider/patients_notifier.dart';
import 'package:app_doctor/features/user/presentation/provider/user_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversation_notifier.g.dart';

class ConversationsState {
  final List<Conversation> conversations;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final Set<String> realtimeUserIds;

  const ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.realtimeUserIds = const {},
  });

  int get totalUnreadCount => conversations.fold<int>(
    0,
    (sum, conv) =>
        sum + (conv.unreadCountDoctor > 0 ? conv.unreadCountDoctor : 0),
  );

  ConversationsState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    Set<String>? realtimeUserIds,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : error ?? this.error,
      realtimeUserIds: realtimeUserIds ?? this.realtimeUserIds,
    );
  }
}

final unreadMessagesCountProvider = Provider<int>((ref) {
  final conversationsState = ref.watch(conversationsProvider);
  final currentDoctorId =
      ref.watch(userProvider).user?.id.trim().toLowerCase() ?? '';
  final currentUserIds = <String>{
    if (currentDoctorId.isNotEmpty) currentDoctorId,
    ...conversationsState.realtimeUserIds,
  };
  final knownPatientIds = ref
      .watch(patientsProvider)
      .patients
      .map((patient) => patient.id);

  return conversationsState.conversations.fold<int>(
    0,
    (sum, conv) =>
        sum +
        resolveDoctorUnreadCount(
          conv,
          currentUserIds: currentUserIds,
          knownPatientIds: knownPatientIds,
        ),
  );
});

int resolveDoctorUnreadCount(
  Conversation conversation, {
  Iterable<String> currentUserIds = const [],
  Iterable<String> knownPatientIds = const [],
  String? patientId,
}) {
  final normalizedCurrentIds = currentUserIds
      .map((id) => id.trim().toLowerCase())
      .where((id) => id.isNotEmpty)
      .toSet();
  final normalizedPatientId = patientId?.trim().toLowerCase() ?? '';
  final participantIds = conversation.participants
      .map((id) => id.trim().toLowerCase())
      .where((id) => id.isNotEmpty)
      .toSet();
  final normalizedKnownPatientIds = knownPatientIds
      .map((id) => id.trim().toLowerCase())
      .where((id) => id.isNotEmpty)
      .toSet();
  final patientIds = <String>{
    if (normalizedPatientId.isNotEmpty) normalizedPatientId,
    ...participantIds.where(normalizedKnownPatientIds.contains),
  };
  if (patientIds.isEmpty) {
    patientIds.addAll(
      participantIds.where((id) => !normalizedCurrentIds.contains(id)),
    );
  }

  final lastSender =
      conversation.lastMessage?.sendBy.trim().toLowerCase() ?? '';
  if (lastSender.isNotEmpty) {
    if (normalizedCurrentIds.contains(lastSender)) return 0;
    // Chat-service user ids are not always the same as patient API ids. Once
    // the current doctor's ids are known, every other sender is incoming.
    if (normalizedCurrentIds.isEmpty &&
        patientIds.isNotEmpty &&
        !patientIds.contains(lastSender)) {
      return 0;
    }
  }

  if (conversation.unreadCountDoctor > 0) {
    return conversation.unreadCountDoctor;
  }

  var patientUnread = 0;
  for (final info in conversation.unreadInfo) {
    final infoUserId = info.userId.trim().toLowerCase();
    if (patientIds.contains(infoUserId) && info.count > patientUnread) {
      patientUnread = info.count;
    }
  }
  return patientUnread;
}

@riverpod
class ConversationsNotifier extends _$ConversationsNotifier {
  static const int _conversationsLimit = 100;
  static const int _processedMessageLimit = 500;

  Timer? _periodicSyncTimer;
  final Map<String, ChatWsDataSource> _wsConnections = {};
  final Map<String, StreamSubscription> _wsSubscriptions = {};
  final LinkedHashSet<String> _processedMessageIds = LinkedHashSet();
  final Set<String> _pendingReadConversationIds = {};
  bool _isDisposed = false;
  bool _isFetching = false;

  @override
  ConversationsState build() {
    _isDisposed = false;
    ref.onDispose(() {
      _isDisposed = true;
      _periodicSyncTimer?.cancel();
      for (final sub in _wsSubscriptions.values) {
        sub.cancel();
      }
      _wsSubscriptions.clear();
      for (final ds in _wsConnections.values) {
        ds.dispose();
      }
      _wsConnections.clear();
      _processedMessageIds.clear();
      _pendingReadConversationIds.clear();
    });

    Future.microtask(() {
      fetchConversations(showLoading: false);
      _startPeriodicSync();
    });

    return const ConversationsState();
  }

  void _startPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_isDisposed || !ref.mounted) return;
      fetchConversations(showLoading: false);
    });
  }

  void _syncWsConnections(List<Conversation> conversations) {
    if (_isDisposed || !ref.mounted) return;
    final currentIds = conversations
        .map((c) => c.id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    // Clean up removed conversations
    final toRemove = _wsConnections.keys
        .where((id) => !currentIds.contains(id))
        .toList();
    for (final id in toRemove) {
      _wsSubscriptions[id]?.cancel();
      _wsSubscriptions.remove(id);
      _wsConnections[id]?.dispose();
      _wsConnections.remove(id);
    }

    for (final conv in conversations) {
      final convId = conv.id.trim();
      if (convId.isEmpty) continue;
      final ws = _ensureWsConnection(convId);
      unawaited(ws.connect());
    }
  }

  ChatWsDataSource _ensureWsConnection(String conversationId) {
    final normalizedId = conversationId.trim();
    final existing = _wsConnections[normalizedId];
    if (existing != null) return existing;

    final chatDs = ref.read(chatRemoteDataSourceProvider);
    final ws = ChatWsDataSource(
      conversationId: normalizedId,
      getAccessToken: () =>
          ref.read(tokenServiceProvider.notifier).getAccessToken(),
      parseMessage: chatDs.parseMessage,
      parseConversation: chatDs.parseConversation,
    );
    _wsConnections[normalizedId] = ws;
    _wsSubscriptions[normalizedId] = ws.events.listen(
      (event) => _handleWsEvent(normalizedId, event),
      onError: (_) {},
    );
    return ws;
  }

  ChatWsDataSource? realtimeConnectionFor(String conversationId) {
    final normalizedId = conversationId.trim();
    if (normalizedId.isEmpty || _isDisposed || !ref.mounted) return null;
    final ws = _ensureWsConnection(normalizedId);
    unawaited(ws.connect());
    return ws;
  }

  void _handleWsEvent(String conversationId, ChatWsEvent event) {
    if (_isDisposed || !ref.mounted) return;
    switch (event) {
      case ChatWsConnected(:final userId):
        final normalizedUserId = userId?.trim().toLowerCase() ?? '';
        if (normalizedUserId.isNotEmpty &&
            !state.realtimeUserIds.contains(normalizedUserId)) {
          state = state.copyWith(
            realtimeUserIds: {...state.realtimeUserIds, normalizedUserId},
          );
          final updatedConversations = state.conversations.map((conversation) {
            if (!_pendingReadConversationIds.contains(
              conversation.id.trim().toLowerCase(),
            )) {
              return conversation;
            }
            return conversation.copyWith(
              unreadCountDoctor: 0,
              unreadInfo: _clearPatientUnreadInfo(conversation),
            );
          }).toList();
          state = state.copyWith(conversations: updatedConversations);
        }
      case ChatWsMessageReceived(:final message):
        updateLastMessage(conversationId: conversationId, message: message);
      case ChatWsConversationUpdated(:final conversation):
        upsertConversation(conversation);
      case ChatWsMessageRead(:final readerId):
        if (_currentUserIds().contains(readerId.trim().toLowerCase())) {
          clearUnreadCount(conversationId);
        }
      default:
        break;
    }
  }

  Future<void> fetchConversations({bool showLoading = true}) async {
    if (_isFetching) return;
    _isFetching = true;

    final link = ref.keepAlive();
    state = state.copyWith(isLoading: showLoading, clearError: true);

    try {
      final response = await ref
          .read(getConversationsUseCaseProvider)
          .call(limit: _conversationsLimit);

      if (!ref.mounted) return;

      if (response.isFailure || response.data == null) {
        state = state.copyWith(isLoading: false, error: response.message);
        return;
      }

      final conversations = _mergeServerConversations(response.data!);
      _sortConversationsByLatest(conversations);

      state = state.copyWith(
        conversations: conversations,
        isLoading: false,
        clearError: true,
      );
      _syncWsConnections(conversations);
    } finally {
      _isFetching = false;
      link.close();
    }
  }

  Future<Conversation?> getOrCreateConversationWithParticipant({
    required String participantId,
  }) async {
    final normalizedParticipantId = participantId.trim();
    if (normalizedParticipantId.isEmpty) {
      state = state.copyWith(error: 'Patient id is missing from API response');
      return null;
    }

    final link = ref.keepAlive();
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final existing = await getConversationWithParticipant(
        participantId: normalizedParticipantId,
      );
      if (existing != null) {
        return existing;
      }

      state = state.copyWith(
        error:
            'Conversation does not exist yet. Send the first message to create it.',
      );
      return null;
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isSubmitting: false);
      }
      link.close();
    }
  }

  Future<Conversation?> getConversationWithParticipant({
    required String participantId,
  }) async {
    final normalizedParticipantId = participantId.trim();
    if (normalizedParticipantId.isEmpty) {
      state = state.copyWith(error: 'Patient id is missing from API response');
      return null;
    }

    var existing = _findConversationByParticipant(
      participantId: normalizedParticipantId,
      source: state.conversations,
    );
    if (existing != null) {
      return existing;
    }

    await fetchConversations(showLoading: false);
    if (!ref.mounted) return null;

    existing = _findConversationByParticipant(
      participantId: normalizedParticipantId,
      source: state.conversations,
    );
    return existing;
  }

  Future<Conversation?> createConversationAndSendFirstMessage({
    required String participantId,
    required String firstMessage,
  }) async {
    final normalizedParticipantId = participantId.trim();
    final normalizedMessage = firstMessage.trim();

    if (normalizedParticipantId.isEmpty) {
      state = state.copyWith(error: 'Patient id is missing from API response');
      return null;
    }
    if (normalizedMessage.isEmpty) {
      state = state.copyWith(error: 'Message cannot be empty');
      return null;
    }

    final link = ref.keepAlive();
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      Conversation? conversation = await getConversationWithParticipant(
        participantId: normalizedParticipantId,
      );
      if (!ref.mounted) return null;

      if (conversation == null) {
        final createResponse = await ref
            .read(createConversationUseCaseProvider)
            .call(
              participantId: normalizedParticipantId,
              initialMessageText: normalizedMessage,
            );

        if (!ref.mounted) return null;

        if (createResponse.isFailure || createResponse.data == null) {
          state = state.copyWith(error: createResponse.message);
          return null;
        }

        conversation = createResponse.data!;
        upsertConversation(conversation);
        return conversation;
      }

      final sendResponse = await ref
          .read(sendTextMessageUseCaseProvider)
          .call(conversationId: conversation.id, text: normalizedMessage);

      if (!ref.mounted) return null;

      if (sendResponse.isFailure) {
        state = state.copyWith(error: sendResponse.message);
        return null;
      }

      final sentMessage = sendResponse.data;
      final updatedConversation = sentMessage == null
          ? conversation
          : _withLastMessageFromMessage(conversation, sentMessage);

      upsertConversation(updatedConversation);
      return updatedConversation;
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isSubmitting: false);
      }
      link.close();
    }
  }

  void upsertConversation(Conversation conversation) {
    final items = [...state.conversations];
    final index = items.indexWhere((item) => _sameId(item.id, conversation.id));
    if (index >= 0) {
      items[index] = _mergeServerConversation(items[index], conversation);
    } else {
      items.insert(0, _normalizeServerUnread(conversation));
    }

    _sortConversationsByLatest(items);
    state = state.copyWith(conversations: items);
    _syncWsConnections(items);
  }

  void clearUnreadCount(String conversationId, [String? patientId]) {
    final normalizedConvId = conversationId.trim();
    final normalizedPatientId = patientId?.trim().toLowerCase() ?? '';
    if (normalizedConvId.isEmpty && normalizedPatientId.isEmpty) return;

    final items = [...state.conversations];
    var index = -1;
    if (normalizedConvId.isNotEmpty) {
      index = items.indexWhere((c) => c.id.trim() == normalizedConvId);
    }
    if (index < 0 && normalizedPatientId.isNotEmpty) {
      index = items.indexWhere(
        (c) => c.participants.any(
          (p) => p.trim().toLowerCase() == normalizedPatientId,
        ),
      );
    }

    if (index >= 0) {
      final current = items[index];
      if (current.id.trim().isNotEmpty) {
        _pendingReadConversationIds.add(current.id.trim().toLowerCase());
      }

      items[index] = current.copyWith(
        unreadCountDoctor: 0,
        unreadInfo: _clearPatientUnreadInfo(
          current,
          patientId: normalizedPatientId,
        ),
      );
      state = state.copyWith(conversations: items);
    }
  }

  void incrementUnreadCount(String conversationId) {
    final normalizedConvId = conversationId.trim();
    if (normalizedConvId.isEmpty) return;

    final items = [...state.conversations];
    final index = items.indexWhere((c) => c.id.trim() == normalizedConvId);
    if (index >= 0) {
      items[index] = items[index].copyWith(
        unreadCountDoctor: items[index].unreadCountDoctor + 1,
      );
      state = state.copyWith(conversations: items);
    }
  }

  void updateLastMessage({
    required String conversationId,
    required Message message,
    String? patientId,
  }) {
    final normalizedConvId = conversationId.trim();
    final normalizedPatientId = patientId?.trim().toLowerCase() ?? '';

    final items = [...state.conversations];
    var foundIndex = -1;

    if (normalizedConvId.isNotEmpty) {
      foundIndex = items.indexWhere((c) => c.id.trim() == normalizedConvId);
    }

    if (foundIndex < 0 && normalizedPatientId.isNotEmpty) {
      foundIndex = items.indexWhere(
        (c) => c.participants.any(
          (p) => p.trim().toLowerCase() == normalizedPatientId,
        ),
      );
    }

    final isNewMessage = _rememberMessage(message);

    if (foundIndex >= 0) {
      final existing = items[foundIndex];
      final isFromPatient = _isSenderPatient(
        senderId: message.senderId,
        conversation: existing,
        patientId: normalizedPatientId,
      );
      if (isNewMessage && isFromPatient) {
        _pendingReadConversationIds.remove(existing.id.trim().toLowerCase());
      }
      final unreadInc = isNewMessage && isFromPatient ? 1 : 0;
      final unreadCount = isFromPatient
          ? existing.unreadCountDoctor + unreadInc
          : 0;
      final updated = _withLastMessageFromMessage(
        existing.copyWith(
          unreadCountDoctor: unreadCount,
          unreadInfo: isFromPatient
              ? existing.unreadInfo
              : _clearPatientUnreadInfo(
                  existing,
                  patientId: normalizedPatientId,
                ),
        ),
        message,
      );
      items[foundIndex] = updated;
      _sortConversationsByLatest(items);
      state = state.copyWith(conversations: items);
    } else if (normalizedConvId.isNotEmpty || normalizedPatientId.isNotEmpty) {
      final isFromPatient =
          normalizedPatientId.isNotEmpty &&
          _sameId(message.senderId, normalizedPatientId);
      final newConv = Conversation(
        id: normalizedConvId,
        name: message.senderId,
        participants: [
          if (normalizedPatientId.isNotEmpty) normalizedPatientId,
          if (message.senderId.isNotEmpty &&
              message.senderId.toLowerCase() != normalizedPatientId)
            message.senderId,
        ],
        lastMessage: LastMessage(
          text: _resolveLastMessageText(message),
          sentAt: message.sentAt,
          sendBy: message.senderId,
        ),
        status: 'active',
        unreadCountDoctor: isFromPatient ? 1 : 0,
        unreadCountPatient: 0,
        unreadInfo: const [],
      );
      items.insert(0, newConv);
      _sortConversationsByLatest(items);
      state = state.copyWith(conversations: items);
      _syncWsConnections(items);
    }
  }

  Conversation? _findConversationByParticipant({
    required String participantId,
    required List<Conversation> source,
  }) {
    for (final conversation in source) {
      final hasParticipant = conversation.participants.any(
        (participant) => _sameId(participant, participantId),
      );
      if (hasParticipant) {
        return conversation;
      }
    }
    return null;
  }

  Conversation _withLastMessageFromMessage(
    Conversation conversation,
    Message message,
  ) {
    final currentLastMessage = conversation.lastMessage;
    if (currentLastMessage != null &&
        currentLastMessage.sentAt.isAfter(message.sentAt)) {
      return conversation;
    }
    return Conversation(
      id: conversation.id,
      name: conversation.name,
      participants: conversation.participants,
      lastMessage: LastMessage(
        text: _resolveLastMessageText(message),
        sentAt: message.sentAt,
        sendBy: message.senderId,
      ),
      status: conversation.status,
      unreadCountDoctor: conversation.unreadCountDoctor,
      unreadCountPatient: conversation.unreadCountPatient,
      unreadInfo: conversation.unreadInfo,
    );
  }

  String _resolveLastMessageText(Message message) {
    final text = (message.content.text ?? '').trim();
    if (text.isNotEmpty) return text;

    switch (message.type.trim().toLowerCase()) {
      case 'image':
        return 'Sent an image';
      case 'video':
        return 'Sent a video';
      default:
        return 'Sent a message';
    }
  }

  List<Conversation> _mergeServerConversations(
    List<Conversation> serverConversations,
  ) {
    final localById = <String, Conversation>{
      for (final conversation in state.conversations)
        conversation.id.trim().toLowerCase(): conversation,
    };
    final merged = <Conversation>[];
    final receivedIds = <String>{};

    for (final serverConversation in serverConversations) {
      final id = serverConversation.id.trim().toLowerCase();
      if (id.isEmpty) continue;
      receivedIds.add(id);
      final local = localById[id];
      merged.add(
        local == null
            ? _normalizeServerUnread(serverConversation)
            : _mergeServerConversation(local, serverConversation),
      );
    }

    // The API is limited/paginated. Keep locally-known conversations so a
    // polling response cannot make their realtime state and badges disappear.
    for (final local in state.conversations) {
      final id = local.id.trim().toLowerCase();
      if (id.isNotEmpty && !receivedIds.contains(id)) merged.add(local);
    }
    return merged;
  }

  Conversation _mergeServerConversation(
    Conversation local,
    Conversation server,
  ) {
    final normalizedServer = _normalizeServerUnread(server);
    final id = local.id.trim().toLowerCase();
    final serverUnread = resolveDoctorUnreadCount(
      normalizedServer,
      currentUserIds: _currentUserIds(),
      knownPatientIds: _knownPatientIds(),
    );
    final isReadPending = _pendingReadConversationIds.contains(id);

    if (isReadPending && serverUnread == 0) {
      _pendingReadConversationIds.remove(id);
    }

    final localTime = local.lastMessage?.sentAt;
    final serverTime = normalizedServer.lastMessage?.sentAt;
    final localIsAtLeastAsNew =
        localTime != null &&
        (serverTime == null || !localTime.isBefore(serverTime));
    final preserveRead = isReadPending && serverUnread > 0;
    final candidateUnread = preserveRead
        ? 0
        : localIsAtLeastAsNew
        ? (local.unreadCountDoctor > serverUnread
              ? local.unreadCountDoctor
              : serverUnread)
        : serverUnread;
    final selectedLastMessage = localIsAtLeastAsNew
        ? local.lastMessage
        : normalizedServer.lastMessage;
    final selectedLastIsFromPatient =
        selectedLastMessage == null ||
        _isSenderPatient(
          senderId: selectedLastMessage.sendBy,
          conversation: normalizedServer,
        );
    final effectiveUnread = selectedLastIsFromPatient ? candidateUnread : 0;

    return normalizedServer.copyWith(
      lastMessage: selectedLastMessage,
      unreadCountDoctor: effectiveUnread,
      unreadInfo: preserveRead
          ? _clearPatientUnreadInfo(normalizedServer)
          : normalizedServer.unreadInfo,
    );
  }

  Conversation _normalizeServerUnread(Conversation conversation) {
    final resolvedUnread = resolveDoctorUnreadCount(
      conversation,
      currentUserIds: _currentUserIds(),
      knownPatientIds: _knownPatientIds(),
    );
    if (resolvedUnread == conversation.unreadCountDoctor) return conversation;
    return conversation.copyWith(unreadCountDoctor: resolvedUnread);
  }

  List<UnReadInfo> _clearPatientUnreadInfo(
    Conversation conversation, {
    String? patientId,
  }) {
    final patientIds = _patientIdsFor(conversation, patientId: patientId);
    if (patientIds.isEmpty) return conversation.unreadInfo;
    return conversation.unreadInfo.map((info) {
      if (!patientIds.contains(info.userId.trim().toLowerCase())) {
        return info;
      }
      return UnReadInfo(
        userId: info.userId,
        count: 0,
        lastReadAt: info.lastReadAt,
      );
    }).toList();
  }

  bool _isSenderPatient({
    required String senderId,
    required Conversation conversation,
    String? patientId,
  }) {
    final normalizedSenderId = senderId.trim().toLowerCase();
    if (normalizedSenderId.isEmpty) return false;
    final currentUserIds = _currentUserIds();
    if (currentUserIds.contains(normalizedSenderId)) return false;
    final patientIds = _patientIdsFor(conversation, patientId: patientId);
    if (patientIds.contains(normalizedSenderId)) return true;
    return currentUserIds.isNotEmpty;
  }

  Set<String> _patientIdsFor(Conversation conversation, {String? patientId}) {
    final currentUserIds = _currentUserIds();
    final normalizedPatientId = patientId?.trim().toLowerCase() ?? '';
    final participantIds = conversation.participants
        .map((id) => id.trim().toLowerCase())
        .where((id) => id.isNotEmpty)
        .toSet();
    final knownPatientIds = _knownPatientIds();
    final result = <String>{
      if (normalizedPatientId.isNotEmpty) normalizedPatientId,
      ...participantIds.where(knownPatientIds.contains),
    };
    if (result.isEmpty) {
      result.addAll(participantIds.where((id) => !currentUserIds.contains(id)));
    }
    return result;
  }

  Set<String> _knownPatientIds() => ref
      .read(patientsProvider)
      .patients
      .map((patient) => patient.id.trim().toLowerCase())
      .where((id) => id.isNotEmpty)
      .toSet();

  Set<String> _currentUserIds() {
    final mainUserId =
        ref.read(userProvider).user?.id.trim().toLowerCase() ?? '';
    return {if (mainUserId.isNotEmpty) mainUserId, ...state.realtimeUserIds};
  }

  bool _rememberMessage(Message message) {
    final id = message.id.trim().toLowerCase();
    final key = id.isNotEmpty
        ? id
        : '${message.conversationId}|${message.senderId}|${message.sentAt.toUtc().toIso8601String()}';
    if (!_processedMessageIds.add(key)) return false;
    while (_processedMessageIds.length > _processedMessageLimit) {
      _processedMessageIds.remove(_processedMessageIds.first);
    }
    return true;
  }

  bool _sameId(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  void _sortConversationsByLatest(List<Conversation> items) {
    items.sort((a, b) {
      final aTime = a.lastMessage?.sentAt;
      final bTime = b.lastMessage?.sentAt;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });
  }
}
