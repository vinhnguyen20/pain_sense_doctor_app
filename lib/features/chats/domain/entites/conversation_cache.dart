import 'package:app_doctor/features/chats/domain/entites/message.dart';

class ConversationCache {
  final List<Message> messages;
  final String? nextCursor;
  final bool hasMore;
  final DateTime updatedAt;
  final String? connectedUserId;

  const ConversationCache({
    required this.messages,
    required this.nextCursor,
    required this.hasMore,
    required this.updatedAt,
    this.connectedUserId,
  });
}
