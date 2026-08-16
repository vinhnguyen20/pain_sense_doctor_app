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
    final diaryState = ref.watch(patientDiaryProvider);
    final now = DateTime.now();
    PatientDiaryEntry? todayEntry;

    for (final e in diaryState.entries) {
      if (e.date.year == now.year && e.date.month == now.month && e.date.day == now.day) {
        todayEntry = e;
        break;
      }
    }

    PatientDiaryActivity? exerciseActivity;
    PatientDiaryActivity? stepsActivity;
    PatientDiaryActivity? postureActivity;

    if (todayEntry != null) {
      for (final a in todayEntry.diary) {
        if (a.label.toLowerCase().contains('exercise')) {
          exerciseActivity = a;
        } else if (a.label.toLowerCase().contains('step')) {
          stepsActivity = a;
        } else if (a.label.toLowerCase().contains('posture')) {
          postureActivity = a;
        }
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
            children: [
              SizedBox(
                width: 250,
                child: _GoalSummaryItem(
                  activity: exerciseActivity,
                  defaultTitle: 'Exercise',
                  defaultDescription: 'No exercise goal assigned.',
                ),
              ),
              const SizedBox(width: 120),
              SizedBox(
                width: 250,
                child: _GoalSummaryItem(
                  activity: stepsActivity,
                  defaultTitle: 'Steps',
                  defaultDescription: 'No step goal assigned.',
                ),
              ),
              const SizedBox(width: 120),
              SizedBox(
                width: 250,
                child: _GoalSummaryItem(
                  activity: postureActivity,
                  defaultTitle: 'Posture',
                  defaultDescription: 'No posture goal recorded.',
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
  final PatientDiaryActivity? activity;
  final String defaultTitle;
  final String defaultDescription;

  const _GoalSummaryItem({
    required this.activity,
    required this.defaultTitle,
    required this.defaultDescription,
  });

  @override
  Widget build(BuildContext context) {
    int percent = 0;
    String title = activity?.label ?? defaultTitle;
    String desc = defaultDescription;

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
                child: CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFF7F7F7),
                  color: const Color(0xFF58E8EA),
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
class TodayExerciseGoalsCard extends ConsumerWidget {
  final Patient patient;

  const TodayExerciseGoalsCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryState = ref.watch(patientDiaryProvider);
    final now = DateTime.now();
    PatientDiaryEntry? todayEntry;

    for (final e in diaryState.entries) {
      if (e.date.year == now.year && e.date.month == now.month && e.date.day == now.day) {
        todayEntry = e;
        break;
      }
    }

    final List<PatientDiaryActivity> exerciseGoals = [];
    if (todayEntry != null) {
      for (final a in todayEntry.diary) {
        if (a.label.toLowerCase().contains('exercise')) {
          exerciseGoals.add(a);
        }
      }
    }

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
          const Text("Today's Exercise Goals", style: DashboardStyles.heading),
          const SizedBox(height: 16),
          Expanded(
            child: exerciseGoals.isEmpty
                ? const Align(alignment: Alignment.topCenter, child: Text('No exercise goals today.', style: DashboardStyles.body))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exerciseGoals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final a = exerciseGoals[index];
                      final isCompleted = a.percent >= 100.0;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              a.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DashboardStyles.body.copyWith(
                                fontWeight: isCompleted ? FontWeight.normal : FontWeight.w700,
                              ),
                            ),
                          ),
                          if (isCompleted)
                            Text(
                              'completed',
                              style: DashboardStyles.body.copyWith(fontSize: 12),
                            ),
                        ],
                      );
                    },
                  ),
          ),
          if (exerciseGoals.length > 4)
            const Center(child: Icon(Icons.keyboard_arrow_down, color: AppPalette.medGray)),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: 136,
              height: 31,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF206EB0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Edit', style: DashboardStyles.button),
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
                      child: CircularProgressIndicator(
                        value: score / 100,
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
