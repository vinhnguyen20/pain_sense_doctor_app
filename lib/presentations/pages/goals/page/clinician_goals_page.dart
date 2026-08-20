import 'dart:async';

import 'package:app_doctor/common/widgets/app_snackbar.dart';
import 'package:app_doctor/common/widgets/clinician_header.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/presentation/provider/patients_notifier.dart';
import 'package:app_doctor/features/user/presentation/provider/user_notifier.dart';
import 'package:app_doctor/features/user/presentation/provider/user_providers.dart';
import 'package:app_doctor/presentations/pages/goals/widgets/clinician_goal_row.dart';
import 'package:app_doctor/presentations/pages/home/page/home_page.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/ai_goal_suggestion.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_action_button.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClinicianGoalsPage extends ConsumerStatefulWidget {
  final Patient? initialPatient;

  const ClinicianGoalsPage({super.key, this.initialPatient});

  @override
  ConsumerState<ClinicianGoalsPage> createState() =>
      _ClinicianGoalsPageState();
}

class _ClinicianGoalsPageState extends ConsumerState<ClinicianGoalsPage> {
  final ScrollController _patientScrollController = ScrollController();
  final ScrollController _goalScrollController = ScrollController();
  Timer? _debounce;
  Patient? _selectedPatient;
  bool _showAiSuggestions = false;

  @override
  void initState() {
    super.initState();
    _selectedPatient = widget.initialPatient;
    Future.microtask(() {
      final state = ref.read(patientsProvider);
      if (!state.isLoading && state.patients.isEmpty) {
        ref.read(patientsProvider.notifier).fetchPatients();
      }
    });
    _patientScrollController.addListener(_onPatientScroll);
    _goalScrollController.addListener(_onGoalScroll);
  }

