import 'package:app_doctor/presentations/pages/patient_monitor_detail/page/goal_form_page.dart';
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

    await tester.tap(find.text('Steps / Walking'));
    await tester.tap(find.text('Yoga / Meditation'));
    await tester.tap(find.text('Activity Time'));
    await tester.pump();

    expect(find.text('Steps / Walking'), findsWidgets);
    expect(find.text('Yoga / Meditation'), findsWidgets);
    expect(find.text('Activity Time'), findsWidgets);
    expect(find.text('Yoga Exercises Setup'), findsOneWidget);
    expect(find.text('Title'), findsNWidgets(3));
    expect(find.text('Description'), findsNWidgets(3));
    expect(find.text('Create Goal'), findsWidgets);
  });
}
