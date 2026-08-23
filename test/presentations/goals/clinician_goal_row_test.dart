import 'package:app_doctor/features/diary/data/models/goal_item_model.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';
import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:app_doctor/presentations/pages/goals/widgets/clinician_goal_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('expands a parent goal to show every goal item detail', (
    tester,
  ) async {
    final goal = UserGoalModel(
      id: 'goal-1',
      patientId: 'patient-1',
      doctorId: 'doctor-1',
      startDate: DateTime(2026, 8, 24),
      endDate: DateTime(2026, 8, 31),
      createdAt: DateTime(2026, 8, 23),
      createdBy: 'doctor-1',
      goalItems: const [
        GoalItemModel(
          type: GoalType.stepsWalking,
          minTarget: 5000,
          unit: 'steps',
          label: 'Daily steps',
          desc: 'Walk safely every day',
        ),
        GoalItemModel(
          type: GoalType.yogaMeditation,
          minTarget: 2,
          unit: 'exercises',
          label: 'Morning yoga',
          desc: 'Improve mobility',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClinicianGoalRow(
            goal: goal,
            onAssign: () {},
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('2 goal items'), findsOneWidget);

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    expect(find.text('Daily steps'), findsOneWidget);
    expect(find.text('5000 steps'), findsOneWidget);
    expect(find.text('Walk safely every day'), findsOneWidget);
    expect(find.text('Morning yoga'), findsOneWidget);
    expect(find.text('2 exercises'), findsOneWidget);
    expect(find.text('Improve mobility'), findsOneWidget);
  });
}
