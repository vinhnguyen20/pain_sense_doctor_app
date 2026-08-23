import 'package:app_doctor/common/widgets/app_snackbar.dart';
import 'package:app_doctor/core/utils/date_utils_helper.dart';
import 'package:app_doctor/features/education/domain/entites/exercise.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_shared_widget.dart';
import 'package:flutter/material.dart';

class SelectedExerciseSessionsEditor extends StatelessWidget {
  final List<GoalExercisePlanDraft> plans;
  final List<Exercise> exercises;
  final bool readOnly;
  final DateTime? goalStartDate;
  final DateTime? goalEndDate;
  final void Function(String exerciseId, String value)
  onDoctorInstructionChanged;
  final void Function(String exerciseId, DateTime date) onAddScheduleDay;
  final void Function(String exerciseId, int dayIndex) onRemoveScheduleDay;
  final void Function(String exerciseId, int dayIndex, DateTime date)
  onScheduleDateChanged;
  final void Function(String exerciseId, int dayIndex) onAddSlot;
  final void Function(String exerciseId, int dayIndex, int slotIndex)
  onRemoveSlot;
  final void Function(
    String exerciseId,
    int dayIndex,
    int slotIndex,
    GoalExerciseSlotDraft slot,
  )
  onSlotChanged;

  const SelectedExerciseSessionsEditor({
    super.key,
    required this.plans,
    required this.exercises,
    required this.readOnly,
    this.goalStartDate,
    this.goalEndDate,
    required this.onDoctorInstructionChanged,
    required this.onAddScheduleDay,
    required this.onRemoveScheduleDay,
    required this.onScheduleDateChanged,
    required this.onAddSlot,
    required this.onRemoveSlot,
    required this.onSlotChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) return const SizedBox.shrink();

    final exerciseById = <String, Exercise>{
      for (final item in exercises) item.id: item,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(label: 'Exercise Schedule Configuration'),
        const SizedBox(height: AppSpacing.s10),
        Text(
          'Configure doctor instruction and session times for each selected exercise.',
          style: context.bodySmall?.copyWith(
            color: context.onSurface.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        ...plans.map((plan) {
          final exercise = exerciseById[plan.exerciseId];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s12),
            child: _ExercisePlanCard(
              plan: plan,
              exerciseTitle: exercise?.title ?? plan.exerciseId,
              exerciseDuration: exercise?.durationSeconds,
              readOnly: readOnly,
              goalStartDate: goalStartDate,
              goalEndDate: goalEndDate,
              onDoctorInstructionChanged: (value) =>
                  onDoctorInstructionChanged(plan.exerciseId, value),
              onAddScheduleDay: (date) =>
                  onAddScheduleDay(plan.exerciseId, date),
              onRemoveScheduleDay: (dayIndex) =>
                  onRemoveScheduleDay(plan.exerciseId, dayIndex),
              onScheduleDateChanged: (dayIndex, date) =>
                  onScheduleDateChanged(plan.exerciseId, dayIndex, date),
              onAddSlot: (dayIndex) => onAddSlot(plan.exerciseId, dayIndex),
              onRemoveSlot: (dayIndex, slotIndex) =>
                  onRemoveSlot(plan.exerciseId, dayIndex, slotIndex),
              onSlotChanged: (dayIndex, slotIndex, slot) =>
                  onSlotChanged(plan.exerciseId, dayIndex, slotIndex, slot),
            ),
          );
        }),
      ],
    );
  }
}

class _ExercisePlanCard extends StatelessWidget {
  final GoalExercisePlanDraft plan;
  final String exerciseTitle;
  final int? exerciseDuration;
  final bool readOnly;
  final DateTime? goalStartDate;
  final DateTime? goalEndDate;
  final ValueChanged<String> onDoctorInstructionChanged;
  final void Function(DateTime date) onAddScheduleDay;
  final ValueChanged<int> onRemoveScheduleDay;
  final void Function(int dayIndex, DateTime date) onScheduleDateChanged;
  final ValueChanged<int> onAddSlot;
  final void Function(int dayIndex, int slotIndex) onRemoveSlot;
  final void Function(int dayIndex, int slotIndex, GoalExerciseSlotDraft slot)
  onSlotChanged;

