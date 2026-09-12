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
  final bool compact;

  const ChatMessageBubble({
    super.key,
    required this.msg,
    required this.currentUserIds,
    this.currentRole,
    this.patient,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalizedCurrentUserIds = currentUserIds
        .map((id) => id.trim().toLowerCase())
        .where((id) => id.isNotEmpty)
        .toSet();
    final isOwn = _isOwnMessage(
      senderId: msg.senderId,
      currentUserIds: normalizedCurrentUserIds,
      currentPatient: patient,
      role: currentRole,
    );
    final isSeenByPeer = _isSeenByPeer(
      isOwn: isOwn,
      status: msg.status,
      readByIds: msg.readByIds,
      currentUserIds: normalizedCurrentUserIds,
    );
    final senderName = _senderName(currentPatient: patient, isOwn: isOwn);
    final timeStr = _timeFormatter.format(msg.sentAt);

    if (compact) {
      return Align(
        alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
        child: _CompactBubble(text: _messageText(msg), isOwn: isOwn),
      );
    }

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

  String _messageText(Message message) {
    final text = message.content.text?.trim() ?? '';
    return text.isNotEmpty ? text : 'Message';
  }

  bool _isOwnMessage({
    required String senderId,
    required Set<String> currentUserIds,
    required Patient? currentPatient,
    required UserRole? role,
  }) {
    final normalizedSenderId = senderId.trim().toLowerCase();
    if (normalizedSenderId.isEmpty) return false;

    final patientId = currentPatient?.id.trim().toLowerCase() ?? '';
    if (patientId.isNotEmpty) {
      final isPatientMessage = normalizedSenderId == patientId;
      if (role == UserRole.doctor) return !isPatientMessage;
      if (role == UserRole.patient) return isPatientMessage;
      if (isPatientMessage) return false;
    }

    return currentUserIds.contains(normalizedSenderId);
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
      if (!currentUserIds.contains(id.trim().toLowerCase())) {
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

class _CompactBubble extends StatelessWidget {
  final String text;
  final bool isOwn;

  const _CompactBubble({required this.text, required this.isOwn});

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 680),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isOwn ? AppPalette.secondaryBlue : AppPalette.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTypography.defaultBody2.copyWith(
          color: isOwn ? AppPalette.white : AppPalette.black,
          height: 1.3,
        ),
      ),
    );

    return CustomPaint(
      foregroundPainter: _BubbleTailPainter(
        color: isOwn ? AppPalette.secondaryBlue : AppPalette.surfaceLight,
        isOwn: isOwn,
      ),
      child: Padding(padding: const EdgeInsets.only(bottom: 8), child: bubble),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color color;
  final bool isOwn;

  const _BubbleTailPainter({required this.color, required this.isOwn});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    if (isOwn) {
      path.moveTo(size.width - 24, size.height - 8);
      path.lineTo(size.width - 6, size.height);
      path.lineTo(size.width - 10, size.height - 16);
    } else {
      path.moveTo(24, size.height - 8);
      path.lineTo(6, size.height);
      path.lineTo(10, size.height - 16);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isOwn != isOwn;
}
