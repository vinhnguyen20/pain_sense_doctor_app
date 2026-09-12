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
  bool _showScrollToBottom = false;
  int _newMessagesCountWhileScrolled = 0;

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
    ref
        .read(conversationsProvider.notifier)
        .fetchConversations(showLoading: false);
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

  bool _isAtBottom([double threshold = 60]) {
    if (!_scrollController.hasClients) return true;
    return _scrollController.offset <= threshold;
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;

    final shouldShowButton = offset > 80;
    if (_showScrollToBottom != shouldShowButton) {
      setState(() {
        _showScrollToBottom = shouldShowButton;
        if (!shouldShowButton) {
          _newMessagesCountWhileScrolled = 0;
        }
      });
    } else if (!shouldShowButton && _newMessagesCountWhileScrolled > 0) {
      setState(() {
        _newMessagesCountWhileScrolled = 0;
      });
    }

    // In reverse ListView: top (oldest messages) is at maxScrollExtent
    if (offset >= maxScroll - 140) {
      ref.read(chatRoomProvider(_chatSession).notifier).loadOlderMessages();
    }
  }

  void _scrollToBottom({required bool animated}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      if (animated) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(0.0);
      }

      if (mounted &&
          (_showScrollToBottom || _newMessagesCountWhileScrolled > 0)) {
        setState(() {
          _showScrollToBottom = false;
          _newMessagesCountWhileScrolled = 0;
        });
      }
    });
  }

  void _handleAutoScroll(ChatRoomState? previous, ChatRoomState next) {
    final previousCount = previous?.messages.length ?? 0;
    final currentCount = next.messages.length;
    if (currentCount == 0) return;

    final previousLastId =
        previousCount == 0 ? '' : previous!.messages.last.id;
    final currentLastId = next.messages.last.id;
    final hasNewTailMessage =
        currentCount > previousCount && currentLastId != previousLastId;

    if (!hasNewTailMessage) return;

    if (_isAtBottom()) {
      _scrollToBottom(animated: true);
    } else {
      if (mounted) {
        setState(() {
          _showScrollToBottom = true;
          _newMessagesCountWhileScrolled += (currentCount - previousCount);
        });
      }
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
    final activePatient =
        widget.patient ??
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
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    _buildMessages(
                      state: chatState,
                      liveConversation: liveConversation,
                      patient: activePatient,
                    ),
                    if (_showScrollToBottom)
                      Positioned(
                        bottom: 12,
                        child: _ScrollToBottomButton(
                          newMessagesCount: _newMessagesCountWhileScrolled,
                          onTap: () => _scrollToBottom(animated: true),
                        ),
                      ),
                  ],
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
                  padding: EdgeInsets.all(
                    context.isCompactShell ? AppSpacing.s16 : 30,
                  ),
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
    final isDesktopView = patient != null && !widget.embedded;

    final listView = ListView.builder(
      controller: _scrollController,
      reverse: true,
      cacheExtent: 1200,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktopView ? 0 : 16,
        vertical: isDesktopView ? 20 : 16,
      ),
      itemCount: displayMessages.length + (showPaginationHeader ? 1 : 0),
      itemBuilder: (context, index) {
        if (showPaginationHeader && index == displayMessages.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
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
                        'Pull to load older messages',
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
          padding: EdgeInsets.only(bottom: isDesktopView ? 20 : 12),
          child: ChatMessageBubble(
            patient: patient,
            compact: isDesktopView,
            key: ValueKey(message.id),
            msg: message,
            currentUserIds: currentUserIds,
            currentRole: currentRole,
          ),
        );
      },
    );

    if (isDesktopView) {
      return SizedBox(width: double.infinity, child: listView);
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(chatRoomProvider(_chatSession).notifier).loadHistory(),
      child: listView,
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

class _ScrollToBottomButton extends StatelessWidget {
  final int newMessagesCount;
  final VoidCallback onTap;

  const _ScrollToBottomButton({
    required this.newMessagesCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasNewMessages = newMessagesCount > 0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Material(
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.28),
        shape: hasNewMessages
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))
            : const CircleBorder(),
        color: hasNewMessages ? AppPalette.secondaryBlue : AppPalette.white,
        child: InkWell(
          onTap: onTap,
          customBorder: hasNewMessages
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))
              : const CircleBorder(),
          child: Container(
            padding: hasNewMessages
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
                : const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasNewMessages
                    ? AppPalette.secondaryBlue
                    : AppPalette.medGray.withValues(alpha: 0.5),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: hasNewMessages
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_downward_rounded,
                        size: 16,
                        color: AppPalette.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        newMessagesCount > 1
                            ? '$newMessagesCount new messages'
                            : 'New message',
                        style: context.labelSmall?.copyWith(
                          color: AppPalette.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 24,
                    color: AppPalette.secondaryBlue,
                  ),
          ),
        ),
      ),
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
