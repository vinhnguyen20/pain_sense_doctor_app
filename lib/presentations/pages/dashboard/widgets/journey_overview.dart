import 'dart:math' as math;

import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/core/utils/date_utils_helper.dart';
import 'package:app_doctor/features/chats/domain/entites/appointment.dart';
import 'package:app_doctor/features/chats/presentation/provider/appointment_notifier.dart';
import 'package:app_doctor/features/diary/data/models/goal_item_model.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';
import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_activity.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_entry.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';
import 'package:app_doctor/features/diary/presentation/provider/patient_diary_notifier.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showPatientJourneyOverview(
  BuildContext context,
  Patient patient,
) async {
  final screenSize = MediaQuery.sizeOf(context);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: math.min(980, screenSize.width - 40),
        height: math.min(760, screenSize.height - 40),
        child: PatientJourneyOverview(patient: patient),
      ),
    ),
  );
}

Future<DateTimeRange?> showJourneyDateRangePicker({
  required BuildContext context,
  required DateTimeRange initialDateRange,
}) {
  return showDateRangePicker(
    context: context,
    initialDateRange: initialDateRange,
    firstDate: DateTime(2020),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    builder: (pickerContext, child) {
      final theme = Theme.of(pickerContext);
      return Theme(
        data: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: AppPalette.secondaryBlue,
            onPrimary: AppPalette.white,
            secondary: AppPalette.primaryBlue,
          ),
        ),
        child: child!,
      );
    },
  );
}

class PatientJourneyOverview extends ConsumerStatefulWidget {
  final Patient patient;

  const PatientJourneyOverview({super.key, required this.patient});

  @override
  ConsumerState<PatientJourneyOverview> createState() =>
      _PatientJourneyOverviewState();
}

