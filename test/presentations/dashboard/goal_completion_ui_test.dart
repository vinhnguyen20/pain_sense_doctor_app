import 'package:app_doctor/features/diary/data/models/goal_item_model.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';
import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_activity.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_entry.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';
import 'package:app_doctor/features/diary/presentation/provider/patient_diary_notifier.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/patient_dashboard_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePatientUserGoalsNotifier extends PatientUserGoalsNotifier {
  final List<UserGoalModel> _goals;
  _FakePatientUserGoalsNotifier(this._goals);

  @override
  Future<List<UserGoalModel>> build(String patientId) async => _goals;
}

void main() {
  const testPatient = Patient(
    id: 'p123',
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com',
  );

  final today = DateTime.now();

  group("Today's Exercise Goals completion UI", () {
    testWidgets(
      'displays success green background and check icon when exercise is completed',
      (tester) async {
        final completedGoal = UserGoalModel(
          id: 'goal-1',
          patientId: testPatient.id,
          doctorId: 'doc-1',
          startDate: today.subtract(const Duration(days: 1)),
          endDate: today.add(const Duration(days: 5)),
          goalItems: [
            GoalItemModel(
              type: GoalType.yogaMeditation,
              label: 'Morning Stretching',
              desc: 'Morning routine',
              minTarget: 1,
              unit: 'exercise',
              userExercises: [
                UserExerciseItem(
                  id: 'ue-1',
                  name: 'Morning Stretching',
                  scheduleConfig: [
                    UserExerciseScheduleConfig(
                      exerciseDate: today,
                      sessionsCount: 1,
                      sessionsCompleted: 1,
                      slots: const [
                        UserExerciseScheduleSlot(
                          period: 'morning',
                          time: '08:00',
                          instruction: '',
                          isCompleted: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
          createdAt: today,
          createdBy: 'doc-1',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              patientUserGoalsProvider(testPatient.id).overrideWith(
                () => _FakePatientUserGoalsNotifier([completedGoal]),
              ),
              patientDiaryProvider(testPatient.id).overrideWithValue(
                PatientDiaryState(
                  entries: [
                    PatientDiaryEntry(
                      id: 'diary-1',
                      date: today,
                      diary: [
                        PatientDiaryActivity(
                          label: 'Morning Stretching',
                          type: GoalType.yogaMeditation,
                          desc: 'Completed',
                          actual: 1,
                          minTarget: 1,
                          percent: 100.0,
                          unit: 'exercise',
                          emoji: '🧘',
                          display: '1 / 1 exercise',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: TodayExerciseGoalsCard(patient: testPatient),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Morning Stretching'), findsOneWidget);
        // Find container with success green background Color(0xFF87C879)
        final containerFinder = find.byWidgetPredicate((w) {
          if (w is Container && w.decoration is BoxDecoration) {
            final box = w.decoration as BoxDecoration;
            return box.color == const Color(0xFF87C879);
          }
          return false;
        });
        expect(containerFinder, findsWidgets);

        // Check icon exists
        expect(find.byIcon(Icons.check), findsOneWidget);
      },
    );

    testWidgets(
      'displays default grey background and no check icon when exercise is NOT completed',
      (tester) async {
        final uncompletedGoal = UserGoalModel(
          id: 'goal-2',
          patientId: testPatient.id,
          doctorId: 'doc-1',
          startDate: today.subtract(const Duration(days: 1)),
          endDate: today.add(const Duration(days: 5)),
          goalItems: [
            GoalItemModel(
              type: GoalType.yogaMeditation,
              label: 'Leg Raise',
              desc: 'Leg exercise',
              minTarget: 1,
              unit: 'exercise',
              userExercises: [
                UserExerciseItem(
                  id: 'ue-2',
                  name: 'Leg Raise',
                  scheduleConfig: [
                    UserExerciseScheduleConfig(
                      exerciseDate: today,
                      sessionsCount: 1,
                      sessionsCompleted: 0,
                      slots: const [
                        UserExerciseScheduleSlot(
                          period: 'morning',
                          time: '08:00',
                          instruction: '',
                          isCompleted: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
          createdAt: today,
          createdBy: 'doc-1',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              patientUserGoalsProvider(testPatient.id).overrideWith(
                () => _FakePatientUserGoalsNotifier([uncompletedGoal]),
              ),
              patientDiaryProvider(testPatient.id).overrideWithValue(
                PatientDiaryState(
                  entries: [
                    PatientDiaryEntry(
                      id: 'diary-2',
                      date: today,
                      diary: [
                        PatientDiaryActivity(
                          label: 'Leg Raise',
                          type: GoalType.yogaMeditation,
                          desc: 'Not yet completed',
                          actual: 0,
                          minTarget: 1,
                          percent: 0.0,
                          unit: 'exercise',
                          emoji: '🧘',
                          display: '0 / 1 exercise',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: TodayExerciseGoalsCard(patient: testPatient),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Leg Raise'), findsOneWidget);
        // Container should have Color(0xFFF7F7F7)
        final uncompletedContainerFinder = find.byWidgetPredicate((w) {
          if (w is Container && w.decoration is BoxDecoration) {
            final box = w.decoration as BoxDecoration;
            return box.color == const Color(0xFFF7F7F7);
          }
          return false;
        });
        expect(uncompletedContainerFinder, findsWidgets);

        // No check icon
        expect(find.byIcon(Icons.check), findsNothing);
      },
    );
  });

  group('Daily Goals (Steps/Posture/Yoga) 100% completion UI', () {
    testWidgets(
      'turns success green (0xFF87C879) when Steps and Posture reach 100%',
      (tester) async {
        final dailyGoals = UserGoalModel(
          id: 'goal-daily',
          patientId: testPatient.id,
          doctorId: 'doc-1',
          startDate: today.subtract(const Duration(days: 1)),
          endDate: today.add(const Duration(days: 5)),
          goalItems: const [
            GoalItemModel(
              type: GoalType.stepsWalking,
              label: 'Steps Walking',
              desc: 'Walk 10000 steps',
              minTarget: 10000,
              unit: 'steps',
            ),
            GoalItemModel(
              type: GoalType.activityWalk,
              label: 'Posture Guidance',
              desc: 'Follow posture',
              minTarget: 100,
              unit: '%',
            ),
          ],
          createdAt: today,
          createdBy: 'doc-1',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              patientUserGoalsProvider(testPatient.id).overrideWith(
                () => _FakePatientUserGoalsNotifier([dailyGoals]),
              ),
              patientDiaryProvider(testPatient.id).overrideWithValue(
                PatientDiaryState(
                  entries: [
                    PatientDiaryEntry(
                      id: 'diary-daily',
                      date: today,
                      diary: const [
                        PatientDiaryActivity(
                          label: 'Daily Steps',
                          type: GoalType.stepsWalking,
                          desc: 'Walking',
                          actual: 10000,
                          minTarget: 10000,
                          percent: 100.0,
                          unit: 'steps',
                          emoji: '🚶',
                          display: '10000 / 10000 steps',
                        ),
                        PatientDiaryActivity(
                          label: 'Posture',
                          type: GoalType.activityWalk,
                          desc: 'Posture tracking',
                          actual: 100,
                          minTarget: 100,
                          percent: 100.0,
                          unit: '%',
                          emoji: '🧍',
                          display: '100 / 100 %',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: DailyGoalsCard(patient: testPatient),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // RoundedCircularProgress widgets for 100% goals should have color 0xFF87C879
        final greenProgressFinder = find.byWidgetPredicate((w) {
          return w is RoundedCircularProgress &&
              w.color == const Color(0xFF87C879) &&
              w.value == 1.0;
        });
        // Both Steps (100%) and Posture (100%) should have green progress
        expect(greenProgressFinder, findsNWidgets(2));
      },
    );

    testWidgets(
      'keeps category colors when Steps and Posture are below 100%',
      (tester) async {
        final dailyGoals = UserGoalModel(
          id: 'goal-daily-2',
          patientId: testPatient.id,
          doctorId: 'doc-1',
          startDate: today.subtract(const Duration(days: 1)),
          endDate: today.add(const Duration(days: 5)),
          goalItems: const [
            GoalItemModel(
              type: GoalType.stepsWalking,
              label: 'Steps Walking',
              desc: 'Walk 10000 steps',
              minTarget: 10000,
              unit: 'steps',
            ),
          ],
          createdAt: today,
          createdBy: 'doc-1',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              patientUserGoalsProvider(testPatient.id).overrideWith(
                () => _FakePatientUserGoalsNotifier([dailyGoals]),
              ),
              patientDiaryProvider(testPatient.id).overrideWithValue(
                PatientDiaryState(
                  entries: [
                    PatientDiaryEntry(
                      id: 'diary-daily-2',
                      date: today,
                      diary: const [
                        PatientDiaryActivity(
                          label: 'Daily Steps',
                          type: GoalType.stepsWalking,
                          desc: 'Walking',
                          actual: 5000,
                          minTarget: 10000,
                          percent: 50.0,
                          unit: 'steps',
                          emoji: '🚶',
                          display: '5000 / 10000 steps',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: DailyGoalsCard(patient: testPatient),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Steps progress below 100% should use secondary blue Color(0xFF206EB0)
        final blueProgressFinder = find.byWidgetPredicate((w) {
          return w is RoundedCircularProgress &&
              w.color == const Color(0xFF206EB0) &&
              w.value == 0.5;
        });
        expect(blueProgressFinder, findsOneWidget);
      },
    );
  });
}
