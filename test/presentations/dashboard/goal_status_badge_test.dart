import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpBadge(WidgetTester tester, GoalModel goal) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GoalStatusBadge(goal: goal)),
      ),
    );
  }

  testWidgets('shows active state when patient has consented', (tester) async {
    await pumpBadge(tester, const GoalModel(patientConsent: true));

    expect(find.text('Active — Patient Consented'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets('shows pending state when patient has not consented', (
    tester,
  ) async {
    await pumpBadge(tester, const GoalModel(patientConsent: false));

    expect(find.text('Pending Consent'), findsOneWidget);
    expect(find.byIcon(Icons.pending_outlined), findsOneWidget);
  });
}
