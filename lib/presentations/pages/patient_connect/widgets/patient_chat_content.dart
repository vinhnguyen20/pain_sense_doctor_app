import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/domain/entites/last_message.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientChatContent extends StatelessWidget {
  final Patient? patient;
  final Conversation? patientConversation;
  final List<Conversation> otherConversations;
  final void Function(Conversation, Patient?) onChat;

  const PatientChatContent({
    super.key,
    required this.patient,
    required this.patientConversation,
    required this.otherConversations,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePatientConv = patient == null
        ? null
        : (patientConversation ??
              Conversation(
                id: '',
                name: patient!.fullName.isEmpty ? 'Patient' : patient!.fullName,
                participants: [patient!.id],
                status: 'active',
                unreadCountDoctor: 0,
                unreadCountPatient: 0,
                unreadInfo: const [],
              ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (patient != null && effectivePatientConv != null)
          ChatSummaryCard(
            avatarAsset: 'assets/images/avatar/avatar.png',
            name: patient!.fullName,
            role: 'Patient',
            message: _messageText(patientConversation),
            conversation: patientConversation,
            onChat: () => onChat(effectivePatientConv, patient),
          ),
        const SizedBox(height: 10),
        Text(
          'Other Clinicians',
          style: AppTypography.titleSmall1.copyWith(
            color: AppPalette.secondaryBlue,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, thickness: 1, color: AppPalette.secondaryBlue),
        const SizedBox(height: 10),
        ...otherConversations.map(
          (conversation) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ChatSummaryCard(
              avatarAsset: 'assets/images/avatar/avatar.png',
              name: conversation.name,
              role: 'Clinician',
              message: _messageText(conversation),
              conversation: conversation,
              onChat: () => onChat(conversation, null),
            ),
          ),
        ),
      ],
    );
  }

  String _messageText(Conversation? conversation) {
    final text = conversation?.lastMessage?.text.trim();
    return text == null || text.isEmpty ? 'No recent message' : text;
  }
}

class ChatSummaryCard extends StatelessWidget {
  final String avatarAsset;
  final String name;
  final String role;
  final String message;
  final Conversation? conversation;
  final VoidCallback? onChat;

  const ChatSummaryCard({
    super.key,
    required this.avatarAsset,
    required this.name,
    required this.role,
    required this.message,
    this.conversation,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChat,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppPalette.surfaceLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ChatAvatar(
              asset: avatarAsset,
              size: context.isCompactShell ? 48 : 80,
            ),
            SizedBox(width: context.isCompactShell ? 12 : 40),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _nameStyle,
                  ),
                  const SizedBox(height: 9),
                  Text(
                    role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 9),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _messageStyle,
                  ),
                ],
              ),
            ),
            SizedBox(width: context.isCompactShell ? 8 : 20),
            _DateTimeGroup(lastMessage: conversation?.lastMessage),
          ],
        ),
      ),
    );
  }

  static final _nameStyle = AppTypography.titleSmall1.copyWith(
    color: AppPalette.secondaryBlue,
    height: 1,
  );
  static final _bodyStyle = AppTypography.defaultBody2.copyWith(
    color: AppPalette.secondaryBlue,
    height: 1,
  );
  static final _messageStyle = AppTypography.defaultBody2.copyWith(
    color: AppPalette.secondaryBlue,
    fontStyle: FontStyle.italic,
    height: 1,
  );
}

class _DateTimeGroup extends StatelessWidget {
  final LastMessage? lastMessage;

  const _DateTimeGroup({required this.lastMessage});

  @override
  Widget build(BuildContext context) {
    final sentAt = lastMessage?.sentAt;
    final date = sentAt == null
        ? 'No date'
        : DateFormat('yyyy/MM/dd').format(sentAt.toLocal());
    final time = sentAt == null
        ? 'No time'
        : DateFormat('h:mm a').format(sentAt.toLocal());

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          date,
          style: _dateStyle,
          textAlign: TextAlign.right,
          maxLines: 1,
          softWrap: false,
        ),
        const SizedBox(height: 11),
        Text(
          time,
          style: _dateStyle,
          textAlign: TextAlign.right,
          maxLines: 1,
          softWrap: false,
        ),
      ],
    );
  }

  static final _dateStyle = AppTypography.titleBig1.copyWith(
    color: AppPalette.secondaryBlue,
    height: 1,
  );
}

class _ChatAvatar extends StatelessWidget {
  final String asset;
  final double size;

  const _ChatAvatar({required this.asset, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(asset, width: size, height: size, fit: BoxFit.cover),
    );
  }
}
