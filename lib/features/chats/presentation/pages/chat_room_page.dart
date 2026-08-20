import 'dart:io';

import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/domain/entites/message.dart';
import 'package:app_doctor/features/chats/domain/entites/message_content.dart';
import 'package:app_doctor/features/chats/presentation/provider/chat_room_notifier.dart';
import 'package:app_doctor/features/chats/presentation/provider/conversation_notifier.dart';
import 'package:app_doctor/features/chats/presentation/widgets/chat_message_buble.dart';
import 'package:app_doctor/features/chats/presentation/widgets/message_input_bar.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/presentation/provider/patients_notifier.dart';
import 'package:app_doctor/features/user/presentation/provider/user_notifier.dart';
import 'package:app_doctor/presentations/pages/patient_connect/widgets/patient_connect_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  final Conversation conversation;
  final bool embedded;
  final Patient? patient;

  const ChatRoomPage({
    super.key,
    required this.conversation,
    this.embedded = false,
    this.patient,
  });

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatRoomNotifier _chatRoomController;
  late ChatRoomSession _chatSession;

  @override
  void initState() {
    super.initState();
    _chatSession = _buildChatSession(widget.conversation);
    _chatRoomController = ref.read(chatRoomProvider(_chatSession).notifier);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ChatRoomPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSession = _chatSession;
    final newSession = _buildChatSession(widget.conversation);
    if (oldSession == newSession) return;

    _chatRoomController.disconnectWs(shouldUpdateState: false);
    _chatSession = newSession;
    _chatRoomController = ref.read(chatRoomProvider(_chatSession).notifier);
  }

  @override
  void dispose() {
    _chatRoomController.disconnectWs(shouldUpdateState: false);
    _scrollController.removeListener(_onScroll);
    _messageController.dispose();
    _scrollController.dispose();
    ref.read(conversationsProvider.notifier).fetchConversations(showLoading: false);
    super.dispose();
  }

  ChatRoomSession _buildChatSession(Conversation conversation) {
    final conversationId = conversation.id.trim();
    final participants = conversation.participants
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final currentUserId = ref.read(userProvider).user?.id.trim().toLowerCase();

    String patientId = '';
    if (participants.isNotEmpty) {
      if (currentUserId != null && currentUserId.isNotEmpty) {
        final peer = participants.firstWhere(
          (participant) => participant.toLowerCase() != currentUserId,
          orElse: () => participants.first,
        );
        patientId = peer;
      } else {
        patientId = participants.first;
      }
    }

    return ChatRoomSession(
      conversationId: conversationId,
      patientId: patientId,
    );
  }

  Future<void> _sendText() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    await ref.read(chatRoomProvider(_chatSession).notifier).sendText(text);
    _scrollToBottom(animated: true);
  }

  Future<void> _sendImage(XFile image, String? caption) async {
    await ref
        .read(chatRoomProvider(_chatSession).notifier)
        .sendImage(file: File(image.path), caption: caption);
    _scrollToBottom(animated: true);
  }

  bool _isNearBottom([double threshold = 180]) {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    final isDesktop = widget.patient != null && !widget.embedded;
    if (isDesktop) {
      return (position.maxScrollExtent - position.pixels) <= threshold;
    }
    return position.pixels <= threshold;
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final isDesktop = widget.patient != null && !widget.embedded;
    if (isDesktop) {
      if (position.pixels > 140) return;
    } else {
      if (position.pixels < position.maxScrollExtent - 140) return;
    }
    ref.read(chatRoomProvider(_chatSession).notifier).loadOlderMessages();
  }

  void _scrollToBottom({required bool animated}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final isDesktop = widget.patient != null && !widget.embedded;
      final target = isDesktop
          ? _scrollController.position.maxScrollExtent
          : 0.0;

      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  void _handleAutoScroll(ChatRoomState? previous, ChatRoomState next) {
    final previousCount = previous?.messages.length ?? 0;
    final currentCount = next.messages.length;
    if (currentCount == 0) return;

    final previousLastId = previousCount == 0 ? '' : previous!.messages.last.id;
    final currentLastId = next.messages.last.id;
    final hasNewTailMessage =
        currentCount > previousCount && currentLastId != previousLastId;

    if (!hasNewTailMessage) return;
    if (_isNearBottom()) {
      _scrollToBottom(animated: true);
    }
  }

  Patient? _resolvePatientFromId(List<Patient> patients, String patientId) {
    if (patientId.isEmpty) return null;
    for (final p in patients) {
      if (p.id == patientId) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ChatRoomState>(
      chatRoomProvider(_chatSession),
      _handleAutoScroll,
    );

    final chatState = ref.watch(chatRoomProvider(_chatSession));
    final liveConversation = _resolveLiveConversation(
      fallback: widget.conversation,
      items: ref.watch(conversationsProvider).conversations,
    );
    final patientActivity = _resolvePatientActivityStatus(
      context,
      liveConversation,
    );
    final activePatient = widget.patient ??
        _resolvePatientFromId(
          ref.watch(patientsProvider).patients,
          _chatSession.patientId,
        );
    final isInitialLoading =
        chatState.isLoadingHistory && chatState.messages.isEmpty;
    final isPatientDashboardChat = GoRouterState.of(
      context,
    ).uri.path.startsWith('/patient-connect');

    final body = isInitialLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.embedded && activePatient != null) ...[
                PatientConnectHeader(
                  patient: activePatient,
                  showBackButton: true,
                  onBack: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (isPatientDashboardChat) {
                      context.go('/patient-connect', extra: activePatient);
                    } else {
                      context.go('/connect');
                    }
                  },
                ),
              ],
              Expanded(
                child: _buildMessages(
                  state: chatState,
                  liveConversation: liveConversation,
                  patient: activePatient,
                ),
              ),
              if (!widget.embedded && activePatient != null)
                const SizedBox(height: 40),
              MessageInputBar(
                controller: _messageController,
                onSend: _sendText,
                onSendWithImages: _sendImage,
                compact: !widget.embedded && activePatient != null,
              ),
            ],
          );

    if (widget.embedded) {
      return Container(color: context.background, child: body);
    }

    if (activePatient != null) {
      return Scaffold(
        backgroundColor: AppPalette.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: SizedBox(width: double.infinity, child: body),
                ),
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        toolbarHeight: 74,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(liveConversation.name),
            const SizedBox(height: 4),
            _PatientActivityBadge(status: patientActivity),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                chatState.isWsConnected
                    ? 'Realtime On'
                    : chatState.isConnectingWs
                    ? 'Connecting...'
                    : 'Realtime Off',
                style: context.labelSmall?.copyWith(
                  color: chatState.isWsConnected
                      ? context.chatColors.online
                      : context.chatColors.offline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: body,
    );
  }

  Conversation _resolveLiveConversation({
    required Conversation fallback,
    required List<Conversation> items,
  }) {
    final targetId = fallback.id.trim();
    for (final item in items) {
      if (item.id.trim() == targetId) {
        return item;
      }
    }
    return fallback;
  }

  _PatientActivityStatus _resolvePatientActivityStatus(
    BuildContext context,
    Conversation conversation,
  ) {
    final patientId = _chatSession.patientId;
    if (patientId.isEmpty) {
      return _PatientActivityStatus(
        label: 'Activity unavailable',
        color: context.chatColors.offline,
      );
    }

    DateTime? lastPatientReadAt;
    for (final info in conversation.unreadInfo) {
      if (info.userId == patientId) {
        lastPatientReadAt = info.lastReadAt?.toLocal();
        break;
      }
    }

    DateTime? lastPatientMessageAt;
    final lastMessage = conversation.lastMessage;
    if (lastMessage != null && lastMessage.sendBy == patientId) {
      lastPatientMessageAt = lastMessage.sentAt.toLocal();
    }

    DateTime? latestActivity = lastPatientReadAt;
    if (lastPatientMessageAt != null &&
        (latestActivity == null ||
            lastPatientMessageAt.isAfter(latestActivity))) {
      latestActivity = lastPatientMessageAt;
    }

    if (latestActivity == null) {
      return _PatientActivityStatus(
        label: 'No recent activity',
        color: context.chatColors.offline,
      );
    }

    final now = DateTime.now();
    final diff = now.difference(latestActivity);
    if (diff.inMinutes <= 2) {
      return _PatientActivityStatus(
        label: 'Active now',
        color: context.chatColors.online,
      );
    }
    if (diff.inMinutes <= 30) {
      return _PatientActivityStatus(
        label: 'Active ${diff.inMinutes} min ago',
        color: context.chatColors.online,
      );
    }

    final isToday =
        now.year == latestActivity.year &&
        now.month == latestActivity.month &&
        now.day == latestActivity.day;
    if (isToday) {
      return _PatientActivityStatus(
        label: 'Active today at ${DateFormat('HH:mm').format(latestActivity)}',
        color: context.chatColors.incomingMeta,
      );
    }

    return _PatientActivityStatus(
      label: 'Last active ${DateFormat('dd/MM HH:mm').format(latestActivity)}',
      color: context.chatColors.offline,
    );
  }

  Widget _buildMessages({
    required ChatRoomState state,
    required Conversation liveConversation,
    required Patient? patient,
  }) {
    final fallbackMessage = _buildFallbackMessageFromConversation(
      liveConversation,
    );
    final displayMessages = state.messages.isNotEmpty
        ? state.messages
        : (fallbackMessage == null ? const <Message>[] : [fallbackMessage]);

    if (displayMessages.isEmpty) {
      final emptyText =
          state.error ??
          'No messages yet. Type a message below to start the conversation.';
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            emptyText,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final userState = ref.watch(userProvider);
    final currentMainUserId = userState.user?.id ?? '';
    final currentChatUserId = state.connectedUserId ?? '';
    final currentUserIds = <String>{
      if (currentMainUserId.isNotEmpty) currentMainUserId,
      if (currentChatUserId.isNotEmpty) currentChatUserId,
    };
    final currentRole = userState.user?.authInfo?.role;

    final showPaginationHeader =
        state.hasMoreHistory || state.isLoadingMoreHistory;

    if (patient != null && !widget.embedded) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 972),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showPaginationHeader)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Center(
                      child: state.isLoadingMoreHistory
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Pull to load older messages',
                              style: context.labelSmall?.copyWith(
                                color: context.onSurface.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                            ),
                    ),
                  ),
                for (int i = 0; i < displayMessages.length; i++) ...[
                  if (i > 0) const SizedBox(height: 20),
                  ChatMessageBubble(
                    patient: patient,
                    compact: true,
                    key: ValueKey(displayMessages[i].id),
                    msg: displayMessages[i],
                    currentUserIds: currentUserIds,
                    currentRole: currentRole,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(chatRoomProvider(_chatSession).notifier).loadHistory(),
      child: ListView.builder(
        controller: _scrollController,
        reverse: true,
        cacheExtent: 1200,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        itemCount: displayMessages.length + (showPaginationHeader ? 1 : 0),
        itemBuilder: (context, index) {
          if (showPaginationHeader && index == displayMessages.length) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 24,
                child: Center(
                  child: state.isLoadingMoreHistory
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Pull up to load older messages',
                          style: context.labelSmall?.copyWith(
                            color: context.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                ),
              ),
            );
          }

          final messageIndex = displayMessages.length - 1 - index;
          final message = displayMessages[messageIndex];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ChatMessageBubble(
                  patient: patient,
                  compact: false,
                  key: ValueKey(message.id),
                  msg: message,
                  currentUserIds: currentUserIds,
                  currentRole: currentRole,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Message? _buildFallbackMessageFromConversation(Conversation conversation) {
    final lastMessage = conversation.lastMessage;
    if (lastMessage == null) return null;

    final text = lastMessage.text.trim();
    if (text.isEmpty) return null;

    return Message(
      id: 'fallback_${conversation.id}_${lastMessage.sentAt.toUtc().millisecondsSinceEpoch}',
      conversationId: conversation.id.trim(),
      senderId: lastMessage.sendBy.trim(),
      sentAt: lastMessage.sentAt.toUtc(),
      readByIds: const <String>[],
      status: 'sent',
      type: 'text',
      content: MessageContent(text: text),
    );
  }
}

class _PatientActivityStatus {
  final String label;
  final Color color;

  const _PatientActivityStatus({required this.label, required this.color});
}

class _PatientActivityBadge extends StatelessWidget {
  final _PatientActivityStatus status;

  const _PatientActivityBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = status.color.withValues(alpha: 0.14);
    final borderColor = status.color.withValues(alpha: 0.36);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
