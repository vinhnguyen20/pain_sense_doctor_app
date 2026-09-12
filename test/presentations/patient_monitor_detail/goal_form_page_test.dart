import 'package:app_doctor/features/diary/data/models/goal_item_model.dart';
import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/page/goal_form_page.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('clinician create form exposes every goal section', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: GoalFormPage(
            patientId: 'patient-1',
            useClinicianLayout: true,
            showClinicianHeader: false,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Goal Types'), findsOneWidget);
    expect(find.text('Shared Schedule'), findsOneWidget);
    expect(find.text('Goal Details'), findsOneWidget);
    expect(find.text('Start Date...'), findsOneWidget);
    expect(find.text('End Date...'), findsOneWidget);

    await tester.tap(find.text('Steps/Walking'));
    await tester.tap(find.text('Yoga/Meditation'));
    await tester.tap(find.text('Activity Walk'));
    await tester.pump();

    expect(find.text('Steps/Walking'), findsWidgets);
    expect(find.text('Yoga/Meditation'), findsWidgets);
    expect(find.text('Activity Walk'), findsWidgets);
    expect(find.text('Yoga Exercises Setup'), findsOneWidget);
    expect(find.text('Title'), findsNWidgets(3));
    expect(find.text('Description'), findsNWidgets(3));
    expect(find.text('Create Goal'), findsWidgets);
  });

  testWidgets('clinician edit form uses the same sections as create', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: GoalFormPage(
            patientId: 'patient-1',
            mode: GoalFormMode.edit,
            useClinicianLayout: true,
            showClinicianHeader: false,
            initialGoal: GoalModel(
              id: 'goal-1',
              startDate: DateTime(2026, 9, 5),
              endDate: DateTime(2026, 9, 30),
            ),
            originalGoalItems: const [
              GoalItemModel(
                type: GoalType.stepsWalking,
                minTarget: 5000,
                unit: 'steps',
                label: 'Daily Steps',
                desc: 'Walk every day',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Edit Goal'), findsOneWidget);
    expect(find.text('Goal Types'), findsOneWidget);
    expect(find.text('Shared Schedule'), findsOneWidget);
    expect(find.text('Goal Details'), findsOneWidget);
    expect(find.text('Daily Steps'), findsWidgets);
    expect(find.text('Update Goal'), findsOneWidget);
  });

  testWidgets('item edit shows only the selected goal type', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: GoalFormPage(
            patientId: 'patient-1',
            mode: GoalFormMode.edit,
            editGoalType: GoalType.activityWalk,
            useClinicianLayout: true,
            showClinicianHeader: false,
            initialGoal: GoalModel(
              id: 'goal-1',
              startDate: DateTime(2026, 9, 5),
              endDate: DateTime(2026, 9, 30),
            ),
            originalGoalItems: const [
              GoalItemModel(
                type: GoalType.stepsWalking,
                minTarget: 100,
                unit: 'steps',
                label: 'Daily Steps',
                desc: 'Walk every day',
              ),
              GoalItemModel(
                type: GoalType.activityWalk,
                minTarget: 60,
                unit: 'minutes',
                label: 'Walking Time',
                desc: 'Walk for one hour',
              ),
              GoalItemModel(
                type: GoalType.yogaMeditation,
                minTarget: 2,
                unit: 'exercises',
                label: 'Yoga',
                desc: 'Two exercises',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Edit the selected goal item.'), findsOneWidget);
    expect(find.text('Walking Time'), findsWidgets);
    expect(find.text('Daily Steps'), findsNothing);
    expect(find.text('Yoga'), findsNothing);
  });
}