  const _ExercisePlanCard({
    required this.plan,
    required this.exerciseTitle,
    required this.exerciseDuration,
    required this.readOnly,
    this.goalStartDate,
    this.goalEndDate,
    required this.onDoctorInstructionChanged,
    required this.onAddScheduleDay,
    required this.onRemoveScheduleDay,
    required this.onScheduleDateChanged,
    required this.onAddSlot,
    required this.onRemoveSlot,
    required this.onSlotChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final minutes = (exerciseDuration ?? 0) ~/ 60;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.r10),
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.5),
          width: AppBorder.regular,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseTitle,
                      style: context.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      minutes > 0 ? '$minutes min/exercise' : 'Exercise',
                      style: context.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s10),
          const SectionLabel(label: 'Doctor instruction'),
          const SizedBox(height: AppSpacing.s6),
          TextFormField(
            key: ValueKey('doctor_instruction_${plan.exerciseId}'),
            initialValue: plan.doctorInstruction,
            readOnly: readOnly,
            maxLines: 1,
            style: TextStyle(fontSize: 14, color: cs.onSurface),
            onChanged: onDoctorInstructionChanged,
            decoration: InputDecoration(
              hintText: 'e.g. Warm up 5 minutes before',
              hintStyle: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: 0.38),
              ),
              filled: true,
              fillColor: readOnly
                  ? cs.outline.withValues(alpha: 0.06)
                  : cs.surface,
              contentPadding: AppInsets.inputContent,
              border: OutlineInputBorder(
                borderRadius: AppCorners.r12,
                borderSide: BorderSide(color: cs.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppCorners.r12,
                borderSide: BorderSide(color: cs.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppCorners.r12,
                borderSide: BorderSide(
                  color: AppPalette.primaryBlue,
                  width: AppBorder.strong,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s10),
          ...List.generate(plan.scheduleConfig.length, (dayIndex) {
            final schedule = plan.scheduleConfig[dayIndex];
            final blockedDateKeys = plan.scheduleConfig
                .asMap()
                .entries
                .where((entry) => entry.key != dayIndex)
                .map((entry) => _dateKey(entry.value.exerciseDate))
                .toSet();
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s10),
              child: _ScheduleDayCard(
                key: ValueKey('day_${plan.exerciseId}_$dayIndex'),
                schedule: schedule,
                dayIndex: dayIndex,
                canRemoveDay: !readOnly,
                initiallyExpanded: dayIndex == plan.scheduleConfig.length - 1,
                readOnly: readOnly,
                onRemoveDay: () => onRemoveScheduleDay(dayIndex),
                onDateTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: schedule.exerciseDate,
                    firstDate: goalStartDate ?? DateTime(2020),
                    lastDate: goalEndDate ?? DateTime(2035),
                    selectableDayPredicate: (candidate) {
                      final normalized = DateTime(
                        candidate.year,
                        candidate.month,
                        candidate.day,
                      );
                      final key = _dateKey(normalized);
                      return !blockedDateKeys.contains(key);
                    },
                  );
                  if (picked != null) onScheduleDateChanged(dayIndex, picked);
                },
                onAddSlot: () => onAddSlot(dayIndex),
                onRemoveSlot: (slotIndex) => onRemoveSlot(dayIndex, slotIndex),
                onSlotChanged: (slotIndex, slot) =>
                    onSlotChanged(dayIndex, slotIndex, slot),
              ),
            );
          }),
          if (!readOnly)
            TextButton.icon(
              onPressed: () async {
                final usedDateKeys = plan.scheduleConfig
                    .map((s) => _dateKey(s.exerciseDate))
                    .toSet();
                final rangeStart = DateTime(
                  (goalStartDate ?? DateTime.now()).year,
                  (goalStartDate ?? DateTime.now()).month,
                  (goalStartDate ?? DateTime.now()).day,
                );
                final rangeEnd = DateTime(
                  (goalEndDate ?? DateTime(2035)).year,
                  (goalEndDate ?? DateTime(2035)).month,
                  (goalEndDate ?? DateTime(2035)).day,
                );

                DateTime candidate = plan.scheduleConfig.isNotEmpty
                    ? DateTime(
                        plan.scheduleConfig.last.exerciseDate.year,
                        plan.scheduleConfig.last.exerciseDate.month,
                        plan.scheduleConfig.last.exerciseDate.day,
                      ).add(const Duration(days: 1))
                    : rangeStart;
                if (candidate.isBefore(rangeStart)) candidate = rangeStart;

                while (!candidate.isAfter(rangeEnd) &&
                    usedDateKeys.contains(_dateKey(candidate))) {
                  candidate = candidate.add(const Duration(days: 1));
                }

                if (candidate.isAfter(rangeEnd)) {
                  AppSnackbar.warning(
                    context,
                    'All dates in the goal range are already scheduled.',
                  );
                  return;
                }

                final picked = await showDatePicker(
                  context: context,
                  initialDate: candidate,
                  firstDate: rangeStart,
                  lastDate: rangeEnd,
                  selectableDayPredicate: (day) {
                    final key = _dateKey(
                      DateTime(day.year, day.month, day.day),
                    );
                    return !usedDateKeys.contains(key);
                  },
                );
                if (picked != null) onAddScheduleDay(picked);
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 16),
              label: const Text('Add exercise date'),
            ),
        ],
      ),
    );
  }

  String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return '${normalized.year}-${normalized.month}-${normalized.day}';
  }
}

