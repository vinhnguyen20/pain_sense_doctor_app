import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:app_doctor/features/diary/domain/entites/user_goal_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes every field required by create goal API', () {
    final request = CreateUserGoalWithExercisesRequest(
      userId: 'patient-1',
      startDate: DateTime(2026, 8, 24),
      endDate: DateTime(2026, 8, 31),
      exercises: [
        UserGoalExerciseAssignment(
          exerciseId: 'exercise-1',
          assignedDate: DateTime(2026, 8, 23),
          startDate: DateTime(2026, 8, 24),
          endDate: DateTime(2026, 8, 31),
          doctorInstruction: 'Warm up first',
          scheduleConfig: [
            UserGoalScheduleConfig(
              exerciseDate: DateTime(2026, 8, 25),
              sessionsCount: 1,
              slots: const [
                UserGoalScheduleSlot(
                  period: 'morning',
                  time: '07:00',
                  instruction: 'Stop when pain increases',
                ),
              ],
            ),
          ],
        ),
      ],
      goalItems: const [
        UserGoalItem(
          type: GoalType.yogaMeditation,
          minTarget: 1,
          unit: 'exercises',
          label: 'Morning mobility',
          desc: 'Improve mobility safely',
          userExerciseIds: ['exercise-1'],
        ),
        UserGoalItem(
          type: GoalType.stepsWalking,
          minTarget: 5000,
          unit: 'steps',
          label: 'Daily steps',
          desc: 'Build daily activity',
        ),
      ],
    );

    expect(request.toJson(), {
      'user_id': 'patient-1',
      'start_date': '2026-08-24',
      'end_date': '2026-08-31',
      'exercises': [
        {
          'exercise_id': 'exercise-1',
          'assigned_date': '2026-08-23',
          'start_date': '2026-08-24',
          'end_date': '2026-08-31',
          'schedule_config': [
            {
              'exercise_date': '2026-08-25',
              'sessions_count': 1,
              'slots': [
                {
                  'period': 'morning',
                  'time': '07:00',
                  'instruction': 'Stop when pain increases',
                },
              ],
            },
          ],
          'doctor_instruction': 'Warm up first',
        },
      ],
      'goal_items': [
        {
          'type': GoalType.yogaMeditation.toApiString(),
          'min_target': 1,
          'unit': 'exercises',
          'label': 'Morning mobility',
          'desc': 'Improve mobility safely',
          'user_exercise_ids': ['exercise-1'],
        },
        {
          'type': GoalType.stepsWalking.toApiString(),
          'min_target': 5000,
          'unit': 'steps',
          'label': 'Daily steps',
          'desc': 'Build daily activity',
          'user_exercise_ids': <String>[],
        },
      ],
    });
  });
}