  @override
  void didUpdateWidget(covariant ClinicianGoalsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPatient?.id != widget.initialPatient?.id) {
      _selectedPatient = widget.initialPatient;
      _showAiSuggestions = false;
    }
  }

  void _onPatientScroll() {
    if (!_patientScrollController.hasClients) return;
    if (_patientScrollController.position.pixels >=
        _patientScrollController.position.maxScrollExtent - 200) {
      ref.read(patientsProvider.notifier).loadMore();
    }
  }

  void _onGoalScroll() {
    final patient = _selectedPatient;
    if (patient == null || !_goalScrollController.hasClients) return;
    if (_goalScrollController.position.pixels >=
        _goalScrollController.position.maxScrollExtent - 200) {
      ref.read(patientUserGoalsProvider(patient.id).notifier).fetchMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(patientsProvider.notifier).search(value);
    });
  }

  void _openPatientGoals(Patient patient) {
    FocusManager.instance.primaryFocus?.unfocus();
    ref.read(selectedPatientProvider.notifier).setPatient(patient);
    context.pushNamed('clinician-patient-goals', extra: patient);
  }

  Future<void> _openCreateGoal() async {
    final patient = _selectedPatient;
    if (patient == null) return;
    final result = await context.pushNamed(
      'clinician-goal-form',
      extra: {
        'mode': GoalFormMode.create,
        'patientId': patient.id,
      },
    );
    if (result != null) {
      ref.invalidate(patientUserGoalsProvider(patient.id));
    }
  }

  Future<void> _editGoal(UserGoalModel goal) async {
    final patient = _selectedPatient;
    if (patient == null) return;
    final result = await context.pushNamed(
      'goal-form',
      extra: {
        'mode': GoalFormMode.edit,
        'initialGoal': goal.toGoalModel(),
        'originalGoalItems': goal.goalItems,
        'patientId': patient.id,
      },
    );
    if (result != null) {
      ref.invalidate(patientUserGoalsProvider(patient.id));
    }
  }

  Future<void> _deleteGoal(UserGoalModel goal) async {
    final patient = _selectedPatient;
    if (patient == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final response = await ref.read(deleteUserGoalUseCaseProvider).call(goal.id);
    if (!mounted) return;
    if (response.isSuccess) {
      ref.invalidate(patientUserGoalsProvider(patient.id));
    } else {
      AppSnackbar.error(context, response.message);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _patientScrollController.dispose();
    _goalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final fullName = userState.user?.fullName.trim();
    final doctorName = fullName == null || fullName.isEmpty
        ? 'Doctor'
        : 'Dr. $fullName';
    final patientsState = ref.watch(patientsProvider);

    if (_selectedPatient == null) {
      return ClinicianHomeView(
        patients: patientsState.patients,
        doctorName: doctorName,
        onSearchChanged: _onSearchChanged,
        scrollController: _patientScrollController,
        isLoading: patientsState.isLoading,
        errorMessage: patientsState.error,
        isLoadingMore: patientsState.isLoadingMore,
        hasMore: patientsState.hasMore,
        onRetry: () => ref.read(patientsProvider.notifier).refresh(),
        onRefresh: () => ref.read(patientsProvider.notifier).refresh(),
        onPatientDetails: _openPatientGoals,
      );
    }

    return _buildGoalsContent(doctorName);
  }

  Widget _buildGoalsContent(String doctorName) {
    final patient = _selectedPatient!;
    final goalsAsync = ref.watch(patientUserGoalsProvider(patient.id));
    final notifier = ref.watch(
      patientUserGoalsProvider(patient.id).notifier,
    );
    final goals = goalsAsync.value ?? const <UserGoalModel>[];

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
                child: Padding(
                  padding: const EdgeInsets.all(30),
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
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GoalActionButton(
                              label: 'Create New Goal',
                              width: 240,
                              onPressed: _openCreateGoal,
                            ),
                            const SizedBox(width: 30),
                            GoalActionButton(
                              label: 'Suggest Goal',
                              width: 240,
                              onPressed: () => setState(
                                () => _showAiSuggestions =
                                    !_showAiSuggestions,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Here are the latest goals you have created.',
                        style: AppTypography.titleBig2.copyWith(
                          color: AppPalette.secondaryBlue,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(
                              patientUserGoalsProvider(patient.id),
                            );
                            await ref.read(
                              patientUserGoalsProvider(patient.id).future,
                            );
                          },
                          child: _buildGoalList(
                            goalsAsync: goalsAsync,
                            goals: goals,
                            isFetchingMore: notifier.isFetchingMore,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGoalList({
    required AsyncValue<List<UserGoalModel>> goalsAsync,
    required List<UserGoalModel> goals,
    required bool isFetchingMore,
  }) {
    final rows = <Widget>[];

    if (goalsAsync.isLoading && goals.isEmpty) {
      rows.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: CircularProgressIndicator(
              color: AppPalette.secondaryBlue,
            ),
          ),
        ),
      );
    } else if (goalsAsync.hasError && goals.isEmpty) {
      rows.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppPalette.surfaceLight,
            borderRadius: AppCorners.r8,
          ),
          child: Text(
            goalsAsync.error.toString(),
            style: AppTypography.defaultBody2.copyWith(
              color: AppPalette.secondaryBlue,
            ),
          ),
        ),
      );
    } else if (goals.isEmpty) {
      rows.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppPalette.surfaceLight,
            borderRadius: AppCorners.r8,
          ),
          child: Text(
            'No goals available for this patient yet.',
            style: AppTypography.defaultBody2.copyWith(
              color: AppPalette.secondaryBlue,
            ),
          ),
        ),
      );
    } else {
      for (final goal in goals) {
        final item = goal.goalItems.firstOrNull;
        final title = item?.label.trim().isNotEmpty == true
            ? item!.label.trim()
            : item == null
            ? 'Goal'
            : '${item.minTarget} ${item.unit} ${item.type.displayName}';
        rows.add(
          ClinicianGoalRow(
            icon: item?.type.icon ?? Icons.flag_outlined,
            title: title,
            onAssign: _openCreateGoal,
            onEdit: () => _editGoal(goal),
            onDelete: () => _deleteGoal(goal),
          ),
        );
      }
    }

    if (isFetchingMore) {
      rows.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              color: AppPalette.secondaryBlue,
            ),
          ),
        ),
      );
    }

    if (_showAiSuggestions) {
      rows.add(
        AiSuggestionsSection(
          suggestions: [
            AiGoalSuggestionRow(
              icon: Icons.directions_walk,
              iconColor: context.goalColors.iconWalking,
              title: 'Daily Walks',
              description:
                  'Based on low activity levels detected from sensor data. Start with short walks and gradually increase.',
              reason: 'Inactivity detected in past 7 days',
              onAdopt: _openCreateGoal,
            ),
            AiGoalSuggestionRow(
              icon: Icons.self_improvement,
              iconColor: context.goalColors.iconYoga,
              title: 'Evening Yoga',
              description:
                  'High EMG readings in evenings suggest muscle tension. Gentle yoga can reduce pain.',
              reason: 'High EMG in evenings',
              onAdopt: _openCreateGoal,
            ),
            AiGoalSuggestionRow(
              icon: Icons.shield_outlined,
              iconColor: context.goalColors.iconPosture,
              title: 'Posture Breaks',
              description:
                  'Poor posture detected during prolonged sitting. Regular breaks improve spinal health.',
              reason: 'Low posture scores detected',
              onAdopt: _openCreateGoal,
            ),
          ],
        ),
      );
    }

    final aiIndex = _showAiSuggestions ? rows.length - 1 : -1;
    return ListView.separated(
      controller: _goalScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.zero,
      itemCount: rows.length,
      separatorBuilder: (_, index) => SizedBox(
        height: index + 1 == aiIndex ? 30 : 10,
      ),
      itemBuilder: (_, index) => rows[index],
    );
  }
}
