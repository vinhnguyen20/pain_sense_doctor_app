import 'package:app_doctor/features/diary/data/models/goal_item_model.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';
import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:app_doctor/features/diary/domain/entites/user_goal_request.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('merges a successful edit into the goal shown outside the form', () {
    final current = UserGoalModel(
      id: 'goal-1',
      patientId: 'patient-1',
      doctorId: 'doctor-1',
      startDate: DateTime(2026, 9, 5),
      endDate: DateTime(2026, 9, 30),
      goalItems: const [
        GoalItemModel(
          type: GoalType.stepsWalking,
          minTarget: 100,
          unit: 'steps',
          label: 'Daily Steps',
          desc: 'Old value',
        ),
        GoalItemModel(
          type: GoalType.activityWalk,
          minTarget: 60,
          unit: 'minutes',
          label: 'Walking Time',
          desc: 'Keep this value',
        ),
      ],
      createdAt: DateTime(2026, 9, 1),
      createdBy: 'doctor-1',
    );
    final request = UpdateUserGoalRequest(
      goalId: 'goal-1',
      patientId: 'patient-1',
      startDate: DateTime(2026, 9, 6),
      endDate: DateTime(2026, 10, 1),
      exercises: const [],
      goalItems: const [
        UserGoalItem(
          type: GoalType.stepsWalking,
          minTarget: 5000,
          unit: 'steps',
          label: 'Daily Steps',
          desc: 'Updated value',
        ),
        UserGoalItem(
          type: GoalType.activityWalk,
          minTarget: 60,
          unit: 'minutes',
          label: 'Walking Time',
          desc: 'Keep this value',
        ),
      ],
    );

    final updated = mergeUserGoalUpdate(current, request);

    expect(updated.startDate, DateTime(2026, 9, 6));
    expect(updated.endDate, DateTime(2026, 10, 1));
    expect(updated.goalItems.first.minTarget, 5000);
    expect(updated.goalItems.first.desc, 'Updated value');
    expect(updated.goalItems.last.desc, 'Keep this value');
  });
}
