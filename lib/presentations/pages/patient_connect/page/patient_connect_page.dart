import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/presentation/pages/chat_room_page.dart';
import 'package:app_doctor/features/chats/presentation/provider/conversation_notifier.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/presentation/provider/patients_notifier.dart';
import 'package:app_doctor/presentations/pages/patient_connect/widgets/patient_chat_content.dart';
import 'package:app_doctor/presentations/pages/patient_connect/widgets/patient_contacts_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientConnectPage extends ConsumerStatefulWidget {
  final Patient? patient;

  const PatientConnectPage({super.key, this.patient});

  @override
  ConsumerState<PatientConnectPage> createState() => _PatientConnectPageState();
}

class _PatientConnectPageState extends ConsumerState<PatientConnectPage> {
  PatientConnectTab _selectedTab = PatientConnectTab.chat;

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
                        Center(
                          child: PatientConnectTabs(
                            selectedTab: _selectedTab,
                            onChanged: (tab) {
                              setState(() => _selectedTab = tab);
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (_selectedTab == PatientConnectTab.contacts)
                          const PatientContactsContent()
                        else if (_selectedTab == PatientConnectTab.chat) ...[
                          PatientChatContent(
                            patient: patient,
                            patientConversation: patientConversation,
                            otherConversations: otherConversations,
                            onChat: _openChat,
                          ),
                        ] else
                          const SizedBox.shrink(),
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

enum PatientConnectTab { chat, contacts, appointments }

class PatientConnectTabs extends StatelessWidget {
  final PatientConnectTab selectedTab;
  final ValueChanged<PatientConnectTab>? onChanged;

  const PatientConnectTabs({
    super.key,
    this.selectedTab = PatientConnectTab.chat,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 680,
      height: 50,
      decoration: BoxDecoration(
        color: AppPalette.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _TabItem(label: 'Chat', tab: PatientConnectTab.chat),
          SizedBox(width: 40),
          _TabItem(label: 'Contacts', tab: PatientConnectTab.contacts),
          SizedBox(width: 40),
          _TabItem(label: 'Appointments', tab: PatientConnectTab.appointments),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final PatientConnectTab tab;

  const _TabItem({required this.label, required this.tab});

  @override
  Widget build(BuildContext context) {
    final tabs = context.findAncestorWidgetOfExactType<PatientConnectTabs>();
    final isSelected = tabs?.selectedTab == tab;

    return GestureDetector(
      onTap: tabs?.onChanged == null ? null : () => tabs!.onChanged!(tab),
      child: Container(
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
      ),
    );
  }
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
