import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/presentation/provider/conversation_notifier.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/presentation/provider/patients_notifier.dart';
import 'package:app_doctor/features/user/presentation/provider/user_providers.dart';
import 'package:app_doctor/presentations/pages/appointments/page/patient_appointments_page.dart';
import 'package:app_doctor/presentations/pages/patient_connect/widgets/patient_chat_content.dart';
import 'package:app_doctor/presentations/pages/patient_connect/widgets/patient_contacts_content.dart';
import 'package:app_doctor/presentations/pages/patient_connect/widgets/patient_connect_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      if (widget.patient != null) {
        ref.read(selectedPatientProvider.notifier).setPatient(widget.patient);
      }
      ref.read(patientsProvider.notifier).fetchPatients();
      ref.read(conversationsProvider.notifier).fetchConversations();
    });
  }

  void _openChat(Conversation conversation, Patient? patient) {
    context.go(
      '/patient-connect/chat',
      extra: {'conversation': conversation, 'patient': patient},
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientsState = ref.watch(patientsProvider);
    final conversationsState = ref.watch(conversationsProvider);
    final selectedPatient = ref.watch(selectedPatientProvider);
    final patient =
        widget.patient ??
        selectedPatient ??
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
            final isAppointments =
                _selectedTab == PatientConnectTab.appointments;

            if (context.isCompactShell) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s16,
                  AppSpacing.s16,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PatientConnectHeader(patient: patient),
                    const SizedBox(height: AppSpacing.s16),
                    PatientConnectTabs(
                      selectedTab: _selectedTab,
                      onChanged: (tab) => setState(() => _selectedTab = tab),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Expanded(
                      child: isAppointments
                          ? patient == null
                                ? const SizedBox.shrink()
                                : PatientAppointmentsContent(patient: patient)
                          : SingleChildScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              child: _selectedTab == PatientConnectTab.contacts
                                  ? const PatientContactsContent()
                                  : PatientChatContent(
                                      patient: patient,
                                      patientConversation: patientConversation,
                                      otherConversations: otherConversations,
                                      onChat: _openChat,
                                    ),
                            ),
                    ),
                  ],
                ),
              );
            }

            final width = constraints.maxWidth < 1208
                ? 1208.0
                : constraints.maxWidth;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                height: constraints.maxHeight,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: SizedBox(
                    width: width - 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PatientConnectHeader(patient: patient),
                        SizedBox(height: isAppointments ? 30 : 20),
                        Center(
                          child: PatientConnectTabs(
                            selectedTab: _selectedTab,
                            onChanged: (tab) {
                              setState(() => _selectedTab = tab);
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        Expanded(
                          child: isAppointments
                              ? patient == null
                                    ? const SizedBox.shrink()
                                    : PatientAppointmentsContent(
                                        patient: patient,
                                      )
                              : SingleChildScrollView(
                                  child:
                                      _selectedTab == PatientConnectTab.contacts
                                      ? const PatientContactsContent()
                                      : PatientChatContent(
                                          patient: patient,
                                          patientConversation:
                                              patientConversation,
                                          otherConversations:
                                              otherConversations,
                                          onChat: _openChat,
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

  Conversation? _conversationForPatient(
    Patient patient,
    List<Conversation> conversations,
  ) {
    final patientId = patient.id.trim().toLowerCase();
    for (final conversation in conversations) {
      final hasMatch = conversation.participants.any(
        (p) => p.trim().toLowerCase() == patientId,
      );
      if (hasMatch) return conversation;
    }
    return null;
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
    if (context.isCompactShell) {
      return Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: AppPalette.surfaceLight,
          borderRadius: AppCorners.r20,
        ),
        child: Row(
          children: [
            for (final tab in PatientConnectTab.values)
              Expanded(
                child: _TabItem(
                  label: switch (tab) {
                    PatientConnectTab.chat => 'Chat',
                    PatientConnectTab.contacts => 'Contacts',
                    PatientConnectTab.appointments => 'Schedule',
                  },
                  tab: tab,
                ),
              ),
          ],
        ),
      );
    }

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
        width: context.isCompactShell ? double.infinity : 200,
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
