import 'package:app_doctor/core/utils/date_utils_helper.dart';
import 'package:app_doctor/features/diary/data/models/goal_item_model.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_doctor/features/diary/presentation/provider/patient_diary_notifier.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_entry.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_activity.dart';
import 'seven_7_day_trend.dart';
import 'patient_dashboard_dimensions.dart';
import 'patient_detail_dialog.dart';
import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:app_doctor/features/tracking/presentation/provider/tracking_providers.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';
import 'package:app_doctor/features/education/presentation/provider/education_provider.dart';
import 'journey_overview.dart';

class DashboardStyles {
  static const heading = TextStyle(
    fontFamily: 'Cabin',
    fontWeight: FontWeight.bold,
    fontSize: 20,
    height: 1.0,
    color: Color(0xFF206EB0),
  );
  static const category = TextStyle(
    fontFamily: 'Cabin',
    fontWeight: FontWeight.bold,
    fontSize: 24,
    height: 1.0,
    color: Color(0xFF206EB0),
  );
  static const body = TextStyle(
    fontFamily: 'Cabin',
    fontWeight: FontWeight.normal,
    fontSize: 16,
    height: 1.0,
    color: Color(0xFF18588C),
  );
  static const button = TextStyle(
    fontFamily: 'Cabin',
    fontWeight: FontWeight.bold,
    fontSize: 16,
    height: 1.0,
    color: Colors.white,
  );
  static const dayLabel = TextStyle(
    fontFamily: 'Cabin',
    fontWeight: FontWeight.bold,
    fontSize: 12,
    height: 1.0,
    color: Color(0xFF206EB0),
  );
}

class RoundedCircularProgress extends StatelessWidget {
  final double value;
  final double strokeWidth;
  final Color backgroundColor;
  final Color color;

  const RoundedCircularProgress({
    super.key,
    required this.value,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RoundedCircularProgressPainter(
        value: value,
        strokeWidth: strokeWidth,
        trackColor: backgroundColor,
        progressColor: color,
      ),
    );
  }
}

class _RoundedCircularProgressPainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  _RoundedCircularProgressPainter({
    required this.value,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    if (value <= 0) return;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (value >= 1.0) {
      canvas.drawCircle(center, radius, progressPaint);
      return;
    }

    const startAngle = -3.1415926535897932 / 2;
    final sweepAngle = 2 * 3.1415926535897932 * value;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RoundedCircularProgressPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

class PatientDashboardContent extends ConsumerWidget {
  final Patient patient;

  const PatientDashboardContent({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (context.isCompactShell) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: PatientDashboardBody(patient: patient),
          );
        }

        const minContentWidth = 1208.0;

        final contentWidth = constraints.maxWidth < minContentWidth
            ? minContentWidth
            : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: contentWidth,
            height: constraints.maxHeight,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: PatientDashboardBody(patient: patient),
            ),
          ),
        );
      },
    );
  }
}

class PatientDashboardBody extends ConsumerWidget {
  final Patient patient;

  const PatientDashboardBody({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.isCompactShell) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This is ${patient.firstName}\'s patient overview.',
            style: DashboardStyles.category,
          ),
          const SizedBox(height: AppSpacing.s20),
          PatientOverviewCard(patient: patient),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(height: 273, child: AppointmentTimeline(patient: patient)),
          const SizedBox(height: AppSpacing.s16),
          DailyGoalsCard(patient: patient),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            height: PatientDashboardDimensions.bottomCardHeight,
            child: TodayExerciseGoalsCard(patient: patient),
          ),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(height: 380, child: AdherenceScoreCard(patient: patient)),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            height: PatientDashboardDimensions.bottomCardHeight,
            child: SevenDayOverviewContainer(patient: patient),
          ),
          const SizedBox(height: AppSpacing.s20),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This is ${patient.firstName}\'s patient overview.',
          style: DashboardStyles.category,
        ),
        const SizedBox(height: PatientDashboardDimensions.sectionGap),
        SizedBox(
          height: 273,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: PatientDashboardDimensions.patientCardWidth,
                child: PatientOverviewCard(patient: patient),
              ),
              const SizedBox(width: PatientDashboardDimensions.firstRowGap),
              Expanded(child: AppointmentTimeline(patient: patient)),
            ],
          ),
        ),
        const SizedBox(height: PatientDashboardDimensions.sectionGap),
        DailyGoalsCard(patient: patient),
        const SizedBox(height: PatientDashboardDimensions.sectionGap),
        SizedBox(
          height: PatientDashboardDimensions.bottomCardHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: TodayExerciseGoalsCard(patient: patient)),
              const SizedBox(width: 20),
              Expanded(child: AdherenceScoreCard(patient: patient)),
              const SizedBox(width: 20),
              Expanded(child: SevenDayOverviewContainer(patient: patient)),
            ],
          ),
        ),
      ],
    );
  }
}

