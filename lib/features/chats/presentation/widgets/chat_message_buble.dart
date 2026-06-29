import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/chats/domain/entites/message.dart';
import 'package:app_doctor/features/chats/presentation/pages/image_viewer_page.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ChatMessageBubble extends ConsumerWidget {
  static final DateFormat _timeFormatter = DateFormat('HH:mm');
  final Message msg;
  final Set<String> currentUserIds;
  final UserRole? currentRole;
  final Patient? patient;

  const ChatMessageBubble({
    super.key,
    required this.msg,
    required this.currentUserIds,
    this.currentRole,
    this.patient,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final senderId = (msg.senderId);
    final isOwn = senderId.isNotEmpty && currentUserIds.contains(senderId);
    final isSeenByPeer = _isSeenByPeer(
      isOwn: isOwn,
      status: msg.status,
      readByIds: msg.readByIds,
      currentUserIds: currentUserIds,
    );
    final senderName = _senderName(currentPatient: patient, isOwn: isOwn);
    final timeStr = _timeFormatter.format(msg.sentAt);

    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isOwn
              ? context.chatColors.outgoingBubble
              : context.chatColors.incomingBubble,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isOwn) ...[
              Text(
                senderName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.primary,
                ),
              ),
              const SizedBox(height: 4),
            ],
            _buildMessageContent(context, msg, isOwn),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isOwn
                        ? context.chatColors.outgoingMeta
                        : context.chatColors.incomingMeta,
                  ),
                ),
                if (isOwn) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isSeenByPeer ? Icons.done_all : Icons.done,
                    size: 14,
                    color: isSeenByPeer
                        ? context.chatColors.readReceipt
                        : context.chatColors.outgoingMeta,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    isSeenByPeer ? 'Seen' : 'Sent',
                    style: TextStyle(
                      fontSize: 11,
                      color: isSeenByPeer
                          ? context.chatColors.readReceipt
                          : context.chatColors.outgoingMeta,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, Message msg, bool isOwn) {
    final textStyle = TextStyle(
      fontSize: 14,
      color: isOwn
          ? context.chatColors.outgoingText
          : context.chatColors.incomingText,
    );
    final messageType = msg.type.trim().toLowerCase();
    final text = msg.content.text?.trim() ?? '';

    switch (messageType) {
      case 'text':
        return Text(text.isNotEmpty ? text : 'Message', style: textStyle);

      case 'image':
        final imageUrl = msg.content.imageUrl?.trim() ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (text.isNotEmpty) ...[
              Text(text, style: textStyle),
              const SizedBox(height: 8),
            ],

            if (imageUrl.isNotEmpty)
              GestureDetector(
                onTap: () {
                  context.push(
                    '/image-viewer',
                    extra: ImageViewerArgs(
                      urls: [imageUrl],
                      initialIndex: 0,
                      messageId: msg.id,
                    ),
                  );
                },
                child: Hero(
                  tag: 'chat_image_${msg.id}_0',
                  child: _buildChatImage(imageUrl),
                ),
              ),

            if (imageUrl.isEmpty) Text('Image message', style: textStyle),
          ],
        );

      case 'video':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.play_circle_outline,
              color: isOwn
                  ? context.chatColors.outgoingText
                  : context.chatColors.incomingText,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(text.isNotEmpty ? text : 'Video message', style: textStyle),
          ],
        );

      case 'appointment':
        return Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: isOwn
                  ? context.chatColors.outgoingText
                  : context.chatColors.outgoingBubble,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text.isNotEmpty ? text : 'Appointment scheduled',
                style: textStyle,
              ),
            ),
          ],
        );

      case 'exerciseassignment':
      case 'exercise_assignment':
        return Row(
          children: [
            Icon(
              Icons.fitness_center,
              color: isOwn
                  ? context.chatColors.outgoingText
                  : context.chatColors.outgoingBubble,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text.isNotEmpty ? text : 'Exercise assigned',
                style: textStyle,
              ),
            ),
          ],
        );

      default:
        return Text(
          text.isNotEmpty ? text : '[${msg.type}] message',
          style: textStyle,
        );
    }
  }

  bool _isSeenByPeer({
    required bool isOwn,
    required String status,
    required List<String> readByIds,
    required Set<String> currentUserIds,
  }) {
    if (!isOwn) return false;
    if ((status) == 'read') return true;
    if (currentUserIds.isEmpty) return false;

    for (final id in readByIds) {
      if (!currentUserIds.contains((id))) {
        return true;
      }
    }
    return false;
  }

  String _senderName({required Patient? currentPatient, required bool isOwn}) {
    if (isOwn) return '';
    return '${currentPatient?.firstName ?? ''} ${currentPatient?.lastName ?? ''}';
  }

  Widget _buildChatImage(String imageUrl) {
    final url = imageUrl.trim();

    if (url.isEmpty || !url.startsWith('http')) {
      return const Icon(Icons.image_not_supported);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 200,
        height: 260,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        cacheWidth: 400,
        frameBuilder: (_, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return Container(
            width: 200,
            height: 260,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, error, ___) {
          debugPrint('[ChatImage] load error: $error | url: $url');
          return Container(
            width: 200,
            height: 260,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, size: 32),
          );
        },
      ),
    );
  }
}
