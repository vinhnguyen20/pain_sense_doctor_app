import 'package:app_doctor/core/utils/date_utils_helper.dart';
import 'package:app_doctor/common/widgets/custom_app_bar.dart';
import 'package:app_doctor/common/widgets/clinician_header.dart';
import 'package:app_doctor/features/diary/data/models/goal_item_model.dart';
import 'package:app_doctor/common/widgets/app_snackbar.dart';
import 'package:app_doctor/core/network/errors/exception_handler.dart';
import 'package:app_doctor/features/diary/domain/entites/user_goal_request.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';
import 'package:app_doctor/features/education/domain/entites/exercise.dart';
import 'package:app_doctor/features/education/presentation/provider/exercise_picker_notifier.dart';
import 'package:app_doctor/features/user/presentation/provider/user_notifier.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/exercise_picker_bottomsheet.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_action_button.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_bottom_action.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_items_card.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_category_chip.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_frequency.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_shared_widget.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/selected_exercise_session.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/goal_consent_checkbox.dart';
import '../widgets/goal_date_row.dart';
import '../widgets/goal_status_badge.dart';

class GoalFormPage extends ConsumerStatefulWidget {
  final GoalFormMode mode;
  final GoalModel? initialGoal;
  final String patientId;
  final List<Map<String, dynamic>> prefillGoalItems;

  final List<GoalItemModel>? originalGoalItems;
  final bool useClinicianLayout;
  final bool showClinicianHeader;

  const GoalFormPage({
    super.key,
    this.mode = GoalFormMode.create,
    this.initialGoal,
    required this.patientId,
    this.prefillGoalItems = const [],
    this.originalGoalItems,
    this.useClinicianLayout = false,
    this.showClinicianHeader = true,
  });

  @override
  ConsumerState<GoalFormPage> createState() => _GoalFormPageState();
}

