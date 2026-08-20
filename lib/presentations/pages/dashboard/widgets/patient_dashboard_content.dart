import 'package:app_doctor/features/diary/data/models/goal_item_model.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_doctor/common/widgets/activity_tracker.dart';
import 'package:app_doctor/features/chats/domain/entites/appointment.dart';
import 'package:app_doctor/features/chats/presentation/provider/appointment_notifier.dart';
import 'package:app_doctor/features/diary/presentation/provider/patient_diary_notifier.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_entry.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_activity.dart';
import 'package:app_doctor/features/tracking/presentation/provider/tracking_providers.dart';
import 'seven_7_day_trend.dart';
import 'patient_dashboard_dimensions.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';

class DashboardStyles {
  static const heading = TextStyle(fontFamily: 'Cabin', fontWeight: FontWeight.bold, fontSize: 20, height: 1.0, color: Color(0xFF206EB0));
  static const category = TextStyle(fontFamily: 'Cabin', fontWeight: FontWeight.bold, fontSize: 24, height: 1.0, color: Color(0xFF206EB0));
  static const body = TextStyle(fontFamily: 'Cabin', fontWeight: FontWeight.normal, fontSize: 16, height: 1.0, color: Color(0xFF18588C));
  static const button = TextStyle(fontFamily: 'Cabin', fontWeight: FontWeight.bold, fontSize: 16, height: 1.0, color: Colors.white);
  static const dayLabel = TextStyle(fontFamily: 'Cabin', fontWeight: FontWeight.bold, fontSize: 12, height: 1.0, color: Color(0xFF206EB0));
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
              Expanded(
                child: AppointmentTimeline(patient: patient),
              ),
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
              Expanded(
                child: TodayExerciseGoalsCard(patient: patient),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: AdherenceScoreCard(patient: patient),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: SevenDayOverviewContainer(patient: patient),
              ),
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
                context.pushNamed('patient-monitor-detail', extra: patient);
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
  void initState() {
    super.initState();
    Future.microtask(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsState = ref.watch(
      appointmentsByPatientProvider(widget.patient.id),
    );

    Appointment? lastAppointment;
    Appointment? nextAppointment;

    final list = appointmentsState.appointments.toList();
    final now = DateTime.now();

    final validAppts = list
        .where((a) => a.status != AppointmentStatus.cancelled)
        .toList();

    validAppts.sort((a, b) {
      final da =
          _parseRobustDate(a.schedule.date) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final db =
          _parseRobustDate(b.schedule.date) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return da.compareTo(db);
    });

    for (final a in validAppts) {
      final d = _parseRobustDate(a.schedule.date);
      if (d == null) continue;

      if (d.isBefore(now) && !DateUtils.isSameDay(d, now)) {
        lastAppointment = a;
      } else if (d.isAfter(now) || DateUtils.isSameDay(d, now)) {
        nextAppointment ??= a;
      }
    }

    final diaryState = ref.watch(patientDiaryProvider(widget.patient.id));
    final diaryMap = <String, double>{};
    for (final entry in diaryState.entries) {
      final dateKey =
          '${entry.date.year}-${entry.date.month}-${entry.date.day}';

      if (entry.diary.isNotEmpty) {
        double total = 0;
        int valid = 0;
        for (final a in entry.diary) {
          total += a.percent;
          valid++;
        }
        if (valid > 0) {
          diaryMap[dateKey] = total / valid;
        }
      }
    }

    final List<String> labels = [];
    final List<double?> values = [];
    final List<Color> barColors = [];

    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    for (int i = -6; i <= 7; i++) {
      final day = now.add(Duration(days: i));
      labels.add(weekdays[day.weekday - 1]);

      final dateKey = '${day.year}-${day.month}-${day.day}';
      double? val;
      if (i <= 0) {
        val = diaryMap[dateKey];
      }

      if (val != null) {
        final normalized = 20.0 + (val / 100.0) * 35.0;
        values.add(normalized);
      } else {
        values.add(null);
      }

      if (i == 0) {
        barColors.add(const Color(0xFF58E8EA));
      } else if (i < 0) {
        barColors.add(AppPalette.secondaryBlue);
      } else {
        barColors.add(AppPalette.surfaceLight);
      }
    }

    return Container(
      width: double.infinity,
      height: 273,
      padding: const EdgeInsets.all(PatientDashboardDimensions.cardPadding),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ActivityTracker(
              labels: labels,
              values: values,
              barColors: barColors,
              expand: true,
              barWidth: 20,
              maxBarHeight: 55,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lastAppointment != null
                            ? _formatMonthDay(_parseRobustDate(lastAppointment.schedule.date) ?? DateTime.now()) : '—',
                        style: DashboardStyles.category,
                      ),
                      Text(
                        'Last Appt.',
                        style: DashboardStyles.body.copyWith(color: AppPalette.secondaryBlue),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Today',
                      style: DashboardStyles.category,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        nextAppointment != null
                            ? _formatMonthDay(_parseRobustDate(nextAppointment.schedule.date) ?? DateTime.now()) : '—',
                        style: DashboardStyles.category,
                      ),
                      Text(
                        'Next Appt.',
                        style: DashboardStyles.body.copyWith(color: AppPalette.secondaryBlue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    nextAppointment != null
                        ? '${widget.patient.firstName} is on track for their next appointment.'
                        : 'No upcoming appointment is scheduled.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DashboardStyles.category,
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: PatientDashboardDimensions.buttonWidth,
                  height: 31,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      backgroundColor: AppPalette.secondaryBlue,
                      foregroundColor: AppPalette.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          PatientDashboardDimensions.buttonRadius,
                        ),
                      ),
                    ),
                    child: Text(
                      'Schedule',
                      style: DashboardStyles.button,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  DateTime? _parseRobustDate(String dateStr) {
    var d = DateTime.tryParse(dateStr);
    if (d != null) return d;
    
    // Handle dd/MM/yyyy or MM/dd/yyyy
    var parts = dateStr.split('/');
    if (parts.length == 3 && parts[2].length == 4) {
      return DateTime.tryParse('${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}');
    }
    
    // Handle dd-MM-yyyy or MM-dd-yyyy
    parts = dateStr.split('-');
    if (parts.length == 3 && parts[2].length == 4) {
      return DateTime.tryParse('${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}');
    }
    
    return null;
  }

  String _formatMonthDay(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
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
      if (e.date.year == now.year && e.date.month == now.month && e.date.day == now.day) {
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
          borderRadius: BorderRadius.circular(PatientDashboardDimensions.cardRadius),
          border: Border.all(color: AppPalette.medGray),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Default to empty state if no real goals assigned
    List<Widget> children = [];
    if (goalItems.isEmpty) {
      children = [
        const SizedBox(
          width: 250,
          child: _GoalSummaryItem(
            goalItem: null,
            activity: null,
            defaultTitle: '—',
            defaultDescription: 'No goal assigned.',
          ),
        ),
      ];
    } else {
      final visibleItems = goalItems.take(3).toList();
      children = <Widget>[];
      for (var index = 0; index < visibleItems.length; index++) {
        final g = visibleItems[index];
        PatientDiaryActivity? activity;
        if (todayEntry != null) {
          final keyword = g.type.name.toLowerCase();
          final gLabel = g.label.toLowerCase();
          for (final a in todayEntry.diary) {
             final aLabel = a.label.toLowerCase();
             if (aLabel.contains(keyword) || aLabel.contains(gLabel)) {
                activity = a;
                break;
             }
          }
        }
        children.add(
          Padding(
            padding: EdgeInsets.only(
              right: index == visibleItems.length - 1 ? 0 : 120,
            ),
            child: SizedBox(
              width: 250,
              child: _GoalSummaryItem(
                goalItem: g,
                activity: activity,
                defaultTitle: g.label,
                defaultDescription: g.desc,
              ),
            ),
          ),
        );
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PatientDashboardDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(PatientDashboardDimensions.cardRadius),
        border: Border.all(color: AppPalette.medGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined, size: 24, color: Color(0xFF206EB0)),
              const SizedBox(width: 10),
              const Text('Daily Goals', style: DashboardStyles.heading),
            ],
          ),
          const SizedBox(height: 10),
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
    String title = activity?.label ?? defaultTitle;
    String desc = defaultDescription;
    Color color = const Color(0xFF58E8EA);

    if (title.toLowerCase().contains('exercise')) color = const Color(0xFF87C879);
    if (title.toLowerCase().contains('step')) color = const Color(0xFF206EB0);
    if (title.toLowerCase().contains('posture')) color = const Color(0xFF18588C);

    if (activity != null) {
      percent = activity!.percent.toInt();

      if (title.toLowerCase().contains('exercise')) {
        desc = 'You have completed\n${activity!.actual.toInt()} out of ${activity!.minTarget.toInt()} exercise goals.';
      } else if (title.toLowerCase().contains('step')) {
        desc = 'You have walked\n${activity!.actual.toInt()} of ${activity!.minTarget.toInt()} steps.';
      } else if (title.toLowerCase().contains('posture')) {
        desc = 'How well you are\nfollowing your posture\nguidance.';
      } else {
        desc = activity!.desc;
      }
    }

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
                  value: percent / 100,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFF7F7F7),
                  color: color,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$percent', style: const TextStyle(fontFamily: 'Cabin', fontWeight: FontWeight.bold, fontSize: 24, height: 1.0, color: Color(0xFF206EB0))),
                  const Text('%', style: TextStyle(fontFamily: 'Cabin', fontWeight: FontWeight.bold, fontSize: 12, height: 1.0, color: Color(0xFF206EB0))),
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
  ConsumerState<TodayExerciseGoalsCard> createState() => _TodayExerciseGoalsCardState();
}

class _TodayExerciseGoalsCardState extends ConsumerState<TodayExerciseGoalsCard> {
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(patientUserGoalsProvider(widget.patient.id));
    final diaryState = ref.watch(patientDiaryProvider(widget.patient.id));

    final now = DateTime.now();

    // 1. Get today's diary to check completion
    PatientDiaryEntry? todayEntry;
    for (final e in diaryState.entries) {
      if (_isSameDay(e.date, now)) {
        todayEntry = e;
        break;
      }
    }

    // 2. Extract today's exercise goals from UserGoals
    final List<Map<String, dynamic>> todayExercises = [];

    final goalsList = goalsAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <UserGoalModel>[],
    );

    for (final goal in goalsList) {
      if (now.isBefore(goal.startDate) || now.isAfter(goal.endDate.add(const Duration(days: 1)))) {
        continue;
      }

      for (final item in goal.goalItems) {
        // Find exercises
        if (item.userExercises != null && item.userExercises!.isNotEmpty) {
          for (final ue in item.userExercises!) {
            bool hasToday = false;
            for (final sc in ue.scheduleConfig) {
              if (_isSameDay(sc.exerciseDate, now)) {
                hasToday = true;
                break;
              }
            }
            if (hasToday) {
              final label = ue.name ?? item.label;
              final matchingActivity = todayEntry?.diary.where((a) => a.label.toLowerCase() == label.toLowerCase() || (a.userExercises?.any((ex) => ex.exerciseId == ue.resolvedExerciseId) ?? false)).firstOrNull;
              final isCompleted = matchingActivity != null && matchingActivity.percent >= 100.0;
              todayExercises.add({
                'label': label,
                'completed': isCompleted,
              });
            }
          }
        } else if (item.type.toApiString() == 'exercise' || item.label.toLowerCase().contains('exercise')) {
          // fallback if no userExercises but it's an exercise goal
          final matchingActivity = todayEntry?.diary.where((a) => a.label.toLowerCase() == item.label.toLowerCase()).firstOrNull;
          final isCompleted = matchingActivity != null && matchingActivity.percent >= 100.0;
          todayExercises.add({
            'label': item.label,
            'completed': isCompleted,
          });
        }
      }
    }
    
    // Add dummy scroll listener callback to check scroll size after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScroll();
    });

    Widget contentWidget;
    if (goalsAsync.isLoading) {
      contentWidget = const Center(child: CircularProgressIndicator());
    } else if (goalsAsync.hasError) {
      contentWidget = const Text(
        'Unable to load exercise goals.',
        style: TextStyle(fontFamily: 'Cabin', fontSize: 16, color: Color(0xFF18588C)),
      );
    } else if (todayExercises.isEmpty) {
      contentWidget = const Text(
        'No exercise goals today.',
        style: TextStyle(fontFamily: 'Cabin', fontSize: 16, color: Color(0xFF18588C)),
      );
    } else {
      contentWidget = ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        itemCount: todayExercises.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final ex = todayExercises[index];
          final bool isCompleted = ex['completed'];
          final String label = ex['label'];

          return Container(
            width: 330,
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFF87C879) : const Color(0xFFF7F7F7),
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
                            color: isCompleted ? const Color(0xFFFFFFFF) : const Color(0xFF206EB0),
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
                            color: isCompleted ? const Color(0xFFFFFFFF) : const Color(0xFF206EB0),
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
                    color: isCompleted ? const Color(0xFFFFFFFF) : const Color(0xFF18588C),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: isCompleted
                      ? const Center(
                          child: Icon(Icons.check, size: 16, color: Color(0xFF87C879)),
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
            width: 330,
            height: 24,
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(Icons.fitness_center, size: 24, color: Color(0xFF206EB0)),
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
          SizedBox(
            width: 330,
            height: 260,
            child: contentWidget,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 330,
            height: 8,
            child: _canScroll
                ? const Center(child: Icon(Icons.keyboard_arrow_down, size: 15, color: Color(0xFF206EB0)))
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 136,
              height: 31,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF206EB0),
                  foregroundColor: const Color(0xFFFFFFFF),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minimumSize: const Size(136, 31),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontFamily: 'Cabin',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
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
    final adherenceAsync = ref.watch(diaryAdherenceProvider(patient.id));

    return Container(
      padding: const EdgeInsets.all(PatientDashboardDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(PatientDashboardDimensions.cardRadius),
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
        borderRadius: BorderRadius.circular(PatientDashboardDimensions.cardRadius),
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
