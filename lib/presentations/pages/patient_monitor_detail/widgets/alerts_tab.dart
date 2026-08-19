import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_activity.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_entry.dart';
import 'package:app_doctor/features/diary/presentation/provider/patient_diary_notifier.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum _AlertSeverity { critical, warning, info }

class _AlertItem {
  final String id;
  final _AlertSeverity severity;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? actionLabel;
  final IconData icon;

  const _AlertItem({
    required this.id,
    required this.severity,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    this.actionLabel,
  });
}

class _ScoredAlert {
  final _AlertItem alert;
  final double score;

  const _ScoredAlert({required this.alert, required this.score});
}

class AlertsTab extends ConsumerStatefulWidget {
  final String patientId;
  final Patient patient;

  const AlertsTab({super.key, required this.patientId, required this.patient});

  @override
  ConsumerState<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends ConsumerState<AlertsTab> {
  @override
  void initState() {
    super.initState();
    if (widget.patientId.trim().isNotEmpty) {
      Future.microtask(
        () => ref
            .read(patientDiaryProvider(widget.patientId).notifier)
            .refresh(),
      );
    }
  }

  double _normalizedPercent(PatientDiaryActivity activity) {
    final raw = activity.percent;
    final scaled = raw <= 1 ? raw * 100 : raw;
    return scaled.clamp(0.0, 100.0);
  }

  double _stableNoise(String seed) {
    var hash = 2166136261;
    for (final code in seed.codeUnits) {
      hash ^= code;
      hash = (hash * 16777619) & 0x7fffffff;
    }
    return (hash % 1000) / 1000;
  }

  List<_AlertItem> _selectTopFive(List<_ScoredAlert> candidates) {
    if (candidates.isEmpty) return const [];
    final ranked = [...candidates]..sort((a, b) => b.score.compareTo(a.score));
    final selected = <_AlertItem>[];

    for (final candidate in ranked) {
      final duplicated = selected.any((item) => item.id == candidate.alert.id);
      if (duplicated) continue;
      selected.add(candidate.alert);
      if (selected.length == 5) break;
    }

    return selected;
  }

  List<_AlertItem> _buildAlerts(List<PatientDiaryEntry> entries) {
    final now = DateTime.now();
    final dateSeed = DateFormat('yyyyMMdd').format(now);
    final candidates = <_ScoredAlert>[];
    final lbpScore = widget.patient.trackingLogs?.lbpScoreValue;
    final sortedEntries = [...entries]
      ..sort((a, b) => b.date.compareTo(a.date));
    final latestEntry = sortedEntries.isEmpty ? null : sortedEntries.first;
    final latestActivities =
        latestEntry?.diary ?? const <PatientDiaryActivity>[];
    final allActivities = sortedEntries.expand((entry) => entry.diary).toList();
    final today = DateTime(now.year, now.month, now.day);
    final latestDay = latestEntry == null
        ? null
        : DateTime(
            latestEntry.date.year,
            latestEntry.date.month,
            latestEntry.date.day,
          );
    final daysFromToday = latestDay == null
        ? 999
        : today.difference(latestDay).inDays.clamp(0, 999);
    final lowProgressCount = latestActivities
        .where((activity) => _normalizedPercent(activity) < 50)
        .length;
    final highProgressCount = latestActivities
        .where((activity) => _normalizedPercent(activity) >= 80)
        .length;
    final recentSevenDaysEntries = sortedEntries.where((entry) {
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
      return today.difference(day).inDays <= 6;
    }).length;
    final hasYogaRecent = latestActivities.any(
      (a) => a.type == GoalType.yogaMeditation,
    );
    final hasStepsRecent = latestActivities.any(
      (a) => a.type == GoalType.stepsWalking,
    );
    final hasActivityTimeRecent = latestActivities.any(
      (a) => a.type == GoalType.activityWalk,
    );
    final avgProgressLatest = latestActivities.isEmpty
        ? 0.0
        : latestActivities.map(_normalizedPercent).reduce((a, b) => a + b) /
              latestActivities.length;

    void addCandidate({
      required String id,
      required double relevance,
      required _AlertSeverity severity,
      required String title,
      required String description,
      required Duration timeAgo,
      required IconData icon,
      String? actionLabel,
    }) {
      if (relevance <= 0) return;
      final noise = _stableNoise('${widget.patientId}|$dateSeed|$id');
      final score = relevance + (noise * 0.49);
      candidates.add(
        _ScoredAlert(
          score: score,
          alert: _AlertItem(
            id: id,
            severity: severity,
            title: title,
            description: description,
            timestamp: now.subtract(timeAgo),
            // actionLabel: actionLabel,
            icon: icon,
          ),
        ),
      );
    }

    addCandidate(
      id: 'pain_spike_critical',
      relevance: lbpScore != null && lbpScore >= 70 ? 9.6 : 0,
      severity: _AlertSeverity.critical,
      title: 'Pain Spike Detected',
      description:
          'Current LBP score is ${lbpScore ?? '--'}/100. Consider reducing intensity and reviewing patient status now.',
      timeAgo: const Duration(minutes: 50),
      actionLabel: 'Review patient status',
      icon: Icons.error_outline_rounded,
    );

    addCandidate(
      id: 'pain_risk_warning',
      relevance: lbpScore != null && lbpScore >= 55 && lbpScore < 70 ? 8.2 : 0,
      severity: _AlertSeverity.warning,
      title: 'Pain Risk Increasing',
      description:
          'LBP score is at ${lbpScore ?? '--'}/100. Monitor closely and adjust exercise load if pain rises.',
      timeAgo: const Duration(hours: 1),
      actionLabel: 'Adjust plan',
      icon: Icons.monitor_heart_outlined,
    );

    addCandidate(
      id: 'no_diary_critical',
      relevance: entries.isEmpty ? 9.2 : 0,
      severity: _AlertSeverity.critical,
      title: 'No Diary Data',
      description:
          'No diary entries are available yet. Tracking cannot be assessed until patient submits logs.',
      timeAgo: const Duration(hours: 2),
      actionLabel: '',
      icon: Icons.menu_book_outlined,
    );

    addCandidate(
      id: 'missed_checkin_warning',
      relevance: entries.isNotEmpty && daysFromToday >= 2 ? 8.8 : 0,
      severity: _AlertSeverity.warning,
      title: 'Missed Check-in',
      description:
          'Patient has not submitted diary entries for $daysFromToday consecutive days.',
      timeAgo: const Duration(hours: 3),
      actionLabel: '',
      icon: Icons.event_busy_outlined,
    );

    addCandidate(
      id: 'stale_diary_critical',
      relevance: entries.isNotEmpty && daysFromToday >= 4 ? 9.0 : 0,
      severity: _AlertSeverity.critical,
      title: 'Follow-up Required',
      description:
          'Diary has been inactive for more than 4 days. Clinical follow-up is recommended.',
      timeAgo: const Duration(hours: 4),
      actionLabel: 'Contact patient',
      icon: Icons.warning_amber_rounded,
    );

    addCandidate(
      id: 'low_adherence_warning',
      relevance: lowProgressCount >= 2 ? 8.5 : 0,
      severity: _AlertSeverity.warning,
      title: 'Low Adherence Trend',
      description:
          '$lowProgressCount activities are below 50% completion in the latest diary entry.',
      timeAgo: const Duration(hours: 5),
      actionLabel: 'Adjust goal targets',
      icon: Icons.trending_down_rounded,
    );

    addCandidate(
      id: 'very_low_adherence_critical',
      relevance: lowProgressCount >= 3 ? 9.1 : 0,
      severity: _AlertSeverity.critical,
      title: 'Adherence Drop (Critical)',
      description:
          'Most goals in the latest diary are under target. Consider immediate intervention.',
      timeAgo: const Duration(hours: 6),
      actionLabel: 'Escalate',
      icon: Icons.report_problem_outlined,
    );

    addCandidate(
      id: 'single_activity_warning',
      relevance: latestActivities.length == 1 ? 6.8 : 0,
      severity: _AlertSeverity.warning,
      title: 'Limited Goal Coverage',
      description:
          'Latest diary includes only one tracked activity. Goal set may be too narrow for full recovery.',
      timeAgo: const Duration(hours: 8),
      actionLabel: 'Review goal mix',
      icon: Icons.filter_1_outlined,
    );

    addCandidate(
      id: 'diary_today_info',
      relevance: entries.isNotEmpty && daysFromToday == 0 ? 6.6 : 0,
      severity: _AlertSeverity.info,
      title: 'Diary Updated Today',
      description:
          'Patient submitted today\'s diary. Good signal for monitoring continuity.',
      timeAgo: const Duration(hours: 2),
      icon: Icons.check_circle_outline_rounded,
    );

    addCandidate(
      id: 'good_progress_info',
      relevance: highProgressCount >= 2 ? 7.8 : 0,
      severity: _AlertSeverity.info,
      title: 'Good Progress',
      description:
          '$highProgressCount activities are above 80% in the latest diary entry.',
      timeAgo: const Duration(days: 1),
      icon: Icons.favorite_border_rounded,
    );

    addCandidate(
      id: 'weekly_consistency_info',
      relevance: recentSevenDaysEntries >= 5 ? 7.0 : 0,
      severity: _AlertSeverity.info,
      title: 'Strong Weekly Consistency',
      description:
          'Patient logged $recentSevenDaysEntries diary entries in the last 7 days.',
      timeAgo: const Duration(days: 1, hours: 4),
      icon: Icons.calendar_month_outlined,
    );

    addCandidate(
      id: 'avg_progress_info',
      relevance: avgProgressLatest >= 70 ? 7.2 : 0,
      severity: _AlertSeverity.info,
      title: 'Recovery Momentum',
      description:
          'Average completion in latest diary is ${avgProgressLatest.toStringAsFixed(0)}%. Keep current progression pace.',
      timeAgo: const Duration(days: 1, hours: 8),
      icon: Icons.auto_graph_rounded,
    );

    addCandidate(
      id: 'missing_yoga_warning',
      relevance: latestActivities.isNotEmpty && !hasYogaRecent ? 6.4 : 0,
      severity: _AlertSeverity.warning,
      title: 'Yoga Component Missing',
      description:
          'No yoga/meditation activity found in latest diary. Consider adding mobility-focused sessions.',
      timeAgo: const Duration(hours: 10),
      actionLabel: 'Add yoga goals',
      icon: Icons.self_improvement_outlined,
    );

    addCandidate(
      id: 'missing_steps_warning',
      relevance: latestActivities.isNotEmpty && !hasStepsRecent ? 6.2 : 0,
      severity: _AlertSeverity.warning,
      title: 'Walking Target Missing',
      description:
          'No step/walking activity appears in latest diary. Daily movement target may be under-structured.',
      timeAgo: const Duration(hours: 11),
      actionLabel: 'Add walking target',
      icon: Icons.directions_walk_outlined,
    );

    addCandidate(
      id: 'missing_activity_time_info',
      relevance: latestActivities.isNotEmpty && !hasActivityTimeRecent
          ? 5.6
          : 0,
      severity: _AlertSeverity.info,
      title: 'Add Activity-Time Goal',
      description:
          'A duration-based goal can improve consistency when step counts fluctuate.',
      timeAgo: const Duration(hours: 12),
      actionLabel: 'Suggest new goal',
      icon: Icons.timer_outlined,
    );

    addCandidate(
      id: 'education_tip_info',
      relevance: 4.9,
      severity: _AlertSeverity.info,
      title: 'Coaching Opportunity',
      description:
          'Send a short coaching tip today to reinforce proper form and daily adherence.',
      timeAgo: const Duration(days: 2),
      actionLabel: 'Send tip',
      icon: Icons.lightbulb_outline,
    );

    addCandidate(
      id: 'review_schedule_info',
      relevance: allActivities.length >= 8 ? 5.4 : 4.7,
      severity: _AlertSeverity.info,
      title: 'Schedule Review Suggested',
      description:
          'Review time slots and session load to maintain sustainable adherence next week.',
      timeAgo: const Duration(days: 2, hours: 3),
      actionLabel: '',
      icon: Icons.schedule_outlined,
    );

    final selected = _selectTopFive(candidates);
    if (selected.length >= 5) return selected;

    final fallback = <_AlertItem>[
      _AlertItem(
        id: 'fallback_monitor_1',
        severity: _AlertSeverity.info,
        title: 'Monitor Patient Trend',
        description:
            'Continue monitoring daily goals and diary updates for clearer recovery patterns.',
        timestamp: now.subtract(const Duration(days: 2, hours: 6)),
        icon: Icons.insights_outlined,
      ),
      _AlertItem(
        id: 'fallback_monitor_2',
        severity: _AlertSeverity.info,
        title: 'Encourage Daily Logging',
        description:
            'Regular diary updates improve alert quality and treatment adjustments.',
        timestamp: now.subtract(const Duration(days: 2, hours: 8)),
        icon: Icons.edit_note_outlined,
      ),
      _AlertItem(
        id: 'fallback_monitor_3',
        severity: _AlertSeverity.warning,
        title: 'Follow-up Recommended',
        description:
            'If progress remains flat, schedule a check-in to re-align goals.',
        timestamp: now.subtract(const Duration(days: 2, hours: 10)),
        actionLabel: 'Plan follow-up',
        icon: Icons.support_agent_outlined,
      ),
    ];

    final merged = [...selected];
    for (final item in fallback) {
      final duplicated = merged.any((existing) => existing.id == item.id);
      if (!duplicated) merged.add(item);
      if (merged.length == 5) break;
    }

    return merged;
  }

  Color _severityTone(BuildContext context, _AlertSeverity severity) {
    return switch (severity) {
      _AlertSeverity.critical => context.error,
      _AlertSeverity.warning => context.warning,
      _AlertSeverity.info => context.info,
    };
  }

  String _severityLabel(_AlertSeverity severity) {
    return switch (severity) {
      _AlertSeverity.critical => 'Critical',
      _AlertSeverity.warning => 'Warning',
      _AlertSeverity.info => 'Info',
    };
  }

  String _formatTimestamp(DateTime value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(value.year, value.month, value.day);
    final sameDay = date == today;
    final time = DateFormat('HH:mm').format(value);
    if (sameDay) return 'Today · $time';
    return '${DateFormat('dd/MM').format(value)} · $time';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.patientId.trim().isEmpty) {
      return Center(
        child: Text(
          'Patient id is missing. Cannot load alerts.',
          style: context.bodyMedium?.copyWith(color: context.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    final diaryState = ref.watch(patientDiaryProvider(widget.patientId));

    if (diaryState.isLoading && diaryState.entries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final alerts = _buildAlerts(diaryState.entries);

    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 44,
              color: context.onSurface.withValues(alpha: 0.35),
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'No alerts at this time',
              style: context.bodyMedium?.copyWith(
                color: context.onSurface.withValues(alpha: 0.58),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: context.screenPadding,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        final tone = _severityTone(context, alert.severity);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.s14),
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.08),
            borderRadius: AppCorners.r12,
            border: Border.all(color: tone.withValues(alpha: 0.26)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.16),
                  borderRadius: AppCorners.r10,
                ),
                alignment: Alignment.center,
                child: Icon(alert.icon, size: 20, color: tone),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: context.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s8,
                            vertical: AppSpacing.s4,
                          ),
                          decoration: BoxDecoration(
                            color: tone,
                            borderRadius: AppCorners.r16,
                          ),
                          child: Text(
                            _severityLabel(alert.severity),
                            style: context.labelMedium?.copyWith(
                              color: context.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    Text(
                      alert.description,
                      style: context.bodySmall?.copyWith(
                        color: context.onSurface.withValues(alpha: 0.72),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s10),
                    Row(
                      children: [
                        Text(
                          _formatTimestamp(alert.timestamp),
                          style: context.labelMedium?.copyWith(
                            color: context.onSurface.withValues(alpha: 0.58),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (alert.actionLabel != null)
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s8,
                                vertical: AppSpacing.s4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              alert.actionLabel!,
                              style: context.labelMedium?.copyWith(
                                color: tone,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s10),
      itemCount: alerts.length,
    );
  }
}