class _PatientJourneyOverviewState
    extends ConsumerState<PatientJourneyOverview> {
  static const _filters = <String>[
    'All',
    'Exercises',
    'Milestones',
    'Appointments',
  ];

  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _query = '';
  late DateTimeRange _selectedDateRange;

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(DateTime.now());
    _selectedDateRange = DateTimeRange(
      start: today.subtract(const Duration(days: 6)),
      end: today,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diaryState = ref.watch(patientDiaryProvider(widget.patient.id));
    final goalsAsync = ref.watch(patientUserGoalsProvider(widget.patient.id));
    final appointmentsState = ref.watch(
      appointmentsByPatientProvider(widget.patient.id),
    );
    final progressQuery = (
      patientId: widget.patient.id,
      fromDate: DateUtilsHelper.formatDateApi(_selectedDateRange.start),
      toDate: DateUtilsHelper.formatDateApi(_selectedDateRange.end),
    );
    final progressAsync = ref.watch(
      patientDiaryProgressProvider(progressQuery),
    );

    final goals = _buildDailyGoals(
      entries: diaryState.entries,
      goals: goalsAsync.value ?? const <UserGoalModel>[],
      date: _selectedDateRange.end,
    );
    final progress = progressAsync.value ?? 0;
    final events = _buildEvents(
      diaryEntries: diaryState.entries,
      appointments: appointmentsState.appointments,
    ).where(_matchesEvent).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = context.isCompactShell || constraints.maxWidth < 760;
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(compact ? 16 : 30),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _JourneyHeader(
                        dateRange: _selectedDateRange,
                        progress: progress,
                        onDateTap: _selectDate,
                        onProgressTap: () =>
                            _showProgressDetails(goals, progress),
                      ),
                      const SizedBox(height: 14),
                      _JourneyProgress(progress: progress),
                      const SizedBox(height: 20),
                      _DailyGoalsCard(
                        goals: goals,
                        compact: compact,
                        isLoading: goalsAsync.isLoading,
                        onTap: _showGoalDetails,
                      ),
                      const SizedBox(height: 20),
                      _TimelineCard(
                        events: events,
                        filters: _filters,
                        selectedFilter: _selectedFilter,
                        searchController: _searchController,
                        query: _query,
                        onFilterChanged: (value) {
                          setState(() => _selectedFilter = value);
                        },
                        onQueryChanged: (value) {
                          setState(() => _query = value);
                        },
                        onEventTap: _showEventDetails,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _refresh() async {
    await ref.read(patientDiaryProvider(widget.patient.id).notifier).refresh();
    ref.invalidate(patientUserGoalsProvider(widget.patient.id));
    await ref
        .read(appointmentsByPatientProvider(widget.patient.id).notifier)
        .refresh();
    final progressQuery = (
      patientId: widget.patient.id,
      fromDate: DateUtilsHelper.formatDateApi(_selectedDateRange.start),
      toDate: DateUtilsHelper.formatDateApi(_selectedDateRange.end),
    );
    final _ = await ref.refresh(
      patientDiaryProgressProvider(progressQuery).future,
    );
  }

  Future<void> _selectDate() async {
    final picked = await showJourneyDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
    );
    if (picked != null && mounted) {
      setState(() => _selectedDateRange = picked);
    }
  }

  bool _matchesEvent(_JourneyEvent event) {
    final start = DateUtils.dateOnly(_selectedDateRange.start);
    final endExclusive = DateUtils.dateOnly(
      _selectedDateRange.end,
    ).add(const Duration(days: 1));
    if (event.date.isBefore(start) || !event.date.isBefore(endExclusive)) {
      return false;
    }
    if (_selectedFilter != 'All' && event.category != _selectedFilter) {
      return false;
    }
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    return event.title.toLowerCase().contains(query) ||
        event.description.toLowerCase().contains(query);
  }

  void _showProgressDetails(List<_JourneyGoal> goals, double progress) {
    _showDetails(
      title: 'Journey progress',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${progress.round()}%',
            style: const TextStyle(
              fontFamily: 'Cabin',
              fontSize: 44,
              fontWeight: FontWeight.w700,
              color: _JourneyColors.blue,
            ),
          ),
          const SizedBox(height: 12),
          ...goals.map(
            (goal) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(goal.icon, color: goal.color),
              title: Text(goal.title),
              trailing: Text(
                '${goal.percent.round()}%',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGoalDetails(_JourneyGoal goal) {
    _showDetails(
      title: goal.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(goal.description),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: (goal.percent / 100).clamp(0.0, 1.0),
              minHeight: 9,
              color: goal.displayColor,
              backgroundColor: goal.displayColor.withValues(alpha: .14),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${goal.actual.toStringAsFixed(0)} of '
                    '${goal.target.toStringAsFixed(0)} ${goal.unit}'
                .trim(),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(_JourneyEvent event) {
    _showDetails(
      title: event.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(event.icon, color: event.color),
              const SizedBox(width: 10),
              Text(
                _formatDate(event.date),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(event.description),
          const SizedBox(height: 14),
          Text(event.category, style: TextStyle(color: event.color)),
        ],
      ),
    );
  }

  void _showDetails({required String title, required Widget child}) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: child,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _JourneyHeader extends StatelessWidget {
  final DateTimeRange dateRange;
  final double progress;
  final VoidCallback onDateTap;
  final VoidCallback onProgressTap;

  const _JourneyHeader({
    required this.dateRange,
    required this.progress,
    required this.onDateTap,
    required this.onProgressTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Journey',
                style: TextStyle(
                  fontFamily: 'Cabin',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _JourneyColors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDateRange(dateRange),
                style: const TextStyle(
                  fontFamily: 'Cabin',
                  color: _JourneyColors.blue,
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'You are making great progress',
                style: TextStyle(
                  fontFamily: 'Cabin',
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: _JourneyColors.blue,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            IconButton(
              tooltip: 'Choose date',
              onPressed: onDateTap,
              icon: const Icon(
                Icons.calendar_month_outlined,
                color: _JourneyColors.blue,
                size: 29,
              ),
            ),
            InkWell(
              onTap: onProgressTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '${progress.round()}%',
                  style: const TextStyle(
                    fontFamily: 'Cabin',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: _JourneyColors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _JourneyProgress extends StatelessWidget {
  final double progress;

  const _JourneyProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LinearProgressIndicator(
        value: progress / 100,
        minHeight: 10,
        color: _JourneyColors.blue,
        backgroundColor: const Color(0xFFE9ECEF),
      ),
    );
  }
}

class _DailyGoalsCard extends StatelessWidget {
  final List<_JourneyGoal> goals;
  final bool compact;
  final bool isLoading;
  final ValueChanged<_JourneyGoal> onTap;

  const _DailyGoalsCard({
    required this.goals,
    required this.compact,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _JourneyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag_outlined, color: _JourneyColors.blue),
              SizedBox(width: 8),
              Text(
                'Daily Goals',
                style: TextStyle(
                  fontFamily: 'Cabin',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: _JourneyColors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (compact)
            Column(
              children: [
                for (var index = 0; index < goals.length; index++) ...[
                  _GoalTile(
                    goal: goals[index],
                    onTap: () => onTap(goals[index]),
                  ),
                  if (index < goals.length - 1) const SizedBox(height: 14),
                ],
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < goals.length; index++) ...[
                  Expanded(
                    child: _GoalTile(
                      goal: goals[index],
                      onTap: () => onTap(goals[index]),
                    ),
                  ),
                  if (index < goals.length - 1) const SizedBox(width: 16),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final _JourneyGoal goal;
  final VoidCallback onTap;

  const _GoalTile({required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              SizedBox(
                width: 66,
                height: 66,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: (goal.percent / 100).clamp(0.0, 1.0),
                      strokeWidth: 7,
                      color: goal.displayColor,
                      backgroundColor: goal.displayColor.withValues(alpha: .13),
                    ),
                    Text(
                      '${goal.percent.round()}%',
                      style: TextStyle(
                        fontFamily: 'Cabin',
                        fontWeight: FontWeight.w700,
                        color: goal.displayColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontFamily: 'Cabin',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: _JourneyColors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cabin',
                        fontSize: 12,
                        color: _JourneyColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _JourneyColors.blue),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final List<_JourneyEvent> events;
  final List<String> filters;
  final String selectedFilter;
  final TextEditingController searchController;
  final String query;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<_JourneyEvent> onEventTap;

  const _TimelineCard({
    required this.events,
    required this.filters,
    required this.selectedFilter,
    required this.searchController,
    required this.query,
    required this.onFilterChanged,
    required this.onQueryChanged,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    return _JourneyCard(
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Search diaries, people, or exercises',
              prefixIcon: const Icon(Icons.search, color: _JourneyColors.blue),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        searchController.clear();
                        onQueryChanged('');
                      },
                      icon: const Icon(Icons.clear),
                    ),
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in filters) ...[
                  ChoiceChip(
                    label: Text(filter),
                    selected: selectedFilter == filter,
                    onSelected: (_) => onFilterChanged(filter),
                    selectedColor: _JourneyColors.blue,
                    labelStyle: TextStyle(
                      color: selectedFilter == filter
                          ? Colors.white
                          : _JourneyColors.blue,
                    ),
                    showCheckmark: false,
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Timeline',
              style: TextStyle(
                fontFamily: 'Cabin',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: _JourneyColors.blue,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Text('No timeline items found.'),
            )
          else
            ...events
                .take(20)
                .map(
                  (event) => _TimelineRow(
                    event: event,
                    onTap: () => onEventTap(event),
                  ),
                ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final _JourneyEvent event;
  final VoidCallback onTap;

  const _TimelineRow({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 88,
              child: Text(
                _formatDate(event.date),
                style: const TextStyle(
                  fontSize: 11,
                  color: _JourneyColors.blue,
                ),
              ),
            ),
            Column(
              children: [
                Icon(Icons.circle, size: 12, color: event.color),
                Container(
                  width: 2,
                  height: 48,
                  color: event.color.withValues(alpha: .25),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(event.icon, color: event.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Cabin',
                              fontWeight: FontWeight.w700,
                              color: _JourneyColors.blue,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            event.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Cabin',
                              fontSize: 12,
                              color: _JourneyColors.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: _JourneyColors.blue),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  final Widget child;

  const _JourneyCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8D8D8)),
      ),
      child: child,
    );
  }
}

class _JourneyGoal {
  final GoalType type;
  final String title;
  final String description;
  final double percent;
  final double actual;
  final double target;
  final String unit;

  const _JourneyGoal({
    required this.type,
    required this.title,
    required this.description,
    required this.percent,
    required this.actual,
    required this.target,
    required this.unit,
  });

  IconData get icon => type.icon;

  bool get isCompleted => percent >= 100;

  Color get displayColor => isCompleted ? const Color(0xFF87C879) : color;

  Color get color => switch (type) {
    GoalType.yogaMeditation => const Color(0xFF58E8EA),
    GoalType.stepsWalking => _JourneyColors.blue,
    GoalType.activityWalk => _JourneyColors.darkBlue,
    GoalType.unknown => const Color(0xFF6E7B85),
  };
}

class _JourneyEvent {
  final DateTime date;
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final Color color;

  const _JourneyEvent({
    required this.date,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
  });
}

abstract final class _JourneyColors {
  static const blue = Color(0xFF206EB0);
  static const darkBlue = Color(0xFF18588C);
}

List<_JourneyGoal> _buildDailyGoals({
  required List<PatientDiaryEntry> entries,
  required List<UserGoalModel> goals,
  required DateTime date,
}) {
  PatientDiaryEntry? entry;
  for (final candidate in entries) {
    if (DateUtils.isSameDay(candidate.date, date)) {
      entry = candidate;
      break;
    }
  }

  final goalItems = goals
      .where(
        (goal) =>
            !date.isBefore(goal.startDate) &&
            date.isBefore(goal.endDate.add(const Duration(days: 1))),
      )
      .expand((goal) => goal.goalItems)
      .toList();

  const types = [
    GoalType.yogaMeditation,
    GoalType.stepsWalking,
    GoalType.activityWalk,
  ];
  return types.map((type) {
    final activity = entry?.diary
        .where((item) => item.type == type)
        .firstOrNull;
    final goalItem = goalItems.where((item) => item.type == type).firstOrNull;
    final title = switch (type) {
      GoalType.yogaMeditation => 'Exercise',
      GoalType.stepsWalking => 'Steps',
      GoalType.activityWalk => 'Posture',
      GoalType.unknown => 'Goal',
    };
    return _JourneyGoal(
      type: type,
      title: title,
      description: _goalDescription(type, activity, goalItem),
      percent: (activity?.percent ?? 0).clamp(0, 100).toDouble(),
      actual: activity?.actual ?? 0,
      target: activity?.minTarget ?? goalItem?.minTarget.toDouble() ?? 0,
      unit: activity?.unit ?? goalItem?.unit ?? '',
    );
  }).toList();
}

String _goalDescription(
  GoalType type,
  PatientDiaryActivity? activity,
  GoalItemModel? goal,
) {
  if (activity != null) {
    return switch (type) {
      GoalType.yogaMeditation =>
        'You have completed ${activity.actual.toInt()} of '
            '${activity.minTarget.toInt()} exercise goals.',
      GoalType.stepsWalking =>
        'You have walked ${activity.actual.toInt()} of '
            '${activity.minTarget.toInt()} steps.',
      GoalType.activityWalk =>
        activity.desc.isEmpty
            ? 'How well you are following your posture guidance.'
            : activity.desc,
      GoalType.unknown => activity.desc,
    };
  }
  if (goal != null && goal.desc.trim().isNotEmpty) return goal.desc;
  return 'No activity recorded for this date.';
}

List<_JourneyEvent> _buildEvents({
  required List<PatientDiaryEntry> diaryEntries,
  required List<Appointment> appointments,
}) {
  final events = <_JourneyEvent>[];
  for (final entry in diaryEntries) {
    for (final activity in entry.diary) {
      final isExercise = activity.type == GoalType.yogaMeditation;
      events.add(
        _JourneyEvent(
          date: entry.date,
          title: activity.label.isEmpty
              ? activity.type.displayName
              : activity.label,
          description: activity.desc.isEmpty
              ? '${activity.actual.toInt()} ${activity.unit}'.trim()
              : activity.desc,
          category: isExercise ? 'Exercises' : 'Milestones',
          icon: activity.type.icon,
          color: isExercise ? _JourneyColors.blue : const Color(0xFF6EBB65),
        ),
      );
    }
  }
  for (final appointment in appointments) {
    final date = _parseDate(appointment.schedule.date) ?? appointment.createdAt;
    if (date == null) continue;
    events.add(
      _JourneyEvent(
        date: date,
        title: appointment.title.isEmpty ? 'Appointment' : appointment.title,
        description: appointment.description.isEmpty
            ? 'Appointment with ${appointment.doctorName}'.trim()
            : appointment.description,
        category: 'Appointments',
        icon: Icons.medical_services_outlined,
        color: const Color(0xFF8D6CCB),
      ),
    );
  }
  events.sort((a, b) => b.date.compareTo(a.date));
  return events;
}

DateTime? _parseDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed != null) return parsed;
  final parts = value.split(RegExp(r'[/\\-]'));
  if (parts.length == 3 && parts[2].length == 4) {
    return DateTime.tryParse(
      '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}',
    );
  }
  return null;
}

String _formatDate(DateTime date) =>
    '${date.year}/${date.month.toString().padLeft(2, '0')}/'
    '${date.day.toString().padLeft(2, '0')}';

String _formatDateRange(DateTimeRange range) =>
    '${_formatDate(range.start)} – ${_formatDate(range.end)}';
