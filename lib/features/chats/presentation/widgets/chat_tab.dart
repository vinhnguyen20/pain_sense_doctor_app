import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/presentation/pages/chat_room_page.dart';
import 'package:app_doctor/features/chats/presentation/provider/conversation_notifier.dart';
import 'package:app_doctor/features/user/presentation/provider/user_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChatTab extends ConsumerStatefulWidget {
  const ChatTab({super.key});

  @override
  ConsumerState<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<ChatTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(conversationsProvider.notifier).fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationsState = ref.watch(conversationsProvider);
    final currentUserId = ref.watch(userProvider).user?.id;

    if (conversationsState.isLoading &&
        conversationsState.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (conversationsState.conversations.isEmpty) {
      return Center(
        child: Text(
          conversationsState.error ?? 'No conversations yet',
          style: context.bodyMedium,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(conversationsProvider.notifier).fetchConversations(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: conversationsState.conversations.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final conversation = conversationsState.conversations[index];
          return _ConversationCard(
            conversation: conversation,
            unreadCount: _getUnreadCount(conversation, currentUserId),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatRoomPage(conversation: conversation),
                ),
              );
            },
          );
        },
      ),
    );
  }

  int _getUnreadCount(Conversation conversation, String? currentUserId) {
    if (currentUserId == null) return 0;
    for (final item in conversation.unreadInfo) {
      if (item.userId == currentUserId) {
        return item.count;
      }
    }
    return 0;
  }
}

class _ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final int unreadCount;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.conversation,
    required this.unreadCount,
    required this.onTap,
  });

  String _previewText(lastMessage) {
    if (lastMessage == null) return 'No messages yet';
    return switch (lastMessage.type?.toLowerCase()) {
      'image' => '📷 Image',
      'video' => '🎥 Video',
      _ => lastMessage.text.isNotEmpty ? lastMessage.text : 'Message',
    };
  }

  @override
  Widget build(BuildContext context) {
    final lastMessage = conversation.lastMessage;
    final timeText = lastMessage?.sentAt != null
        ? DateFormat('HH:mm').format(lastMessage!.sentAt)
        : '';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.chat_bubble_outline, color: context.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.name,
                    style: context.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _previewText(lastMessage),
                    style: context.bodyMedium?.copyWith(
                      color: context.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeText,
                  style: context.labelSmall?.copyWith(
                    color: context.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 6),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: context.labelSmall?.copyWith(
                        color: context.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
