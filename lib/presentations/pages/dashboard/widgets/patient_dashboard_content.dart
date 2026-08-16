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
              SizedBox(
                width: PatientDashboardDimensions.appointmentWidth,
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
              SizedBox(
                width: PatientDashboardDimensions.bottomCardWidth,
                child: TodayExerciseGoalsCard(patient: patient),
              ),
              SizedBox(
                width: PatientDashboardDimensions.bottomCardWidth,
                child: AdherenceScoreCard(patient: patient),
              ),
              SizedBox(
                width: PatientDashboardDimensions.bottomCardWidth,
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
      ref.read(patientDiaryProvider.notifier).loadForPatient(widget.patient.id);
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
          DateTime.tryParse(a.schedule.date) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final db =
          DateTime.tryParse(b.schedule.date) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return da.compareTo(db);
    });

    for (final a in validAppts) {
      final d = DateTime.tryParse(a.schedule.date);
      if (d == null) continue;

      if (d.isBefore(now) && !DateUtils.isSameDay(d, now)) {
        lastAppointment = a;
      } else if (d.isAfter(now) || DateUtils.isSameDay(d, now)) {
        nextAppointment ??= a;
      }
    }

    final diaryState = ref.watch(patientDiaryProvider);
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
      width: PatientDashboardDimensions.appointmentWidth,
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
                            ? _formatMonthDay(DateTime.tryParse(lastAppointment.schedule.date) ?? DateTime.now()) : '—',
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
                            ? _formatMonthDay(DateTime.tryParse(nextAppointment.schedule.date) ?? DateTime.now()) : '—',
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
                  child: Text('John is on track for his next appointment.',
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

class DailyGoalsCard extends StatelessWidget {
  final Patient patient;

  const DailyGoalsCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
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
            children: [
              SizedBox(
                width: 250,
                child: _GoalSummaryItem(
                  percent: 60,
                  color: const Color(0xFF87C879),
                  title: 'Exercise',
                  desc: 'You have completed\n3 out of 5 exercise goals.',
                ),
              ),
              const SizedBox(width: 120),
              SizedBox(
                width: 250,
                child: _GoalSummaryItem(
                  percent: 64,
                  color: const Color(0xFF206EB0),
                  title: 'Steps',
                  desc: 'You have walked\n6,432 of 10,000 steps.',
                ),
              ),
              const SizedBox(width: 120),
              SizedBox(
                width: 250,
                child: _GoalSummaryItem(
                  percent: 85,
                  color: const Color(0xFF18588C),
                  title: 'Posture',
                  desc: 'How well you are\nfollowing your posture\nguidance.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalSummaryItem extends StatelessWidget {
  final int percent;
  final String title;
  final String desc;
  final Color color;

  const _GoalSummaryItem({
    required this.percent,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
class TodayExerciseGoalsCard extends StatefulWidget {
  final Patient patient;

  const TodayExerciseGoalsCard({super.key, required this.patient});

  @override
  State<TodayExerciseGoalsCard> createState() => _TodayExerciseGoalsCardState();
}

class _TodayExerciseGoalsCardState extends State<TodayExerciseGoalsCard> {
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, dynamic>> mockExercises = [
    {'label': '30 Minute\nStretches', 'completed': true},
    {'label': '10K Steps', 'completed': false},
    {'label': '2 Strength\nExercises', 'completed': false},
    {'label': '2 Yoga Poses', 'completed': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      height: 423,
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
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              itemCount: mockExercises.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final ex = mockExercises[index];
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
                                  Icons.directions_run,
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
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(
            width: 330,
            height: 8,
            child: SizedBox.shrink(),
          ),
          const SizedBox(height: 18),
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
class AdherenceScoreCard extends StatelessWidget {
  final Patient patient;

  const AdherenceScoreCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: RoundedCircularProgress(
                    value: 82 / 100,
                    strokeWidth: 12,
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
                      '82',
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
      width: 370,
      height: 423,
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