class _ScheduleDayCard extends StatefulWidget {
  final GoalExerciseScheduleDraft schedule;
  final int dayIndex;
  final bool readOnly;
  final bool canRemoveDay;
  final bool initiallyExpanded;
  final VoidCallback onDateTap;
  final VoidCallback onAddSlot;
  final VoidCallback onRemoveDay;
  final ValueChanged<int> onRemoveSlot;
  final void Function(int slotIndex, GoalExerciseSlotDraft slot) onSlotChanged;

  const _ScheduleDayCard({
    super.key,
    required this.schedule,
    required this.dayIndex,
    required this.readOnly,
    required this.canRemoveDay,
    this.initiallyExpanded = false,
    required this.onDateTap,
    required this.onAddSlot,
    required this.onRemoveDay,
    required this.onRemoveSlot,
    required this.onSlotChanged,
  });

  @override
  State<_ScheduleDayCard> createState() => _ScheduleDayCardState();
}

class _ScheduleDayCardState extends State<_ScheduleDayCard> {
  late bool _slotsExpanded;

  @override
  void initState() {
    super.initState();
    _slotsExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final slots = widget.schedule.slots;
    final canAddMoreSlot = slots.length < 3;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s10),
      decoration: BoxDecoration(
        color: cs.outline.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadius.r8),
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.4),
          width: AppBorder.regular,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: widget.readOnly ? null : widget.onDateTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 16,
                      color: widget.readOnly
                          ? cs.onSurface.withValues(alpha: 0.5)
                          : AppPalette.primaryBlue,
                    ),
                    const SizedBox(width: AppSpacing.s4),
                    Text(
                      _formatDate(widget.schedule.exerciseDate),
                      style: context.bodySmall?.copyWith(
                        color: widget.readOnly
                            ? cs.onSurface.withValues(alpha: 0.7)
                            : AppPalette.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!widget.readOnly) ...[
                      const SizedBox(width: AppSpacing.s4),
                      Icon(
                        Icons.edit_rounded,
                        size: 12,
                        color: AppPalette.primaryBlue.withValues(alpha: 0.7),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              if (widget.canRemoveDay)
                GestureDetector(
                  onTap: widget.onRemoveDay,
                  child: Icon(Icons.close_rounded, size: 18, color: cs.error),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          InkWell(
            onTap: () => setState(() => _slotsExpanded = !_slotsExpanded),
            borderRadius: BorderRadius.circular(AppRadius.r8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.s4,
                horizontal: AppSpacing.s2,
              ),
              child: Row(
                children: [
                  Icon(
                    _slotsExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 18,
                    color: AppPalette.primaryBlue,
                  ),
                  const SizedBox(width: AppSpacing.s4),
                  Text(
                    slots.isEmpty
                        ? 'Add time slots'
                        : _slotsExpanded
                        ? 'Hide time slots (${slots.length})'
                        : 'Show time slots (${slots.length})',
                    style: context.bodySmall?.copyWith(
                      color: AppPalette.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_slotsExpanded) ...[
            const SizedBox(height: AppSpacing.s6),
            ...List.generate(slots.length, (slotIndex) {
              final slot = slots[slotIndex];
              final usedOtherPeriods = slots
                  .asMap()
                  .entries
                  .where((entry) => entry.key != slotIndex)
                  .map((entry) => _normalizePeriod(entry.value.period))
                  .toSet();
              final currentPeriod = _normalizePeriod(slot.period);
              final availablePeriods = ['morning', 'afternoon', 'evening']
                  .where(
                    (period) =>
                        period == currentPeriod ||
                        !usedOtherPeriods.contains(period),
                  )
                  .toList();

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                child: _SlotEditor(
                  key: ValueKey('slot_${widget.dayIndex}_$slotIndex'),
                  slot: slot,
                  readOnly: widget.readOnly,
                  canRemove: !widget.readOnly && slots.length > 1,
                  availablePeriods: availablePeriods,
                  onRemove: () => widget.onRemoveSlot(slotIndex),
                  onChanged: (updated) =>
                      widget.onSlotChanged(slotIndex, updated),
                ),
              );
            }),
            if (!widget.readOnly)
              TextButton.icon(
                onPressed: canAddMoreSlot
                    ? () {
                        widget.onAddSlot();
                        setState(() => _slotsExpanded = true);
                      }
                    : null,
                icon: const Icon(Icons.add_alarm_rounded, size: 16),
                label: Text(
                  canAddMoreSlot ? 'Add time slot' : 'Maximum 3 time slots',
                ),
              ),
          ] else if (!widget.readOnly && slots.isEmpty) ...[
            const SizedBox(height: AppSpacing.s4),
            TextButton.icon(
              onPressed: () {
                widget.onAddSlot();
                setState(() => _slotsExpanded = true);
              },
              icon: const Icon(Icons.add_alarm_rounded, size: 16),
              label: const Text('Add time slot'),
            ),
          ],
        ],
      ),
    );
  }

  String _normalizePeriod(String period) {
    final normalized = period.trim().toLowerCase();
    if (normalized == 'afternoon' || normalized == 'evening') {
      return normalized;
    }
    return 'morning';
  }

  String _formatDate(DateTime date) => DateUtilsHelper.formatDateDMY(date);
}

class _SlotEditor extends StatelessWidget {
  final GoalExerciseSlotDraft slot;
  final bool readOnly;
  final bool canRemove;
  final List<String> availablePeriods;
  final ValueChanged<GoalExerciseSlotDraft> onChanged;
  final VoidCallback onRemove;

  const _SlotEditor({
    super.key,
    required this.slot,
    required this.readOnly,
    required this.canRemove,
    required this.availablePeriods,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.r8),
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.4),
          width: AppBorder.regular,
        ),
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 420;

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPeriodDropdown(),
                    const SizedBox(height: AppSpacing.s8),
                    _buildTimeButton(context),
                    if (canRemove) ...[
                      const SizedBox(height: AppSpacing.s4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: onRemove,
                          icon: Icon(
                            Icons.remove_circle_outline_rounded,
                            color: cs.error,
                            size: AppSize.iconSm,
                          ),
                          label: Text(
                            'Remove slot',
                            style: context.labelMedium?.copyWith(
                              color: cs.error,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 3, child: _buildPeriodDropdown()),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(flex: 2, child: _buildTimeButton(context)),
                  if (canRemove) ...[
                    const SizedBox(width: AppSpacing.s4),
                    IconButton(
                      onPressed: onRemove,
                      tooltip: 'Remove slot',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: AppButtonSize.sm,
                        height: AppButtonSize.sm,
                      ),
                      icon: Icon(
                        Icons.remove_circle_outline_rounded,
                        color: cs.error,
                        size: AppSize.iconSm,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.s8),
          const SectionLabel(label: 'Slot instruction (optional)'),
          const SizedBox(height: AppSpacing.s6),
          TextFormField(
            key: ValueKey('slot_instruction_${slot.period}_${slot.time}'),
            initialValue: slot.instruction,
            readOnly: readOnly,
            onChanged: (value) => onChanged(slot.copyWith(instruction: value)),
            maxLines: 1,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'e.g. Cool down after session',
              hintStyle: TextStyle(fontSize: 13),
              border: OutlineInputBorder(borderRadius: AppCorners.r12),
              enabledBorder: OutlineInputBorder(borderRadius: AppCorners.r12),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppCorners.r12,
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: AppBorder.strong,
                ),
              ),
              contentPadding: AppInsets.inputContent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodDropdown() {
    final periods = availablePeriods.isEmpty
        ? const ['morning', 'afternoon', 'evening']
        : availablePeriods;
    final normalizedCurrent = _normalizePeriod(slot.period);
    final initialValue = periods.contains(normalizedCurrent)
        ? normalizedCurrent
        : periods.first;

    return DropdownButtonFormField<String>(
      initialValue: initialValue,
      isExpanded: true,
      onChanged: readOnly
          ? null
          : (value) {
              if (value == null) return;
              onChanged(slot.copyWith(period: value));
            },
      items: periods
          .map(
            (period) => DropdownMenuItem(
              value: period,
              child: Text(_periodLabel(period)),
            ),
          )
          .toList(),
      decoration: const InputDecoration(
        labelText: 'Period',
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _buildTimeButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: readOnly ? null : () => _pickTime(context),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s10,
          vertical: AppSpacing.s10,
        ),
        minimumSize: const Size(0, AppButtonSize.sm),
      ),
      icon: const Icon(Icons.schedule_rounded, size: AppSize.iconSm),
      label: Text(slot.time),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final initial = _parseTime(slot.time);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    final hour = picked.hour.toString().padLeft(2, '0');
    final minute = picked.minute.toString().padLeft(2, '0');
    onChanged(slot.copyWith(time: '$hour:$minute'));
  }

  TimeOfDay _parseTime(String value) => DateUtilsHelper.parseTimeOfDay(value);

  String _normalizePeriod(String period) {
    final normalized = period.trim().toLowerCase();
    if (normalized == 'afternoon' || normalized == 'evening') {
      return normalized;
    }
    return 'morning';
  }

  String _periodLabel(String period) {
    return switch (period) {
      'morning' => 'Morning',
      'afternoon' => 'Afternoon',
      'evening' => 'Evening',
      _ => period,
    };
  }
}