class PatientOverviewCard extends StatelessWidget {
  final Patient patient;

  const PatientOverviewCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PatientDashboardDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(
          PatientDashboardDimensions.cardRadius,
        ),
        border: Border.all(color: AppPalette.medGray, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 152,
            child: Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/avatar/avatar.png',
                    width: 152,
                    height: 152,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  patient.fullName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DashboardStyles.category,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: PatientDashboardDimensions.buttonWidth,
            height: 31,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => PatientDetailDialog(
                    patientId: patient.id,
                    initialPatient: patient,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.secondaryBlue,
                foregroundColor: AppPalette.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    PatientDashboardDimensions.buttonRadius,
                  ),
                ),
                textStyle: AppTypography.buttonLarge.copyWith(
                  fontSize: 16,
                  height: 1.0,
                ),
              ),
              child: const Text('Details'),
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentTimeline extends ConsumerStatefulWidget {
  final Patient patient;

  const AppointmentTimeline({super.key, required this.patient});

  @override
  ConsumerState<AppointmentTimeline> createState() =>
      _AppointmentTimelineState();
}

class _AppointmentTimelineState extends ConsumerState<AppointmentTimeline> {
  @override
  Widget build(BuildContext context) {
    final sevenDays = dashboardLastSevenDays();
    final lastSevenDays = DateTimeRange(
      start: sevenDays.first,
      end: sevenDays.last,
    );
    final progressAsync = ref.watch(
      patientDiaryProgressProvider((
        patientId: widget.patient.id,
        fromDate: DateUtilsHelper.formatDateApi(lastSevenDays.start),
        toDate: DateUtilsHelper.formatDateApi(lastSevenDays.end),
      )),
    );
    final journeyProgress = progressAsync.value ?? 0;

    return Container(
      width: double.infinity,
      height: 273,
      padding: const EdgeInsets.all(PatientDashboardDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Journey', style: DashboardStyles.heading),
          const SizedBox(height: 5),
          Text(
            'Last 7 days · ${_formatJourneyDateRange(lastSevenDays)}',
            style: DashboardStyles.body.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 24),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => showPatientJourneyOverview(context, widget.patient),
              borderRadius: BorderRadius.circular(12),
              mouseCursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'You are making great progress',
                            style: DashboardStyles.heading,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${journeyProgress.round()}%',
                          style: DashboardStyles.category.copyWith(
                            fontSize: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: journeyProgress / 100,
                        minHeight: 12,
                        color: AppPalette.secondaryBlue,
                        backgroundColor: AppPalette.surfaceLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatJourneyDate(DateTime date) =>
      '${date.year}/${date.month.toString().padLeft(2, '0')}/'
      '${date.day.toString().padLeft(2, '0')}';

  String _formatJourneyDateRange(DateTimeRange range) =>
      '${_formatJourneyDate(range.start)} – '
      '${_formatJourneyDate(range.end)}';
}

class DailyGoalsCard extends ConsumerWidget {
  final Patient patient;

  const DailyGoalsCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryState = ref.watch(patientDiaryProvider(patient.id));
    final goalsAsync = ref.watch(patientUserGoalsProvider(patient.id));

    final now = DateTime.now();
    PatientDiaryEntry? todayEntry;

    for (final e in diaryState.entries) {
      if (e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day) {
        todayEntry = e;
        break;
      }
    }

    final goals = goalsAsync.value ?? [];
    final activeGoal = goals.isNotEmpty ? goals.first : null;
    final goalItems = activeGoal?.goalItems ?? [];

    if (goalsAsync.isLoading && goals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(PatientDashboardDimensions.cardPadding),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(
            PatientDashboardDimensions.cardRadius,
          ),
          border: Border.all(color: AppPalette.medGray),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Daily Goals always has the same three slots. The API may omit a goal or
    // today's activity, but the slot remains visible with a 0% progress ring.
    const dailyGoalTypes = [
      GoalType.yogaMeditation,
      GoalType.stepsWalking,
      GoalType.activityWalk,
    ];

    final children = <Widget>[];
    for (var index = 0; index < dailyGoalTypes.length; index++) {
      final type = dailyGoalTypes[index];
      final activity = todayEntry?.diary
          .where((item) => item.type == type)
          .firstOrNull;
      final goalItem = goalItems.where((item) => item.type == type).firstOrNull;
      final description = goalItem?.desc.trim().isNotEmpty == true
          ? goalItem!.desc
          : 'No goal assigned.';

      children.add(
        Padding(
          padding: EdgeInsets.only(
            right: context.isCompactShell || index == dailyGoalTypes.length - 1
                ? 0
                : 120,
            bottom: context.isCompactShell && index != dailyGoalTypes.length - 1
                ? AppSpacing.s16
                : 0,
          ),
          child: SizedBox(
            width: context.isCompactShell ? double.infinity : 250,
            child: _GoalSummaryItem(
              goalItem: goalItem,
              activity: activity,
              // Keep the three Daily Goals labels stable even when a goal
              // uses a custom label in the API response.
              defaultTitle: type.toApiString(),
              defaultDescription: description,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PatientDashboardDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(
          PatientDashboardDimensions.cardRadius,
        ),
        border: Border.all(color: AppPalette.medGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flag_outlined,
                size: 24,
                color: Color(0xFF206EB0),
              ),
              const SizedBox(width: 10),
              const Text('Daily Goals', style: DashboardStyles.heading),
            ],
          ),
          const SizedBox(height: 10),
          if (context.isCompactShell)
            Column(children: children)
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
        ],
      ),
    );
  }
}

class _GoalSummaryItem extends StatelessWidget {
  final GoalItemModel? goalItem;
  final PatientDiaryActivity? activity;
  final String defaultTitle;
  final String defaultDescription;

  const _GoalSummaryItem({
    this.goalItem,
    required this.activity,
    required this.defaultTitle,
    required this.defaultDescription,
  });

  @override
  Widget build(BuildContext context) {
    int percent = 0;
    final title = defaultTitle;
    String desc = defaultDescription;
    Color color = const Color(0xFF58E8EA);

    if (title.toLowerCase().contains('exercise') ||
        title.toLowerCase().contains('yoga') ||
        activity?.type == GoalType.yogaMeditation) {
      color = const Color(0xFF58E8EA);
    }
    if (title.toLowerCase().contains('step') ||
        title.toLowerCase().contains('walk') ||
        activity?.type == GoalType.stepsWalking) {
      color = const Color(0xFF206EB0);
    }
    if (title.toLowerCase().contains('posture') ||
        title.toLowerCase().contains('pain') ||
        title.toLowerCase().contains('limit') ||
        activity?.type == GoalType.activityWalk) {
      color = const Color(0xFF18588C);
    }

    if (activity != null) {
      percent = activity!.percent.toInt();

      if (title.toLowerCase().contains('exercise') ||
          title.toLowerCase().contains('yoga') ||
          activity!.type == GoalType.yogaMeditation) {
        desc =
            'You have completed\n${activity!.actual.toInt()} out of ${activity!.minTarget.toInt()} exercise goals.';
      } else if (title.toLowerCase().contains('step') ||
          title.toLowerCase().contains('walk') ||
          activity!.type == GoalType.stepsWalking) {
        desc =
            'You have walked\n${activity!.actual.toInt()} of ${activity!.minTarget.toInt()} steps.';
      } else if (title.toLowerCase().contains('posture') ||
          title.toLowerCase().contains('pain') ||
          title.toLowerCase().contains('limit') ||
          activity!.type == GoalType.activityWalk) {
        desc = 'How well you are\nfollowing your posture\nguidance.';
      } else {
        desc = activity!.desc.isNotEmpty ? activity!.desc : defaultDescription;
      }
    }

    final bool isCompleted = percent >= 100;
    final Color progressColor = isCompleted ? const Color(0xFF87C879) : color;
    final Color percentTextColor = isCompleted
        ? const Color(0xFF87C879)
        : const Color(0xFF206EB0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 78,
          height: 78,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: RoundedCircularProgress(
                  value: (percent / 100).clamp(0.0, 1.0),
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFF7F7F7),
                  color: progressColor,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$percent',
                    style: TextStyle(
                      fontFamily: 'Cabin',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      height: 1.0,
                      color: percentTextColor,
                    ),
                  ),
                  Text(
                    '%',
                    style: TextStyle(
                      fontFamily: 'Cabin',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      height: 1.0,
                      color: percentTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: DashboardStyles.category),
              const SizedBox(height: 10),
              Text(desc, style: DashboardStyles.body),
            ],
          ),
        ),
      ],
    );
  }
}

