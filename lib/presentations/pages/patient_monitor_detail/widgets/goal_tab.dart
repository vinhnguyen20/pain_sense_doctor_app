import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/ai_goal_suggestion.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_action_button.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart'
    as goal_form;
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/user_goal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GoalsTab extends ConsumerStatefulWidget {
  final String patientId;
  final TrackingLogs? logs;

  const GoalsTab({super.key, required this.patientId, this.logs});

  @override
  ConsumerState<GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends ConsumerState<GoalsTab> {
  bool _showAiSuggestions = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(patientUserGoalsProvider(widget.patientId).notifier).fetchMore();
    }
  }

  String _friendlyError(Object error) {
    final raw = error.toString().trim();
    if (raw.startsWith('Exception: ')) {
      return raw.replaceFirst('Exception: ', '');
    }
    return raw;
  }

  Future<void> _openGoalForm() async {
    final result = await context.pushNamed(
      'goal-form',
      extra: {
        'mode': goal_form.GoalFormMode.create,
        'patientId': widget.patientId,
      },
    );

    if (result != null) {
      ref.invalidate(patientUserGoalsProvider(widget.patientId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userGoalsAsync = ref.watch(
      patientUserGoalsProvider(widget.patientId),
    );
    final notifier = ref.watch(
      patientUserGoalsProvider(widget.patientId).notifier,
    );

    Future<void> handleRefresh() async {
      ref.invalidate(patientUserGoalsProvider(widget.patientId));
      await ref.read(patientUserGoalsProvider(widget.patientId).future);
    }

    return RefreshIndicator(
      onRefresh: handleRefresh,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(30),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 30,
            runSpacing: 10,
            children: [
              GoalActionButton(
                label: 'Create New Goal',
                width: 240,
                onPressed: _openGoalForm,
              ),
              GoalActionButton(
                label: 'Suggest Goal',
                width: 240,
                onPressed: () => setState(
                  () => _showAiSuggestions = !_showAiSuggestions,
                ),
              ),
            ],
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
          if (userGoalsAsync.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s20),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppPalette.secondaryBlue,
                ),
              ),
            )
          else if (userGoalsAsync.hasError)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppPalette.surfaceLight,
                borderRadius: AppCorners.r8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cannot load goals right now',
                    style: AppTypography.titleSmall1.copyWith(
                      color: AppPalette.secondaryBlue,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    _friendlyError(userGoalsAsync.error ?? 'Unknown error'),
                    style: AppTypography.denseBody1.copyWith(
                      color: AppPalette.black.withValues(alpha: 0.68),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  GoalActionButton(
                    label: 'Retry',
                    width: 137,
                    onPressed: () => ref.invalidate(
                      patientUserGoalsProvider(widget.patientId),
                    ),
                  ),
                ],
              ),
            )
          else if ((userGoalsAsync.value ?? []).isEmpty)
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
            )
          else ...[
            ...(userGoalsAsync.value ?? []).map(
              (goal) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s10),
                child: UserGoalCard(
                  goal: goal,
                  patientId: widget.patientId,
                  onDelete: () => ref.invalidate(
                    patientUserGoalsProvider(widget.patientId),
                  ),
                ),
              ),
            ),

            if (notifier.isFetchingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppPalette.secondaryBlue,
                  ),
                ),
              )
            else if (!notifier.hasMore)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                child: Center(
                  child: Text(
                    'No more goals',
                    style: AppTypography.denseBody1.copyWith(
                      color: AppPalette.medGray,
                    ),
                  ),
                ),
              ),
          ],
          if (_showAiSuggestions) ...[
            const SizedBox(height: 30),
            AiSuggestionsSection(
              suggestions: [
                AiGoalSuggestionRow(
                  icon: Icons.directions_walk,
                  iconColor: context.goalColors.iconWalking,
                  title: 'Daily Walks',
                  description:
                      'Based on low activity levels detected from sensor data. Start with short walks and gradually increase.',
                  reason: 'Inactivity detected in past 7 days',
                  onAdopt: () => context.pushNamed(
                    'goal-form',
                    extra: {
                      'mode': goal_form.GoalFormMode.create,
                      'patientId': widget.patientId,
                    },
                  ),
                ),
                AiGoalSuggestionRow(
                  icon: Icons.self_improvement,
                  iconColor: context.goalColors.iconYoga,
                  title: 'Evening Yoga',
                  description:
                      'High EMG readings in evenings suggest muscle tension. Gentle yoga can reduce pain.',
                  reason: 'High EMG in evenings',
                  onAdopt: () => context.pushNamed(
                    'goal-form',
                    extra: {
                      'mode': goal_form.GoalFormMode.create,
                      'patientId': widget.patientId,
                    },
                  ),
                ),
                AiGoalSuggestionRow(
                  icon: Icons.shield_outlined,
                  iconColor: context.goalColors.iconPosture,
                  title: 'Posture Breaks',
                  description:
                      'Poor posture detected during prolonged sitting. Regular breaks improve spinal health.',
                  reason: 'Low posture scores detected',
                  onAdopt: () => context.pushNamed(
                    'goal-form',
                    extra: {
                      'mode': goal_form.GoalFormMode.create,
                      'patientId': widget.patientId,
                    },
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.s16),
        ],
      ),
    );
  }
}
