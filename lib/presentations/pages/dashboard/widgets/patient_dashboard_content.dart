import 'package:app_doctor/common/widgets/activity_tracker.dart';
import 'package:app_doctor/common/widgets/section.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/diary/data/models/diary_adherence_model.dart';
import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';
import 'package:app_doctor/features/tracking/presentation/provider/tracking_providers.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/seven_7_day_trend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';

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
          style: AppTypography.titleBig1.copyWith(
            color: AppPalette.secondaryBlue,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          height: 273,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 380,
                child: PatientOverviewCard(patient: patient),
              ),
              const SizedBox(width: 30),
              SizedBox(
                width: 589,
                child: AppointmentTimeline(patient: patient),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        DailyGoalsCard(patient: patient),
        const SizedBox(height: 30),
        SizedBox(
          height: 420,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: TodayExerciseGoalsCard(patient: patient)),
              const SizedBox(width: 30),
              Expanded(child: AdherenceScoreCard(patient: patient)),
              const SizedBox(width: 30),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(20),
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
                const SizedBox(height: 8),
                Text(
                  patient.fullName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleBig1.copyWith(
                    color: AppPalette.secondaryBlue,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 136,
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
                  borderRadius: BorderRadius.circular(30),
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

class AppointmentTimeline extends StatelessWidget {
  final Patient patient;

  const AppointmentTimeline({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    const activityValues = <double?>[
      36.0,
      44.0,
      28.0,
      44.0,
      36.0,
      28.0,
      44.0, // Today
      null,
      null,
      null,
      null,
      null,
      null,
    ];

    const barColors = [
      AppPalette.secondaryBlue,
      AppPalette.secondaryBlue,
      AppPalette.secondaryBlue,
      AppPalette.secondaryBlue,
      AppPalette.secondaryBlue,
      AppPalette.secondaryBlue,
      Colors.cyan, // Today
      AppPalette.medGray,
      AppPalette.medGray,
      AppPalette.medGray,
      AppPalette.medGray,
      AppPalette.medGray,
      AppPalette.medGray,
    ];

    return SizedBox(
      width: 589,
      height: 273,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ActivityTracker(
                labels: const [
                  'S',
                  'M',
                  'T',
                  'W',
                  'T',
                  'F',
                  'S',
                  'S',
                  'M',
                  'T',
                  'W',
                  'T',
                  'F',
                ],
                values: activityValues,
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
                          'July 2',
                          style: AppTypography.titleBig1.copyWith(
                            color: AppPalette.secondaryBlue,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          'Last Appt.',
                          style: AppTypography.defaultBody2.copyWith(
                            color: AppPalette.secondaryBlue,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Today',
                        style: AppTypography.titleBig1.copyWith(
                          color: AppPalette.secondaryBlue,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'July 14',
                          style: AppTypography.titleBig1.copyWith(
                            color: AppPalette.secondaryBlue,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          'Next Appt.',
                          style: AppTypography.defaultBody2.copyWith(
                            color: AppPalette.secondaryBlue,
                            height: 1.0,
                          ),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      '${patient.firstName} is on track for his next appointment.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleBig1.copyWith(
                        color: AppPalette.secondaryBlue,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 136,
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
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Schedule',
                        style: AppTypography.defaultBody2.copyWith(
                          color: AppPalette.white,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DailyGoalsCard extends ConsumerWidget {
  final Patient patient;

  const DailyGoalsCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adherenceAsync = ref.watch(diaryAdherenceProvider(patient.id));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.medGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, size: 20, color: AppPalette.secondaryBlue),
              const SizedBox(width: 8),
              Text(
                'Daily Goals',
                style: AppTypography.titleBig2.copyWith(
                  color: AppPalette.secondaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          adherenceAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error loading goals: $err'),
            data: (adherence) {
              if (adherence == null) {
                return const Text('No goals available.');
              }

              final exercises = adherence.byType[GoalType.activityWalk.name];
              final steps = adherence.byType[GoalType.stepsWalking.name];
              final posture = adherence.byType[GoalType.yogaMeditation.name];

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _GoalSummaryItem(
                      percentage: '${(exercises?.avgPercent ?? 0).toInt()}%',
                      title: 'Exercise',
                      description:
                          'You have completed\n4 out of 4 exercise goals.',
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _GoalSummaryItem(
                      percentage: '${(steps?.avgPercent ?? 0).toInt()}%',
                      title: 'Steps',
                      description: 'You have walked\n7500 of 10,000 steps.',
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _GoalSummaryItem(
                      percentage: '${(posture?.avgPercent ?? 0).toInt()}',
                      title: 'Posture',
                      description:
                          'How well you are\nfollowing your posture\nguidance.',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GoalSummaryItem extends StatelessWidget {
  final String percentage;
  final String title;
  final String description;

  const _GoalSummaryItem({
    required this.percentage,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          percentage,
          style: AppTypography.titleBig1.copyWith(
            color: AppPalette.secondaryBlue,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppTypography.titleBig2.copyWith(
            color: AppPalette.secondaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: AppTypography.defaultBody2.copyWith(color: AppPalette.medGray),
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
    final goalsAsync = ref.watch(patientUserGoalsProvider(patient.id));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.medGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Exercise Goals",
            style: AppTypography.titleBig2.copyWith(
              color: AppPalette.secondaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: goalsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Error loading goals'),
              data: (goals) {
                if (goals.isEmpty) {
                  return const Text('No exercise goals today.');
                }

                // Try to extract goal items to show
                final items = <String>[];
                for (final g in goals) {
                  for (final gi in g.goalItems) {
                    if (gi.label.isNotEmpty) {
                      items.add(gi.label);
                    } else {
                      items.add(gi.type.displayName);
                    }
                  }
                }

                if (items.isEmpty) {
                  // Mock placeholders if no items found in models
                  items.addAll([
                    '30 Minute Stretches',
                    '10K Steps',
                    '2 Strength Exercises',
                    '2 Yoga Poses',
                  ]);
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length > 4 ? 4 : items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final isCompleted =
                        index == 0 || index == 3; // mock completion status
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            items[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.defaultBody2.copyWith(
                              color: AppPalette.secondaryBlue,
                              fontWeight: isCompleted
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isCompleted)
                          Text(
                            'completed',
                            style: AppTypography.captionBody1.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Icon(Icons.keyboard_arrow_down, color: AppPalette.medGray),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.white,
                foregroundColor: AppPalette.secondaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppPalette.medGray),
                ),
              ),
              child: const Text('Edit'),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.medGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adherence Score',
            style: AppTypography.titleBig2.copyWith(
              color: AppPalette.secondaryBlue,
            ),
          ),
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
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 12,
                        backgroundColor: AppPalette.surfaceLight,
                        color: AppPalette.secondaryBlue,
                      ),
                    ),
                    Text(
                      '${score.toInt()}',
                      style: AppTypography.titleBig1.copyWith(
                        color: AppPalette.secondaryBlue,
                        fontSize: 48,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Spacer(),
          Text(
            'Your patient is adhering to most of their prescribed activities.',
            textAlign: TextAlign.center,
            style: AppTypography.defaultBody2.copyWith(
              color: AppPalette.medGray,
            ),
          ),
        ],
      ),
    );
  }
}

class SevenDayOverviewContainer extends ConsumerWidget {
  final Patient patient;

  const SevenDayOverviewContainer({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(
      patientTrackingSummary7DaysProvider(patient.id),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.medGray),
      ),
      child: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SingleChildScrollView(
              child: SevenDayTrendCard(items: items),
            ),
          );
        },
      ),
    );
  }
}
