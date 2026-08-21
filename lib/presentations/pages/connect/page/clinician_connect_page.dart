import 'dart:async';

import 'package:app_doctor/common/widgets/clinician_header.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/presentation/provider/conversation_notifier.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/presentation/provider/patients_notifier.dart';
import 'package:app_doctor/features/user/presentation/provider/user_notifier.dart';
import 'package:app_doctor/presentations/pages/connect/widgets/clinician_chat_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClinicianConnectPage extends ConsumerStatefulWidget {
  const ClinicianConnectPage({super.key});

  @override
  ConsumerState<ClinicianConnectPage> createState() =>
      _ClinicianConnectPageState();
}

class _ClinicianConnectPageState extends ConsumerState<ClinicianConnectPage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(patientsProvider);
      if (!state.isLoading && state.patients.isEmpty) {
        ref.read(patientsProvider.notifier).fetchPatients();
      }
      ref.read(conversationsProvider.notifier).fetchConversations();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(patientsProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(patientsProvider.notifier).search(value);
    });
  }

  String _doctorName() {
    final user = ref.watch(userProvider).user;
    final lastName = user?.lastName?.trim();
    return lastName == null || lastName.isEmpty ? 'Doctor' : 'Dr. $lastName';
  }

  void _openChat(Conversation conversation, Patient patient) {
    context.go(
      '/connect/chat',
      extra: {'conversation': conversation, 'patient': patient},
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientsState = ref.watch(patientsProvider);
    final conversationsState = ref.watch(conversationsProvider);
    final doctorName = _doctorName();

    return Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (context.isCompactShell) {
              Widget stateContent;
              if (patientsState.isLoading && patientsState.patients.isEmpty) {
                stateContent = const SizedBox(
                  height: 240,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppPalette.secondaryBlue,
                    ),
                  ),
                );
              } else if (patientsState.error != null &&
                  patientsState.patients.isEmpty) {
                stateContent = Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s40),
                  child: Column(
                    children: [
                      Text(
                        patientsState.error!,
                        textAlign: TextAlign.center,
                        style: AppTypography.defaultBody2.copyWith(
                          color: context.error,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(patientsProvider.notifier).refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else if (patientsState.patients.isEmpty) {
                stateContent = const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.s40),
                  child: Center(child: Text('No patients found.')),
                );
              } else {
                stateContent = _PatientChatList(
                  patients: patientsState.patients,
                  conversations: conversationsState.conversations,
                  onChat: _openChat,
                );
              }

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
                    ClinicianHeader(
                      doctorName: doctorName,
                      onSearchChanged: _onSearchChanged,
                      onNotificationPressed: () {},
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    Text(
                      'Patient conversations',
                      style: AppTypography.titleBig1.copyWith(
                        color: AppPalette.secondaryBlue,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await Future.wait([
                            ref.read(patientsProvider.notifier).refresh(),
                            ref
                                .read(conversationsProvider.notifier)
                                .fetchConversations(),
                          ]);
                        },
                        child: ListView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          children: [
                            stateContent,
                            if (patientsState.isLoadingMore)
                              const Padding(
                                padding: EdgeInsets.all(AppSpacing.s20),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppPalette.secondaryBlue,
                                  ),
                                ),
                              ),
                            const SizedBox(height: AppSpacing.s20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final contentWidth = constraints.maxWidth < 1208
                ? 1208.0
                : constraints.maxWidth;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: contentWidth,
                height: constraints.maxHeight,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await Future.wait([
                      ref.read(patientsProvider.notifier).refresh(),
                      ref
                          .read(conversationsProvider.notifier)
                          .fetchConversations(),
                    ]);
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(30),
                    child: SizedBox(
                      width: contentWidth - 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClinicianHeader(
                            doctorName: doctorName,
                            onSearchChanged: _onSearchChanged,
                            onNotificationPressed: () {},
                          ),
                          const SizedBox(height: 30),
                          Text(
                            doctorName,
                            style: AppTypography.titleBig1.copyWith(
                              color: AppPalette.secondaryBlue,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 30),
                          if (patientsState.isLoading &&
                              patientsState.patients.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 60),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppPalette.secondaryBlue,
                                ),
                              ),
                            )
                          else if (patientsState.error != null &&
                              patientsState.patients.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      patientsState.error!,
                                      style: AppTypography.defaultBody2
                                          .copyWith(color: context.error),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () => ref
                                          .read(patientsProvider.notifier)
                                          .refresh(),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (patientsState.patients.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: Center(
                                child: Text(
                                  'No patients found.',
                                  style: AppTypography.titleBig2.copyWith(
                                    color: AppPalette.secondaryBlue,
                                  ),
                                ),
                              ),
                            )
                          else ...[
                            _PatientChatList(
                              patients: patientsState.patients,
                              conversations: conversationsState.conversations,
                              onChat: _openChat,
                            ),
                            if (patientsState.isLoadingMore)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppPalette.secondaryBlue,
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
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
}

class _PatientChatList extends StatelessWidget {
  final List<Patient> patients;
  final List<Conversation> conversations;
  final void Function(Conversation conversation, Patient patient) onChat;

  const _PatientChatList({
    required this.patients,
    required this.conversations,
    required this.onChat,
  });

  Conversation? _conversationFor(Patient patient) {
    final patientId = patient.id.trim().toLowerCase();
    for (final conversation in conversations) {
      final hasMatch = conversation.participants.any(
        (p) => p.trim().toLowerCase() == patientId,
      );
      if (hasMatch) return conversation;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: patients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final patient = patients[index];
        final conversation = _conversationFor(patient);
        final effectiveConversation =
            conversation ??
            Conversation(
              id: '',
              name: patient.fullName.isEmpty ? 'Patient' : patient.fullName,
              participants: [patient.id],
              status: 'active',
              unreadCountDoctor: 0,
              unreadCountPatient: 0,
              unreadInfo: const [],
            );
        return ClinicianChatRow(
          patient: patient,
          conversation: conversation,
          onChat: () => onChat(effectiveConversation, patient),
        );
      },
    );
  }
}