class TodayExerciseGoalsCard extends ConsumerStatefulWidget {
  final Patient patient;

  const TodayExerciseGoalsCard({super.key, required this.patient});

  @override
  ConsumerState<TodayExerciseGoalsCard> createState() =>
      _TodayExerciseGoalsCardState();
}

class _TodayExerciseGoalsCardState
    extends ConsumerState<TodayExerciseGoalsCard> {
  final ScrollController _scrollController = ScrollController();
  bool _canScroll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScroll();
    });
  }

  void _checkScroll() {
    if (_scrollController.hasClients) {
      final canScroll = _scrollController.position.maxScrollExtent > 0;
      if (_canScroll != canScroll) {
        setState(() {
          _canScroll = canScroll;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final exercisesAsync = ref.watch(
      patientExercisesByPatientDateProvider((
        patientId: widget.patient.id,
        date: today,
      )),
    );
    final todayExercises =
        exercisesAsync.value ?? const <TodayExerciseGoalItem>[];

    // Add dummy scroll listener callback to check scroll size after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScroll();
    });

    Widget contentWidget;
    if (exercisesAsync.isLoading) {
      contentWidget = const Center(child: CircularProgressIndicator());
    } else if (exercisesAsync.hasError) {
      contentWidget = const Text(
        'Unable to load exercise goals.',
        style: TextStyle(
          fontFamily: 'Cabin',
          fontSize: 16,
          color: Color(0xFF18588C),
        ),
      );
    } else if (todayExercises.isEmpty) {
      contentWidget = const Text(
        'No exercise goals today.',
        style: TextStyle(
          fontFamily: 'Cabin',
          fontSize: 16,
          color: Color(0xFF18588C),
        ),
      );
    } else {
      contentWidget = ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        itemCount: todayExercises.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final ex = todayExercises[index];
          final isCompleted = ex.isCompleted;
          final label = ex.label;

          return Container(
            width: context.isCompactShell ? double.infinity : 330,
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF87C879)
                  : const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Center(
                          child: Icon(
                            Icons.directions_run, // Fallback icon
                            color: isCompleted
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF206EB0),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Cabin',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            height: 1.1875,
                            color: isCompleted
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF206EB0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF18588C),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: isCompleted
                      ? const Center(
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: Color(0xFF87C879),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          );
        },
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC8C8C8), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.isCompactShell ? double.infinity : 330,
            height: 24,
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(
                    Icons.fitness_center,
                    size: 24,
                    color: Color(0xFF206EB0),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Today's Exercise Goals",
                  style: TextStyle(
                    fontFamily: 'Cabin',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF206EB0),
                    letterSpacing: 0,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SizedBox(
              width: context.isCompactShell ? double.infinity : 330,
              child: contentWidget,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: context.isCompactShell ? double.infinity : 330,
            height: 12,
            child: _canScroll
                ? const Center(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 15,
                      color: Color(0xFF206EB0),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class AdherenceScoreCard extends ConsumerWidget {
  final Patient patient;

  const AdherenceScoreCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adherenceAsync = ref.watch(
      patientTrackingAdherence7DaysProvider(patient.id),
    );

    return Container(
      padding: const EdgeInsets.all(PatientDashboardDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(
          PatientDashboardDimensions.cardRadius,
        ),
        border: Border.all(color: AppPalette.medGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Adherence Score', style: DashboardStyles.heading),
          const Spacer(),
          Center(
            child: adherenceAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error'),
              data: (adherence) {
                final score = adherence?.overall ?? 0;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: RoundedCircularProgress(
                        value: score / 100,
                        strokeWidth: 20,
                        backgroundColor: const Color(0xFFF7F7F7),
                        color: const Color(0xFF206EB0),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      height: 100,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          '${score.toInt()}',
                          style: const TextStyle(
                            fontFamily: 'Cabin',
                            fontWeight: FontWeight.bold,
                            fontSize: 96,
                            height: 1.0,
                            color: Color(0xFF206EB0),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Spacer(),
          const Text(
            'This number represents how well your patient is\nsticking to their assigned goals and exercises.',
            textAlign: TextAlign.left,
            style: DashboardStyles.body,
          ),
        ],
      ),
    );
  }
}

class SevenDayOverviewContainer extends StatelessWidget {
  final Patient patient;

  const SevenDayOverviewContainer({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(PatientDashboardDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(
          PatientDashboardDimensions.cardRadius,
        ),
        border: Border.all(color: AppPalette.medGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('7-Day Overview', style: DashboardStyles.heading),
          const SizedBox(height: 20),
          Expanded(child: SevenDayTrendCard(patientId: patient.id)),
        ],
      ),
    );
  }
}
