import 'dart:async';

import 'package:app_doctor/common/widgets/clinician_header.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/presentation/pages/chat_room_page.dart';
import 'package:app_doctor/features/chats/presentation/provider/conversation_notifier.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/presentation/provider/patients_notifier.dart';
import 'package:app_doctor/features/user/presentation/provider/user_notifier.dart';
import 'package:app_doctor/presentations/pages/connect/widgets/clinician_chat_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void _openChat(Conversation conversation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomPage(conversation: conversation),
      ),
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
                      ref.read(conversationsProvider.notifier).fetchConversations(),
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
                                      style: AppTypography.defaultBody2.copyWith(
                                        color: context.error,
                                      ),
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
  final ValueChanged<Conversation> onChat;

  const _PatientChatList({
    required this.patients,
    required this.conversations,
    required this.onChat,
  });

  Conversation? _conversationFor(Patient patient) {
    for (final conversation in conversations) {
      if (conversation.participants.contains(patient.id)) return conversation;
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
        return ClinicianChatRow(
          patient: patient,
          conversation: conversation,
          onChat: conversation == null ? null : () => onChat(conversation),
        );
      },
    );
  }
}