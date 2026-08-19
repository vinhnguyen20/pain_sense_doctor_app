import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/domain/entites/last_message.dart';
import 'package:app_doctor/features/chats/domain/entites/message.dart';
import 'package:app_doctor/features/chats/presentation/provider/chat_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversation_notifier.g.dart';

class ConversationsState {
  final List<Conversation> conversations;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  ConversationsState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : error ?? this.error,
    );
  }
}

@riverpod
class ConversationsNotifier extends _$ConversationsNotifier {
  static const int _conversationsLimit = 10;

  @override
  ConversationsState build() {
    return const ConversationsState();
  }

  Future<void> fetchConversations({bool showLoading = true}) async {
    if (state.isLoading) return;

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

      final conversations = [...response.data!];
      _sortConversationsByLatest(conversations);

      state = state.copyWith(
        conversations: conversations,
        isLoading: false,
        clearError: true,
      );
    } finally {
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
    final index = items.indexWhere((item) => item.id == conversation.id);
    if (index >= 0) {
      items[index] = conversation;
    } else {
      items.insert(0, conversation);
    }

    _sortConversationsByLatest(items);
    state = state.copyWith(conversations: items);
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
        (c) => c.participants.any((p) => p.trim().toLowerCase() == normalizedPatientId),
      );
    }

    if (foundIndex >= 0) {
      final existing = items[foundIndex];
      final updated = _withLastMessageFromMessage(existing, message);
      items[foundIndex] = updated;
      _sortConversationsByLatest(items);
      state = state.copyWith(conversations: items);
    } else if (normalizedConvId.isNotEmpty || normalizedPatientId.isNotEmpty) {
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
        unreadCountDoctor: 0,
        unreadCountPatient: 0,
        unreadInfo: const [],
      );
      items.insert(0, newConv);
      _sortConversationsByLatest(items);
      state = state.copyWith(conversations: items);
    }
  }

  Conversation? _findConversationByParticipant({
    required String participantId,
    required List<Conversation> source,
  }) {
    for (final conversation in source) {
      final hasParticipant = conversation.participants.any(
        (participant) => (participant) == participantId,
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
