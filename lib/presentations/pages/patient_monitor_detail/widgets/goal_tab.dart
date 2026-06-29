import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart'
    as goal_form;
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/patient_insight_card.dart';
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

  Widget _buildSuggestionItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
    required String warning,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s10,
        AppSpacing.s12,
        AppSpacing.s0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppCorners.r10,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: context.bodySmall?.copyWith(
                    color: context.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 13,
                      color: context.warning,
                    ),
                    const SizedBox(width: AppSpacing.s4),
                    Expanded(
                      child: Text(
                        warning,
                        style: context.labelSmall?.copyWith(
                          color: context.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s10),
                Divider(color: context.border, height: 1, thickness: 0.8),
              ],
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: () => context.pushNamed(
              'goal-form',
              extra: {
                'mode': goal_form.GoalFormMode.create,
                'patientId': widget.patientId,
              },
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s14,
                vertical: AppSpacing.s6,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Adopt'),
          ),
        ],
      ),
    );
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
        padding: context.screenPadding,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          PatientInsightsCard(logs: widget.logs),
          const SizedBox(height: AppSpacing.s16),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AppButtonSize.lg + AppSpacing.s8,
                  child: ElevatedButton(
                    onPressed: _openGoalForm,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.add, size: AppSize.iconSm),
                        SizedBox(width: AppSpacing.s8),
                        Flexible(
                          child: Text(
                            'Create New Goal',
                            textAlign: TextAlign.left,
                            softWrap: true,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s10),
              Expanded(
                child: SizedBox(
                  height: AppButtonSize.lg + AppSpacing.s8,
                  child: OutlinedButton(
                    onPressed: () => setState(
                      () => _showAiSuggestions = !_showAiSuggestions,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.hub_outlined, size: 16),
                        SizedBox(width: AppSpacing.s8),
                        Flexible(
                          child: Text(
                            'AI Suggestions',
                            textAlign: TextAlign.left,
                            softWrap: true,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_showAiSuggestions) ...[
            const SizedBox(height: AppSpacing.s12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: AppCorners.r12,
                border: Border.all(color: context.border),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: context.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI Suggestions',
                            style: context.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: context.border, height: 1, thickness: 0.8),
                  _buildSuggestionItem(
                    icon: Icons.directions_walk,
                    iconBg: context.goalColors.iconWalking.withValues(
                      alpha: 0.12,
                    ),
                    iconColor: context.goalColors.iconWalking,
                    title: 'Daily Walks',
                    description:
                        'Based on low activity levels detected from sensor data. Start with short walks and gradually increase.',
                    warning: 'Inactivity detected in past 7 days',
                  ),
                  _buildSuggestionItem(
                    icon: Icons.self_improvement,
                    iconBg: context.goalColors.iconYoga.withValues(alpha: 0.12),
                    iconColor: context.goalColors.iconYoga,
                    title: 'Evening Yoga',
                    description:
                        'High EMG readings in evenings suggest muscle tension. Gentle yoga can reduce pain.',
                    warning: 'High EMG in evenings',
                  ),
                  _buildSuggestionItem(
                    icon: Icons.shield_outlined,
                    iconBg: context.goalColors.iconPosture.withValues(
                      alpha: 0.12,
                    ),
                    iconColor: context.goalColors.iconPosture,
                    title: 'Posture Breaks',
                    description:
                        'Poor posture detected during prolonged sitting. Regular breaks improve spinal health.',
                    warning: 'Low posture scores detected',
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.s20),

          if (userGoalsAsync.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (userGoalsAsync.hasError)
            Container(
              width: double.infinity,
              padding: AppInsets.card,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: AppCorners.r12,
                border: Border.all(color: context.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cannot load goals right now',
                    style: context.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    _friendlyError(userGoalsAsync.error ?? 'Unknown error'),
                    style: context.bodySmall?.copyWith(
                      color: context.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(
                      patientUserGoalsProvider(widget.patientId),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if ((userGoalsAsync.value ?? []).isEmpty)
            Container(
              width: double.infinity,
              padding: AppInsets.card,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: AppCorners.r12,
                border: Border.all(color: context.border),
              ),
              child: Text(
                'No goals available for this patient yet.',
                style: context.bodyMedium?.copyWith(
                  color: context.onSurface.withValues(alpha: 0.7),
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
                child: Center(child: CircularProgressIndicator()),
              )
            else if (!notifier.hasMore)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                child: Center(
                  child: Text(
                    'No more goals',
                    style: context.bodySmall?.copyWith(
                      color: context.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
          ],

          const SizedBox(height: AppSpacing.s16),
        ],
      ),
    );
  }
}