class _GoalFormPageState extends ConsumerState<GoalFormPage>
    with SingleTickerProviderStateMixin {
  late GoalModel _goal;

  late final TextEditingController _titleCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _scheduleCtrl;
  late final TextEditingController _notesCtrl;
  late final Map<GoalCategory, bool> _selectedGoalCategories;
  late final Map<GoalCategory, TextEditingController> _goalItemTitleCtrls;
  late final Map<GoalCategory, TextEditingController> _goalItemTargetCtrls;
  late final Map<GoalCategory, TextEditingController> _goalItemDescCtrls;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  bool _isSubmitting = false;
  final Set<int> _selectedWeekDays = {};

  bool get _isReadOnly => widget.mode == GoalFormMode.view;
  bool get _isCreating => widget.mode == GoalFormMode.create;
  bool get _isEditing => widget.mode == GoalFormMode.edit;
  bool get _isYoga => _isReadOnly
      ? _goal.category == GoalCategory.yoga
      : (_selectedGoalCategories[GoalCategory.yoga] ?? false);

  void _applyCreatePrefillItems() {
    if (!_isCreating) return;
    if (widget.prefillGoalItems.isEmpty) return;

    for (final item in widget.prefillGoalItems) {
      final category = GoalCategory.fromRaw(item['category']?.toString());
      if (category == null) continue;

      _selectedGoalCategories[category] = true;
      final title = item['title']?.toString().trim() ?? '';
      final target = item['target']?.toString().trim() ?? '';
      final description = item['description']?.toString().trim() ?? '';

      if (title.isNotEmpty) {
        _goalItemTitleCtrls[category]!.text = title;
      }
      if (target.isNotEmpty) {
        _goalItemTargetCtrls[category]!.text = target;
      }
      if (description.isNotEmpty) {
        _goalItemDescCtrls[category]!.text = description;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _goal = widget.initialGoal ?? const GoalModel();
    final now = DateTime.now();
    final defaultStartDate =
        _goal.startDate ?? DateTime(now.year, now.month, now.day);
    _goal = _goal.copyWith(
      selectedExercisePlans: _syncExercisePlans(
        _goal.selectedExerciseIds,
        defaultStartDate,
      ),
    );

    _titleCtrl = TextEditingController(text: _goal.title);
    _targetCtrl = TextEditingController(text: _goal.target);
    _descCtrl = TextEditingController(text: _goal.description);
    _scheduleCtrl = TextEditingController(text: _goal.notificationSchedule);
    _notesCtrl = TextEditingController(text: _goal.educationNotes);
    _selectedGoalCategories = {
      for (final category in GoalCategory.values) category: false,
    };
    _goalItemTitleCtrls = {
      for (final category in GoalCategory.values)
        category: TextEditingController(),
    };
    _goalItemTargetCtrls = {
      for (final category in GoalCategory.values)
        category: TextEditingController(),
    };
    _goalItemDescCtrls = {
      for (final category in GoalCategory.values)
        category: TextEditingController(),
    };

    if (_isCreating && widget.initialGoal != null) {
      final category = _goal.category;
      _selectedGoalCategories[category] = true;
      _goalItemTitleCtrls[category]!.text = _goal.title;
      _goalItemTargetCtrls[category]!.text = _goal.target;
      _goalItemDescCtrls[category]!.text = _goal.description;
    }
    _applyCreatePrefillItems();
    if (widget.useClinicianLayout &&
        _isCreating &&
        !_selectedGoalCategories.values.any((selected) => selected)) {
      _selectedGoalCategories[_goal.category] = true;
    }

    if (_isEditing && widget.originalGoalItems != null) {
      for (final item in widget.originalGoalItems!) {
        final category = GoalCategory.fromGoalType(item.type);
        _selectedGoalCategories[category] = true;
        _goalItemTitleCtrls[category]!.text = item.label;
        _goalItemTargetCtrls[category]!.text = item.minTarget.toString();
        _goalItemDescCtrls[category]!.text = item.desc;
      }
      final yogaItems = widget.originalGoalItems!
          .where(
            (item) => GoalCategory.fromGoalType(item.type) == GoalCategory.yoga,
          )
          .toList();
      if (yogaItems.isNotEmpty) {
        final userExercises = yogaItems.first.userExercises ?? const [];
        if (userExercises.isNotEmpty) {
          final plans = userExercises.map((ue) {
            final realId = ue.resolvedExerciseId;
            final scheduleConfig = ue.scheduleConfig
                .map(
                  (sc) => GoalExerciseScheduleDraft(
                    exerciseDate: sc.exerciseDate,
                    slots: sc.slots
                        .map(
                          (sl) => GoalExerciseSlotDraft(
                            period: sl.period,
                            time: sl.time,
                            instruction: sl.instruction ?? '',
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList();
            return GoalExercisePlanDraft(
              exerciseId: realId,
              scheduleConfig: scheduleConfig,
            );
          }).toList();
          _goal = _goal.copyWith(
            selectedExerciseIds: plans.map((p) => p.exerciseId).toList(),
            selectedExercisePlans: plans,
          );
        } else {
          final rawIds = yogaItems.first.userExerciseIds ?? const [];
          final exerciseIds = rawIds
              .map((id) => id.contains('+') ? id.split('+').first : id)
              .where((id) => id.isNotEmpty)
              .toList();
          if (exerciseIds.isNotEmpty) {
            _goal = _goal.copyWith(
              selectedExerciseIds: exerciseIds,
              selectedExercisePlans: _syncExercisePlans(
                exerciseIds,
                _goal.startDate ?? DateTime.now(),
              ),
            );
          }
        }
      }
    }

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    if (_isEditing && (_selectedGoalCategories[GoalCategory.yoga] ?? false)) {
      final idsToLoad = List<String>.from(_goal.selectedExerciseIds);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(exercisePickerProvider.notifier).ensureIdsLoaded(idsToLoad);
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetCtrl.dispose();
    _descCtrl.dispose();
    _scheduleCtrl.dispose();
    _notesCtrl.dispose();
    for (final controller in _goalItemTitleCtrls.values) {
      controller.dispose();
    }
    for (final controller in _goalItemTargetCtrls.values) {
      controller.dispose();
    }
    for (final controller in _goalItemDescCtrls.values) {
      controller.dispose();
    }
    _fadeCtrl.dispose();
    super.dispose();
  }

  bool get _hasValidGoalDateRange {
    final start = _goal.startDate;
    final end = _goal.endDate;
    if (start == null || end == null) return false;
    return !DateUtilsHelper.normalizeDate(
      end,
    ).isBefore(DateUtilsHelper.normalizeDate(start));
  }

  void _showChooseDateRangeFirstMessage() {
    AppSnackbar.error(
      context,
      'Please choose Start Date and End Date first, then setup exercises.',
    );
  }

  String? _nextAvailablePeriod(List<GoalExerciseSlotDraft> slots) {
    const ordered = ['morning', 'afternoon', 'evening'];
    final used = slots
        .map((slot) => DateUtilsHelper.normalizePeriod(slot.period, slot.time))
        .toSet();

    for (final period in ordered) {
      if (!used.contains(period)) return period;
    }
    return null;
  }

  void _showConstraintMessage(String message) {
    AppSnackbar.error(context, message);
  }

  GoalExercisePlanDraft _createDefaultExercisePlan(
    String exerciseId,
    DateTime startDate,
  ) {
    return GoalExercisePlanDraft(
      exerciseId: exerciseId,
      scheduleConfig: const [],
    );
  }

  List<GoalExercisePlanDraft> _syncExercisePlans(
    List<String> selectedIds,
    DateTime startDate,
  ) {
    final existingById = <String, GoalExercisePlanDraft>{
      for (final plan in _goal.selectedExercisePlans) plan.exerciseId: plan,
    };

    return selectedIds.map((id) {
      final trimmedId = id.trim();
      return existingById[trimmedId] ??
          _createDefaultExercisePlan(trimmedId, startDate);
    }).toList();
  }

  void _updateExercisePlan(
    String exerciseId,
    GoalExercisePlanDraft Function(GoalExercisePlanDraft current) transform,
  ) {
    final plans = _goal.selectedExercisePlans
        .map((plan) => plan.exerciseId == exerciseId ? transform(plan) : plan)
        .toList();

    setState(() {
      _goal = _goal.copyWith(selectedExercisePlans: plans);
    });
  }

  void _updateDoctorInstruction(String exerciseId, String value) {
    _updateExercisePlan(
      exerciseId,
      (current) => current.copyWith(doctorInstruction: value),
    );
  }

  void _addScheduleDay(String exerciseId, DateTime date) {
    final normalizedDate = DateUtilsHelper.normalizeDate(date);
    _updateExercisePlan(exerciseId, (current) {
      final isDuplicate = current.scheduleConfig.any(
        (s) =>
            DateUtilsHelper.dateKey(s.exerciseDate) ==
            DateUtilsHelper.dateKey(normalizedDate),
      );
      if (isDuplicate) {
        _showConstraintMessage(
          'This exercise day is already configured. Please choose another date.',
        );
        return current;
      }
      final updated = [
        ...current.scheduleConfig,
        GoalExerciseScheduleDraft(exerciseDate: normalizedDate, slots: []),
      ];
      return current.copyWith(scheduleConfig: updated);
    });
  }

  void _removeScheduleDay(String exerciseId, int dayIndex) {
    _updateExercisePlan(exerciseId, (current) {
      final updated = [...current.scheduleConfig]..removeAt(dayIndex);
      return current.copyWith(scheduleConfig: updated);
    });
  }

  void _updateScheduleDate(String exerciseId, int dayIndex, DateTime date) {
    final normalizedDate = DateUtilsHelper.normalizeDate(date);
    GoalExercisePlanDraft? currentPlan;
    for (final plan in _goal.selectedExercisePlans) {
      if (plan.exerciseId == exerciseId) {
        currentPlan = plan;
        break;
      }
    }
    if (currentPlan == null) return;

    final isDuplicated = currentPlan.scheduleConfig.asMap().entries.any((
      entry,
    ) {
      if (entry.key == dayIndex) return false;
      return DateUtilsHelper.dateKey(entry.value.exerciseDate) ==
          DateUtilsHelper.dateKey(normalizedDate);
    });
    if (isDuplicated) {
      _showConstraintMessage(
        'This exercise day is already configured. Please choose another date.',
      );
      return;
    }

    _updateExercisePlan(exerciseId, (current) {
      final schedules = [...current.scheduleConfig];
      if (dayIndex < 0 || dayIndex >= schedules.length) return current;
      schedules[dayIndex] = schedules[dayIndex].copyWith(
        exerciseDate: normalizedDate,
      );
      return current.copyWith(scheduleConfig: schedules);
    });
  }

  void _addScheduleSlot(String exerciseId, int dayIndex) {
    _updateExercisePlan(exerciseId, (current) {
      final schedules = [...current.scheduleConfig];
      if (dayIndex < 0 || dayIndex >= schedules.length) return current;

      final target = schedules[dayIndex];
      if (target.slots.length >= 3) {
        _showConstraintMessage(
          'Each exercise day supports up to 3 slots: morning, afternoon, evening.',
        );
        return current;
      }

      final nextPeriod = _nextAvailablePeriod(target.slots);
      if (nextPeriod == null) {
        _showConstraintMessage(
          'Morning, afternoon, and evening are already configured for this day.',
        );
        return current;
      }

      final updatedSlots = [
        ...target.slots,
        GoalExerciseSlotDraft(
          period: nextPeriod,
          time: DateUtilsHelper.defaultTimeForPeriod(nextPeriod),
          instruction: current.doctorInstruction,
        ),
      ];
      schedules[dayIndex] = target.copyWith(slots: updatedSlots);
      return current.copyWith(scheduleConfig: schedules);
    });
  }

  void _removeScheduleSlot(String exerciseId, int dayIndex, int slotIndex) {
    _updateExercisePlan(exerciseId, (current) {
      final schedules = [...current.scheduleConfig];
      if (dayIndex < 0 || dayIndex >= schedules.length) return current;

      final target = schedules[dayIndex];
      final updatedSlots = [...target.slots]..removeAt(slotIndex);
      schedules[dayIndex] = target.copyWith(slots: updatedSlots);
      return current.copyWith(scheduleConfig: schedules);
    });
  }

  void _updateScheduleSlot(
    String exerciseId,
    int dayIndex,
    int slotIndex,
    GoalExerciseSlotDraft slot,
  ) {
    _updateExercisePlan(exerciseId, (current) {
      final schedules = [...current.scheduleConfig];
      if (dayIndex < 0 || dayIndex >= schedules.length) return current;

      final target = schedules[dayIndex];
      if (slotIndex < 0 || slotIndex >= target.slots.length) return current;

      final currentSlot = target.slots[slotIndex];
      var nextSlot = slot;

      if (nextSlot.period != currentSlot.period &&
          nextSlot.time == currentSlot.time &&
          !DateUtilsHelper.isTimeInPeriod(nextSlot.time, nextSlot.period)) {
        nextSlot = nextSlot.copyWith(
          time: DateUtilsHelper.defaultTimeForPeriod(nextSlot.period),
        );
      }

      if (!DateUtilsHelper.isValidTime(nextSlot.time)) {
        _showConstraintMessage('Time must use 24h format HH:mm.');
        return current;
      }

      if (!DateUtilsHelper.isTimeInPeriod(nextSlot.time, nextSlot.period)) {
        _showConstraintMessage(
          'Time does not match selected period. Morning: 00:00-11:59, Afternoon: 12:00-17:59, Evening: 18:00-23:59.',
        );
        return current;
      }

      final normalizedPeriod = DateUtilsHelper.normalizePeriod(
        nextSlot.period,
        nextSlot.time,
      );
      final duplicatedPeriod = target.slots.asMap().entries.any((entry) {
        if (entry.key == slotIndex) return false;
        final other = entry.value;
        return DateUtilsHelper.normalizePeriod(other.period, other.time) ==
            normalizedPeriod;
      });
      if (duplicatedPeriod) {
        _showConstraintMessage(
          'Each day can only have one slot per period (morning/afternoon/evening).',
        );
        return current;
      }

      final updatedSlots = [...target.slots];
      updatedSlots[slotIndex] = nextSlot;
      schedules[dayIndex] = target.copyWith(slots: updatedSlots);
      return current.copyWith(scheduleConfig: schedules);
    });
  }

  String? _validateYogaPlans(
    List<GoalExercisePlanDraft> plans,
    DateTime startDate,
    DateTime endDate,
  ) {
    for (final plan in plans) {
      final usedDateKeys = <String>{};
      for (final schedule in plan.scheduleConfig) {
        final date = DateUtilsHelper.normalizeDate(schedule.exerciseDate);
        final dateKey = DateUtilsHelper.dateKey(date);
        if (usedDateKeys.contains(dateKey)) {
          return 'Each exercise day must be unique for an exercise.';
        }
        usedDateKeys.add(dateKey);

        if (date.isBefore(DateUtilsHelper.normalizeDate(startDate)) ||
            date.isAfter(DateUtilsHelper.normalizeDate(endDate))) {
          return 'Exercise dates must be within Start Date and End Date.';
        }

        if (schedule.slots.isEmpty) {
          return 'Each exercise date must have at least one time slot.';
        }

        if (schedule.slots.length > 3) {
          return 'Each exercise day supports up to 3 slots: morning, afternoon, evening.';
        }

        final usedPeriods = <String>{};
        for (final slot in schedule.slots) {
          if (!DateUtilsHelper.isValidTime(slot.time)) {
            return 'Time must use 24h format HH:mm.';
          }

          final period = DateUtilsHelper.normalizePeriod(
            slot.period,
            slot.time,
          );
          if (period != 'morning' &&
              period != 'afternoon' &&
              period != 'evening') {
            return 'Period must be morning, afternoon, or evening.';
          }
          if (usedPeriods.contains(period)) {
            return 'Each exercise day can only have one slot per period.';
          }
          usedPeriods.add(period);
          if (!DateUtilsHelper.isTimeInPeriod(slot.time, period)) {
            return 'Time does not match period. Morning: 00:00-11:59, Afternoon: 12:00-17:59, Evening: 18:00-23:59.';
          }
        }
      }
    }
    return null;
  }

  List<GoalExercisePlanDraft>? _resolveYogaPlans({
    required List<String> selectedExerciseIds,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_hasValidGoalDateRange) {
      _showChooseDateRangeFirstMessage();
      return null;
    }
    if (selectedExerciseIds.isEmpty) {
      AppSnackbar.error(
        context,
        'Please select at least one exercise for Yoga/Meditation.',
      );
      return null;
    }
    final plans = _syncExercisePlans(selectedExerciseIds, startDate);
    final error = _validateYogaPlans(plans, startDate, endDate);
    if (error != null) {
      AppSnackbar.error(context, error);
      return null;
    }
    return plans;
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;

    if (widget.patientId.trim().isEmpty) {
      AppSnackbar.error(context, 'Patient id is missing. Cannot submit goal.');
      return;
    }

    if (!_goal.patientConsent) {
      AppSnackbar.error(
        context,
        'Patient consent is required before submitting this goal.',
      );
      return;
    }

    if (_isCreating) {
      await _submitCreateMode();
      return;
    }

    if (_isEditing) {
      await _submitEditMode();
      return;
    }

    _submitEditViewMode();
  }

  Future<void> _submitCreateMode() async {
    final now = DateTime.now();
    final startDate = _goal.startDate ?? DateTime(now.year, now.month, now.day);
    final endDate = _goal.endDate;
    if (endDate == null) {
      AppSnackbar.error(context, 'End Date is required.');
      return;
    }
    if (endDate.isBefore(startDate)) {
      AppSnackbar.error(
        context,
        'End Date must be the same or after Start Date.',
      );
      return;
    }

    final selectedCategories = GoalCategory.values
        .where((category) => _selectedGoalCategories[category] == true)
        .toList();
    if (selectedCategories.isEmpty) {
      AppSnackbar.error(context, 'Please select at least one goal type.');
      return;
    }

    final selectedExerciseIds = _goal.selectedExerciseIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();
    final hasYoga = selectedCategories.contains(GoalCategory.yoga);
    List<GoalExercisePlanDraft> yogaPlans = const [];
    if (hasYoga) {
      final plans = _resolveYogaPlans(
        selectedExerciseIds: selectedExerciseIds,
        startDate: startDate,
        endDate: endDate,
      );
      if (plans == null) return;
      yogaPlans = plans;
    }

    final goalItems = <UserGoalItem>[];
    for (final category in selectedCategories) {
      final title = _goalItemTitleCtrls[category]!.text.trim();
      final description = _goalItemDescCtrls[category]!.text.trim();
      final parsedTarget = _parseNumericTarget(
        _goalItemTargetCtrls[category]!.text,
      );
      if (title.isEmpty) {
        AppSnackbar.error(context, 'Please enter title for ${category.label}.');
        return;
      }

      num minTarget;
      if (category == GoalCategory.yoga) {
        minTarget = _computedYogaTarget;
      } else {
        if (parsedTarget == null) {
          AppSnackbar.error(
            context,
            'Please enter a valid target greater than 0 for ${category.label}.',
          );
          return;
        }
        minTarget = parsedTarget;
      }

      goalItems.add(
        UserGoalItem(
          type: category.goalType,
          minTarget: minTarget,
          unit: category.unit,
          label: title,
          desc: description,
        ),
      );
    }

    final assignedDate = DateTime(now.year, now.month, now.day);
    final exercises = hasYoga
        ? _buildExerciseAssignments(
            plans: yogaPlans,
            assignedDate: assignedDate,
            startDate: startDate,
            endDate: endDate,
          )
        : <UserGoalExerciseAssignment>[];

    setState(() => _isSubmitting = true);
    try {
      final response = await ref
          .read(diaryRepositoryProvider)
          .createUserGoalsWithExercises(
            CreateUserGoalWithExercisesRequest(
              userId: widget.patientId.trim(),
              startDate: startDate,
              endDate: endDate,
              exercises: exercises,
              goalItems: goalItems,
            ),
          );

      if (!mounted) return;

      if (response.isSuccess) {
        AppSnackbar.success(context, 'Goals created successfully.');
        Navigator.of(context).pop(true);
        return;
      }

      AppSnackbar.error(
        context,
        _resolveCreateGoalErrorMessage(response.message),
      );
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error(context, ExceptionHandler.handle(error).message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _submitEditViewMode() async {
    if (_isYoga && !_hasValidGoalDateRange) {
      _showChooseDateRangeFirstMessage();
      return;
    }

    final title = _titleCtrl.text.trim();
    final description = _descCtrl.text.trim();
    final normalizedTarget = _parseNumericTarget(_targetCtrl.text);

    if (title.isEmpty) {
      AppSnackbar.error(context, 'Goal title is required.');
      return;
    }

    if (!_isYoga && normalizedTarget == null) {
      AppSnackbar.error(context, 'Please enter a valid target greater than 0.');
      return;
    }

    if (_goal.id == null || _goal.id!.isEmpty) {
      AppSnackbar.error(context, 'Goal ID is missing. Cannot update.');
      return;
    }

    if (_goal.startDate == null || _goal.endDate == null) {
      AppSnackbar.error(context, 'Start Date and End Date are required.');
      return;
    }

    final editedItem = UserGoalItem(
      type: _goal.category.goalType,
      minTarget: normalizedTarget ?? _computedYogaTarget,
      unit: _goal.category.unit,
      label: title,
      desc: description,
      userExerciseIds: _isYoga ? _goal.selectedExerciseIds : null,
    );

    final List<UserGoalItem> goalItems;
    final originals = widget.originalGoalItems;
    if (originals != null && originals.isNotEmpty) {
      final hasMatch = originals.any((e) => e.type == _goal.category.goalType);
      goalItems = originals.map((orig) {
        if (orig.type == _goal.category.goalType) return editedItem;
        return UserGoalItem(
          type: orig.type,
          minTarget: orig.minTarget,
          unit: orig.unit,
          label: orig.label,
          desc: orig.desc,
          userExerciseIds: orig.userExerciseIds,
        );
      }).toList();
      if (!hasMatch) goalItems.add(editedItem);
    } else {
      goalItems = [editedItem];
    }

    final startDate = _goal.startDate!;
    final endDate = _goal.endDate!;
    final now = DateTime.now();
    final assignedDate = DateTime(now.year, now.month, now.day);
    final exercises = _isYoga
        ? _buildExerciseAssignments(
            plans: _goal.selectedExercisePlans,
            assignedDate: assignedDate,
            startDate: startDate,
            endDate: endDate,
          )
        : <UserGoalExerciseAssignment>[];

    setState(() => _isSubmitting = true);
    try {
      final response = await ref
          .read(diaryRepositoryProvider)
          .updateUserGoal(
            UpdateUserGoalRequest(
              goalId: _goal.id!,
              patientId: widget.patientId,
              startDate: startDate,
              endDate: endDate,
              exercises: exercises,
              goalItems: goalItems,
            ),
          );
      if (!mounted) return;
      if (response.isSuccess) {
        AppSnackbar.success(context, 'Goal updated successfully.');
        Navigator.of(context).pop(true);
        return;
      }
      AppSnackbar.error(context, response.message);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, ExceptionHandler.handle(e).message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitEditMode() async {
    final now = DateTime.now();
    final startDate = _goal.startDate ?? DateTime(now.year, now.month, now.day);
    final endDate = _goal.endDate;
    if (endDate == null) {
      AppSnackbar.error(context, 'End Date is required.');
      return;
    }
    if (endDate.isBefore(startDate)) {
      AppSnackbar.error(
        context,
        'End Date must be the same or after Start Date.',
      );
      return;
    }
    if (_goal.id == null || _goal.id!.isEmpty) {
      AppSnackbar.error(context, 'Goal ID is missing. Cannot update.');
      return;
    }

    final selectedCategories = GoalCategory.values
        .where((category) => _selectedGoalCategories[category] == true)
        .toList();
    if (selectedCategories.isEmpty) {
      AppSnackbar.error(context, 'Please select at least one goal type.');
      return;
    }

    final hasYoga = selectedCategories.contains(GoalCategory.yoga);
    final selectedExerciseIds = _goal.selectedExerciseIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();

    List<GoalExercisePlanDraft> yogaPlans = const [];
    if (hasYoga) {
      final plans = _resolveYogaPlans(
        selectedExerciseIds: selectedExerciseIds,
        startDate: startDate,
        endDate: endDate,
      );
      if (plans == null) return;
      yogaPlans = plans;
    }

    final goalItems = <UserGoalItem>[];
    for (final category in selectedCategories) {
      final title = _goalItemTitleCtrls[category]!.text.trim();
      final description = _goalItemDescCtrls[category]!.text.trim();
      final parsedTarget = _parseNumericTarget(
        _goalItemTargetCtrls[category]!.text,
      );
      if (title.isEmpty) {
        AppSnackbar.error(context, 'Please enter title for ${category.label}.');
        return;
      }
      num minTarget;
      if (category == GoalCategory.yoga) {
        minTarget = _computedYogaTarget;
      } else {
        if (parsedTarget == null) {
          AppSnackbar.error(
            context,
            'Please enter a valid target greater than 0 for ${category.label}.',
          );
          return;
        }
        minTarget = parsedTarget;
      }
      goalItems.add(
        UserGoalItem(
          type: category.goalType,
          minTarget: minTarget,
          unit: category.unit,
          label: title,
          desc: description,
          userExerciseIds: category == GoalCategory.yoga
              ? selectedExerciseIds
              : null,
        ),
      );
    }

    final assignedDate = DateTime(now.year, now.month, now.day);
    final exercises = hasYoga
        ? _buildExerciseAssignments(
            plans: yogaPlans,
            assignedDate: assignedDate,
            startDate: startDate,
            endDate: endDate,
          )
        : <UserGoalExerciseAssignment>[];

    setState(() => _isSubmitting = true);
    try {
      final response = await ref
          .read(diaryRepositoryProvider)
          .updateUserGoal(
            UpdateUserGoalRequest(
              goalId: _goal.id!,
              patientId: widget.patientId,
              startDate: startDate,
              endDate: endDate,
              exercises: exercises,
              goalItems: goalItems,
            ),
          );
      if (!mounted) return;
      if (response.isSuccess) {
        AppSnackbar.success(context, 'Goal updated successfully.');
        Navigator.of(context).pop(true);
        return;
      }
      AppSnackbar.error(context, response.message);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, ExceptionHandler.handle(e).message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  List<UserGoalExerciseAssignment> _buildExerciseAssignments({
    required List<GoalExercisePlanDraft> plans,
    required DateTime assignedDate,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return plans
        .map(
          (plan) => UserGoalExerciseAssignment(
            exerciseId: plan.exerciseId.trim(),
            assignedDate: assignedDate,
            startDate: startDate,
            endDate: endDate,
            doctorInstruction: plan.doctorInstruction.trim().isEmpty
                ? null
                : plan.doctorInstruction.trim(),
            scheduleConfig: plan.scheduleConfig
                .map(
                  (schedule) => UserGoalScheduleConfig(
                    exerciseDate: DateUtilsHelper.normalizeDate(
                      schedule.exerciseDate,
                    ),
                    sessionsCount: schedule.slots.isEmpty
                        ? 1
                        : schedule.slots.length,
                    slots: schedule.slots
                        .map(
                          (slot) => UserGoalScheduleSlot(
                            period: DateUtilsHelper.normalizePeriod(
                              slot.period,
                              slot.time,
                            ),
                            time: DateUtilsHelper.extractScheduleTime(
                              slot.time,
                            ),
                            instruction: slot.instruction.trim().isEmpty
                                ? null
                                : slot.instruction.trim(),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  num? _parseNumericTarget(String value) {
    final normalized = value.trim().replaceAll(',', '');
    if (normalized.isEmpty) return null;

    final parsed = num.tryParse(normalized);
    if (parsed == null || parsed <= 0) return null;
    if (parsed == parsed.roundToDouble()) return parsed.toInt();
    return parsed.toDouble();
  }

  String _resolveCreateGoalErrorMessage(String rawMessage) {
    final normalized = rawMessage.trim().toLowerCase();
    if (normalized.contains('đã tồn tại trong ngày hôm nay') ||
        normalized.contains('already exists') ||
        normalized.contains('already existed')) {
      return 'A goal already exists on this start date. Please choose another date.';
    }
    if (normalized.contains('exercise') && normalized.contains('required')) {
      return 'At least one assigned exercise is required.';
    }
    return rawMessage;
  }

  Widget _buildCreateCategorySelector() {
    return SectionCard(
      children: [
        const SectionLabel(label: 'Goal Types'),
        const SizedBox(height: AppSpacing.s8),
        Text(
          'Choose 1 to 3 goal types for one shared date range.',
          style: context.bodySmall?.copyWith(
            color: context.onSurface.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: AppSpacing.s10),
        GoalCategoryMultiChips(
          selected: _selectedGoalCategories,
          readOnly: _isReadOnly,
          onToggle: (category) {
            setState(() {
              final nextValue = !(_selectedGoalCategories[category] ?? false);
              _selectedGoalCategories[category] = nextValue;
              if (category == GoalCategory.yoga && !nextValue) {
                _goal = _goal.copyWith(
                  selectedExerciseIds: const [],
                  selectedExercisePlans: const [],
                );
              }
            });
          },
        ),
      ],
    );
  }

  int get _computedYogaTarget {
    if (_goal.selectedExercisePlans.isEmpty) {
      return _goal.selectedExerciseIds.length.clamp(1, double.infinity).toInt();
    }
    return _goal.selectedExercisePlans.fold(0, (sum, plan) {
      final totalSlots = plan.scheduleConfig.fold(
        0,
        (s, schedule) =>
            s + (schedule.slots.isEmpty ? 1 : schedule.slots.length),
      );
      return sum + (totalSlots == 0 ? 1 : totalSlots);
    });
  }

  Future<void> _openExercisePicker() async {
    final result = await showExercisePickerSheet(
      context: context,
      initialSelected: Set<String>.from(_goal.selectedExerciseIds),
    );

    if (result != null) {
      final now = DateTime.now();
      final fallbackStartDate =
          _goal.startDate ?? DateTime(now.year, now.month, now.day);
      final selectedIds = List<String>.from(result);
      setState(() {
        _goal = _goal.copyWith(
          selectedExerciseIds: selectedIds,
          selectedExercisePlans: _syncExercisePlans(
            selectedIds,
            fallbackStartDate,
          ),
        );
      });
    }
  }

  void _onStartDateChanged(DateTime? d) {
    if (d == null) return;
    setState(() {
      final normalizedStart = DateUtilsHelper.normalizeDate(d);
      DateTime? adjustedEnd = _goal.endDate;
      if (adjustedEnd != null &&
          DateUtilsHelper.normalizeDate(
            adjustedEnd,
          ).isBefore(normalizedStart)) {
        adjustedEnd = normalizedStart;
      }
      _goal = _goal.copyWith(startDate: normalizedStart, endDate: adjustedEnd);
    });
  }

  void _onEndDateChanged(DateTime? d) {
    if (d == null) return;
    setState(() {
      final normalizedEnd = DateUtilsHelper.normalizeDate(d);
      _goal = _goal.copyWith(endDate: normalizedEnd);
    });
  }

  GoalCategory get _clinicianCategory {
    for (final category in GoalCategory.values) {
      if (_selectedGoalCategories[category] == true) return category;
    }
    return _goal.category;
  }

  void _selectClinicianCategory(GoalCategory category) {
    setState(() {
      for (final value in GoalCategory.values) {
        _selectedGoalCategories[value] = value == category;
      }
      if (category != GoalCategory.yoga) {
        _goal = _goal.copyWith(
          selectedExerciseIds: const [],
          selectedExercisePlans: const [],
        );
      }
    });
  }

  Future<void> _pickClinicianDate({required bool isStartDate}) async {
    final now = DateTime.now();
    final current = isStartDate ? _goal.startDate : _goal.endDate;
    final firstDate = isStartDate ? DateTime(2020) : (_goal.startDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? (isStartDate ? now : (_goal.startDate ?? now)),
      firstDate: firstDate,
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    if (isStartDate) {
      _onStartDateChanged(picked);
    } else {
      _onEndDateChanged(picked);
    }
  }

  String _formatClinicianDate(DateTime? date, String placeholder) {
    if (date == null) return placeholder;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _onClinicianSubmit() async {
    if (_goal.patientConsent) {
      await _onSubmit();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Patient Consent',
          style: AppTypography.titleBig1.copyWith(
            color: AppPalette.secondaryBlue,
          ),
        ),
        content: const Text(
          'Confirm that the patient has been informed and agrees to this goal.',
          style: AppTypography.defaultBody2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _goal = _goal.copyWith(patientConsent: true));
    await _onSubmit();
  }

  Widget _buildYogaSection({required List<Exercise> availableExercises}) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: SectionCard(
        children: [
          const SectionLabel(label: 'Yoga Exercises Setup'),
          const SizedBox(height: AppSpacing.s10),
          SelectedExercisesSection(
            selectedIds: _goal.selectedExerciseIds,
            readOnly: _isReadOnly,
            onPickTap: _openExercisePicker,
            exercises: availableExercises,
            onRemove: (id) {
              setState(() {
                final remainingIds = _goal.selectedExerciseIds
                    .where((e) => e != id)
                    .toList();
                _goal = _goal.copyWith(
                  selectedExerciseIds: remainingIds,
                  selectedExercisePlans: _goal.selectedExercisePlans
                      .where((plan) => plan.exerciseId != id)
                      .toList(),
                );
              });
            },
          ),
          if (_goal.selectedExerciseIds.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s12),
            SelectedExerciseSessionsEditor(
              plans: _goal.selectedExercisePlans,
              exercises: availableExercises,
              readOnly: _isReadOnly,
              goalStartDate: _goal.startDate,
              goalEndDate: _goal.endDate,
              onDoctorInstructionChanged: _updateDoctorInstruction,
              onAddScheduleDay: (id, date) => _addScheduleDay(id, date),
              onRemoveScheduleDay: _removeScheduleDay,
              onScheduleDateChanged: _updateScheduleDate,
              onAddSlot: _addScheduleSlot,
              onRemoveSlot: _removeScheduleSlot,
              onSlotChanged: _updateScheduleSlot,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleCard({
    required String sectionLabel,
    bool optionalEndDate = false,
  }) {
    return SectionCard(
      children: [
        SectionLabel(label: sectionLabel),
        const SizedBox(height: AppSpacing.s8),
        GoalFrequencyDropdown(
          value: _goal.frequency,
          readOnly: _isReadOnly,
          onChanged: (f) =>
              setState(() => _goal = _goal.copyWith(frequency: f)),
        ),
        const SizedBox(height: AppSpacing.s14),
        GoalDateRow(
          label: 'Start Date',
          date: _goal.startDate,
          readOnly: _isReadOnly,
          lastDate: _goal.endDate ?? DateTime(2035),
          onChanged: _onStartDateChanged,
        ),
        const SizedBox(height: AppSpacing.s14),
        GoalDateRow(
          label: optionalEndDate && !_isYoga
              ? 'End Date (optional)'
              : 'End Date',
          date: _goal.endDate,
          readOnly: _isReadOnly,
          firstDate: _goal.startDate ?? DateTime(2020),
          onChanged: _onEndDateChanged,
        ),
      ],
    );
  }

  void _switchToEdit() {
    context.pushReplacementNamed(
      'goal-form',
      extra: {
        'mode': GoalFormMode.edit,
        'initialGoal': _goal,
        'patientId': widget.patientId,
        'originalGoalItems': widget.originalGoalItems,
      },
    );
  }

  Widget _buildClinicianGoalForm({required List<Exercise> availableExercises}) {
    final userState = ref.watch(userProvider);
    final fullName = userState.user?.fullName.trim();
    final doctorName = fullName == null || fullName.isEmpty
        ? 'Doctor'
        : 'Dr. $fullName';
    final category = _clinicianCategory;
    final targetController = _goalItemTargetCtrls[category]!;
    final titleController = _goalItemTitleCtrls[category]!;
    final descriptionController = _goalItemDescCtrls[category]!;

    return Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = context.isCompactShell
                ? constraints.maxWidth
                : constraints.maxWidth < 1208
                ? 1208.0
                : constraints.maxWidth;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                height: constraints.maxHeight,
                child: Padding(
                  padding: EdgeInsets.all(
                    context.isCompactShell ? AppSpacing.s16 : 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.showClinicianHeader) ...[
                        ClinicianHeader(
                          doctorName: doctorName,
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
                      ],
                      if (!widget.showClinicianHeader) ...[
                        Text(
                          _isCreating ? 'Create Goal' : 'Edit Goal',
                          style: AppTypography.display1.copyWith(
                            color: AppPalette.secondaryBlue,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (context.isCompactShell)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: AppPalette.secondaryBlue,
                          ),
                        ),
                      Expanded(
                        child: Stack(
                          children: [
                            SingleChildScrollView(
                              child: SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: context.isCompactShell ? 0 : 90,
                                    right: context.isCompactShell ? 0 : 40,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Goal Type',
                                        style: AppTypography.titleBig1.copyWith(
                                          color: AppPalette.secondaryBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Select an activity type to base your goal around.',
                                        style: AppTypography.denseBody1
                                            .copyWith(
                                              color: AppPalette.secondaryBlue,
                                            ),
                                      ),
                                      const SizedBox(height: 18),
                                      Center(
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 20,
                                          runSpacing: AppSpacing.s10,
                                          children: [
                                            _ClinicianGoalTypeButton(
                                              label: 'Exercise',
                                              icon:
                                                  Icons.fitness_center_rounded,
                                              selected:
                                                  category == GoalCategory.yoga,
                                              onPressed: () =>
                                                  _selectClinicianCategory(
                                                    GoalCategory.yoga,
                                                  ),
                                            ),
                                            _ClinicianGoalTypeButton(
                                              label: 'Steps',
                                              icon:
                                                  Icons.directions_walk_rounded,
                                              selected:
                                                  category ==
                                                  GoalCategory.steps,
                                              onPressed: () =>
                                                  _selectClinicianCategory(
                                                    GoalCategory.steps,
                                                  ),
                                            ),
                                            _ClinicianGoalTypeButton(
                                              label: 'Posture',
                                              icon: Icons.chair_alt_rounded,
                                              selected:
                                                  category ==
                                                  GoalCategory.activityTime,
                                              onPressed: () =>
                                                  _selectClinicianCategory(
                                                    GoalCategory.activityTime,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Center(
                                        child: Text(
                                          switch (category) {
                                            GoalCategory.steps =>
                                              'Set your Target Step Count',
                                            GoalCategory.activityTime =>
                                              'Set your Target Posture Score',
                                            GoalCategory.yoga =>
                                              'Set your Target Exercise Count',
                                          },
                                          style: AppTypography.titleBig1
                                              .copyWith(
                                                color: AppPalette.secondaryBlue,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Center(
                                        child: _ClinicianTargetInput(
                                          controller: targetController,
                                          readOnly:
                                              category == GoalCategory.yoga,
                                          computedValue:
                                              category == GoalCategory.yoga
                                              ? _computedYogaTarget
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'Goal Frequency',
                                        style: AppTypography.titleBig1.copyWith(
                                          color: AppPalette.secondaryBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Select how often you would like to see this goal.',
                                        style: AppTypography.denseBody1
                                            .copyWith(
                                              color: AppPalette.secondaryBlue,
                                            ),
                                      ),
                                      const SizedBox(height: 18),
                                      Center(
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 20,
                                          runSpacing: AppSpacing.s10,
                                          children: [
                                            _ClinicianChoiceButton(
                                              label: 'Daily',
                                              selected:
                                                  _goal.frequency ==
                                                  GoalFrequency.daily,
                                              onPressed: () => setState(
                                                () => _goal = _goal.copyWith(
                                                  frequency:
                                                      GoalFrequency.daily,
                                                ),
                                              ),
                                            ),
                                            _ClinicianChoiceButton(
                                              label: 'Certain Days of the Week',
                                              selected:
                                                  _goal.frequency ==
                                                  GoalFrequency.weekly,
                                              onPressed: () => setState(
                                                () => _goal = _goal.copyWith(
                                                  frequency:
                                                      GoalFrequency.weekly,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Center(
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: context.isCompactShell
                                              ? 8
                                              : 20,
                                          runSpacing: AppSpacing.s8,
                                          children: List.generate(7, (index) {
                                            const labels = [
                                              'Sun',
                                              'Mon',
                                              'Tues',
                                              'Wed',
                                              'Thurs',
                                              'Fri',
                                              'Sat',
                                            ];
                                            return _ClinicianDayButton(
                                              label: labels[index],
                                              selected: _selectedWeekDays
                                                  .contains(index),
                                              enabled:
                                                  _goal.frequency ==
                                                  GoalFrequency.weekly,
                                              onPressed: () => setState(() {
                                                if (_selectedWeekDays.contains(
                                                  index,
                                                )) {
                                                  _selectedWeekDays.remove(
                                                    index,
                                                  );
                                                } else {
                                                  _selectedWeekDays.add(index);
                                                }
                                              }),
                                            );
                                          }),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Center(
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 10,
                                          runSpacing: AppSpacing.s10,
                                          children: [
                                            _ClinicianDateButton(
                                              label: _formatClinicianDate(
                                                _goal.startDate,
                                                'Start Date...',
                                              ),
                                              onPressed: () =>
                                                  _pickClinicianDate(
                                                    isStartDate: true,
                                                  ),
                                            ),
                                            _ClinicianDateButton(
                                              label: _formatClinicianDate(
                                                _goal.endDate,
                                                'End Date...',
                                              ),
                                              onPressed: () =>
                                                  _pickClinicianDate(
                                                    isStartDate: false,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      _ClinicianGoalTextField(
                                        controller: titleController,
                                        hint: 'Name Your Goal...',
                                      ),
                                      const SizedBox(height: 20),
                                      _ClinicianGoalTextField(
                                        controller: descriptionController,
                                        hint: 'Describe Your Goal...',
                                        height: 70,
                                        maxLines: 3,
                                      ),
                                      if (category == GoalCategory.yoga) ...[
                                        const SizedBox(height: 20),
                                        _buildYogaSection(
                                          availableExercises:
                                              availableExercises,
                                        ),
                                      ],
                                      const SizedBox(height: 20),
                                      Center(
                                        child: GoalActionButton(
                                          label: _isCreating
                                              ? 'Create Goal'
                                              : 'Update Goal',
                                          width: 240,
                                          onPressed: _isSubmitting
                                              ? null
                                              : _onClinicianSubmit,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (!context.isCompactShell)
                              Positioned(
                                left: 0,
                                top: 390,
                                child: IconButton(
                                  onPressed: () => context.pop(),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 36,
                                    color: AppPalette.secondaryBlue,
                                  ),
                                ),
                              ),
                          ],
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

  @override
  Widget build(BuildContext context) {
    final availableExercises = ref.watch(exercisePickerProvider).exercises;

    if (widget.useClinicianLayout && (_isCreating || _isEditing)) {
      return _buildClinicianGoalForm(availableExercises: availableExercises);
    }

    return Scaffold(
      backgroundColor: context.surface,
      appBar: CustomAppBar(
        title: _isReadOnly
            ? 'Goal Details'
            : _isCreating
            ? 'Create Goal'
            : 'Edit Goal',
        showBackButton: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s20),

              if (_isReadOnly) ...[
                GoalStatusBadge(goal: _goal),
                const SizedBox(height: AppSpacing.s16),
              ],

              if (_isCreating || _isEditing) ...[
                _buildCreateCategorySelector(),
                const SizedBox(height: AppSpacing.s12),
                _buildScheduleCard(sectionLabel: 'Shared Schedule'),
                const SizedBox(height: AppSpacing.s12),
                GoalItemsCard(
                  selectedCategories: GoalCategory.values
                      .where((c) => _selectedGoalCategories[c] == true)
                      .toList(),
                  titleCtrls: _goalItemTitleCtrls,
                  targetCtrls: _goalItemTargetCtrls,
                  descCtrls: _goalItemDescCtrls,
                  computedYogaTarget: _computedYogaTarget,
                  readOnly: _isReadOnly,
                ),
                const SizedBox(height: AppSpacing.s12),
              ] else ...[
                SectionCard(
                  children: [
                    const SectionLabel(label: 'Goal Category'),
                    const SizedBox(height: AppSpacing.s10),
                    GoalCategoryChips(
                      selected: _goal.category,
                      readOnly: _isReadOnly,
                      onChanged: (c) => setState(() {
                        _goal = _goal.copyWith(
                          category: c,
                          selectedExerciseIds: c == GoalCategory.yoga
                              ? _goal.selectedExerciseIds
                              : [],
                          selectedExercisePlans: c == GoalCategory.yoga
                              ? _goal.selectedExercisePlans
                              : [],
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s12),
                SectionCard(
                  children: [
                    GoalFormTextField(
                      label: 'Goal Title',
                      controller: _titleCtrl,
                      hint: 'e.g. Daily Walking',
                      readOnly: _isReadOnly,
                    ),
                    const SizedBox(height: AppSpacing.s14),
                    if (!_isYoga) ...[
                      GoalFormTextField(
                        label: 'Target',
                        numbersOnly: true,
                        controller: _targetCtrl,
                        hint: 'e.g. 3000',
                        readOnly: _isReadOnly,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.s14),
                    GoalFormTextField(
                      label: 'Description',
                      controller: _descCtrl,
                      hint: 'Describe the goal and why it is important...',
                      maxLines: 3,
                      readOnly: _isReadOnly,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s12),
                _buildScheduleCard(
                  sectionLabel: 'Frequency',
                  optionalEndDate: true,
                ),
                const SizedBox(height: AppSpacing.s12),
              ],

              if (_isYoga) ...[
                _buildYogaSection(availableExercises: availableExercises),
                const SizedBox(height: AppSpacing.s12),
              ],

              const SizedBox(height: AppSpacing.s12),

              if (!_isReadOnly)
                GoalConsentCheckbox(
                  value: _goal.patientConsent,
                  onChanged: (v) =>
                      setState(() => _goal = _goal.copyWith(patientConsent: v)),
                ),

              const SizedBox(height: AppSpacing.s20),

              GoalBottomActions(
                mode: widget.mode,
                isSubmitting: _isSubmitting,
                onSubmit: () {
                  _onSubmit();
                },
                onCancel: () {
                  if (_isSubmitting) return;
                  Navigator.of(context).pop();
                },
                onEdit: _switchToEdit,
              ),
              const SizedBox(height: AppSpacing.s32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClinicianGoalTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  const _ClinicianGoalTypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 25),
        label: Text(label),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          backgroundColor: selected
              ? AppPalette.secondaryBlue
              : AppPalette.surfaceLight,
          foregroundColor: selected ? AppPalette.white : AppPalette.medGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: AppTypography.titleBig1,
        ),
      ),
    );
  }
}

class _ClinicianChoiceButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const _ClinicianChoiceButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          backgroundColor: selected
              ? AppPalette.secondaryBlue
              : AppPalette.surfaceLight,
          foregroundColor: selected ? AppPalette.white : AppPalette.medGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: AppTypography.titleBig1,
        ),
        child: Text(label),
      ),
    );
  }
}

class _ClinicianDayButton extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  const _ClinicianDayButton({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: selected
              ? AppPalette.secondaryBlue
              : AppPalette.surfaceLight,
          disabledBackgroundColor: AppPalette.surfaceLight,
          foregroundColor: selected ? AppPalette.white : AppPalette.medGray,
          disabledForegroundColor: AppPalette.medGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: AppTypography.titleBig1,
        ),
        child: Text(label),
      ),
    );
  }
}

class _ClinicianDateButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ClinicianDateButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          backgroundColor: AppPalette.surfaceLight,
          foregroundColor: AppPalette.medGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: AppTypography.titleBig1,
        ),
        child: Text(label),
      ),
    );
  }
}

class _ClinicianGoalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final double height;
  final int maxLines;

  const _ClinicianGoalTextField({
    required this.controller,
    required this.hint,
    this.height = 50,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        cursorColor: AppPalette.secondaryBlue,
        style: AppTypography.titleBig1.copyWith(
          color: AppPalette.secondaryBlue,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppPalette.surfaceLight,
          hintText: hint,
          hintStyle: AppTypography.titleBig1.copyWith(
            color: AppPalette.medGray,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: AppPalette.secondaryBlue,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _ClinicianTargetInput extends StatelessWidget {
  final TextEditingController controller;
  final bool readOnly;
  final int? computedValue;

  const _ClinicianTargetInput({
    required this.controller,
    required this.readOnly,
    this.computedValue,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final target = computedValue ?? num.tryParse(value.text) ?? 0;
        final progress = (target.toDouble() / 100).clamp(0.0, 1.0).toDouble();
        return SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 94,
                height: 94,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 9,
                  backgroundColor: AppPalette.surfaceLight,
                  color: AppPalette.secondaryBlue,
                  strokeCap: StrokeCap.round,
                ),
              ),
              SizedBox(
                width: 62,
                child: readOnly
                    ? Text(
                        '$target',
                        textAlign: TextAlign.center,
                        style: AppTypography.display1.copyWith(
                          color: AppPalette.secondaryBlue,
                        ),
                      )
                    : TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        cursorColor: AppPalette.secondaryBlue,
                        style: AppTypography.display1.copyWith(
                          color: AppPalette.secondaryBlue,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: AppTypography.display1.copyWith(
                            color: AppPalette.medGray,
                          ),
                          filled: false,
                          fillColor: AppPalette.transparent,
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
