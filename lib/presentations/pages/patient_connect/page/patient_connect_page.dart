import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/domain/entites/last_message.dart';
import 'package:app_doctor/features/chats/presentation/pages/chat_room_page.dart';
import 'package:app_doctor/features/chats/presentation/provider/conversation_notifier.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/presentation/provider/patients_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PatientConnectPage extends ConsumerStatefulWidget {
  final Patient? patient;

  const PatientConnectPage({super.key, this.patient});

  @override
  ConsumerState<PatientConnectPage> createState() => _PatientConnectPageState();
}

class _PatientConnectPageState extends ConsumerState<PatientConnectPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(patientsProvider.notifier).fetchPatients();
      ref.read(conversationsProvider.notifier).fetchConversations();
    });
  }

  void _openChat(Conversation conversation, Patient? patient) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ChatRoomPage(conversation: conversation, patient: patient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientsState = ref.watch(patientsProvider);
    final conversationsState = ref.watch(conversationsProvider);
    final patient =
        widget.patient ??
        (patientsState.patients.isNotEmpty
            ? patientsState.patients.first
            : null);
    final patientConversation = patient == null
        ? null
        : _conversationForPatient(patient, conversationsState.conversations);
    final otherConversations = patient == null
        ? conversationsState.conversations
        : conversationsState.conversations
              .where(
                (conversation) =>
                    !conversation.participants.contains(patient.id),
              )
              .toList();

    return Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth < 1208
                ? 1208.0
                : constraints.maxWidth;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                height: constraints.maxHeight,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: SizedBox(
                    width: width - 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PatientIdentityHeader(patient: patient),
                        const SizedBox(height: 20),
                        const Center(child: PatientConnectTabs()),
                        const SizedBox(height: 30),
                        if (patient != null)
                          ChatSummaryCard(
                            avatarAsset: 'assets/images/avatar/avatar.png',
                            name: patient.fullName,
                            role: 'Patient',
                            message: _messageText(patientConversation),
                            conversation: patientConversation,
                            patient: patient,
                            onChat: patientConversation == null
                                ? null
                                : () => _openChat(patientConversation, patient),
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
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppPalette.secondaryBlue,
                        ),
                        const SizedBox(height: 10),
                        if (otherConversations.isNotEmpty)
                          ...otherConversations.map(
                            (conversation) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ChatSummaryCard(
                                avatarAsset: 'assets/images/avatar/avatar.png',
                                name: conversation.name,
                                role: 'Clinician',
                                message: _messageText(conversation),
                                conversation: conversation,
                                onChat: () => _openChat(conversation, null),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _messageText(Conversation? conversation) {
    final text = conversation?.lastMessage?.text.trim();
    return text == null || text.isEmpty ? 'No recent message' : text;
  }

  Conversation? _conversationForPatient(
    Patient patient,
    List<Conversation> conversations,
  ) {
    for (final conversation in conversations) {
      if (conversation.participants.contains(patient.id)) return conversation;
    }
    return null;
  }
}

class _PatientIdentityHeader extends StatelessWidget {
  final Patient? patient;

  const _PatientIdentityHeader({required this.patient});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          const _Avatar(size: 80),
          const SizedBox(width: 40),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient?.fullName.isNotEmpty == true
                    ? patient!.fullName
                    : 'Patient',
                style: AppTypography.titleBig1.copyWith(
                  color: AppPalette.secondaryBlue,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                patient?.phone?.trim().isNotEmpty == true
                    ? patient!.phone!
                    : 'No phone number',
                style: AppTypography.defaultBody2.copyWith(
                  color: AppPalette.secondaryBlue,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PatientConnectTabs extends StatelessWidget {
  const PatientConnectTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 680,
      height: 50,
      decoration: BoxDecoration(
        color: AppPalette.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          _TabItem(label: 'Chat', isSelected: true),
          SizedBox(width: 40),
          _TabItem(label: 'Contacts'),
          SizedBox(width: 40),
          _TabItem(label: 'Appointments'),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _TabItem({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? AppPalette.secondaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.defaultBody1.copyWith(
          color: isSelected ? AppPalette.white : AppPalette.medGray,
          height: 1,
        ),
      ),
    );
  }
}

class ChatSummaryCard extends StatelessWidget {
  final String avatarAsset;
  final String name;
  final String role;
  final String message;
  final Conversation? conversation;
  final Patient? patient;
  final VoidCallback? onChat;

  const ChatSummaryCard({
    super.key,
    required this.avatarAsset,
    required this.name,
    required this.role,
    required this.message,
    this.conversation,
    this.patient,
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
            _Avatar(size: 80, asset: avatarAsset),
            const SizedBox(width: 40),
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
            const SizedBox(width: 20),
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

class _Avatar extends StatelessWidget {
  final double size;
  final String asset;

  const _Avatar({
    required this.size,
    this.asset = 'assets/images/avatar/avatar.png',
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(asset, width: size, height: size, fit: BoxFit.cover),
    );
  }
}
