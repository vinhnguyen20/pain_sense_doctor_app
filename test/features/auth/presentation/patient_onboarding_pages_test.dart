import 'package:app_doctor/features/auth/presentation/pages/patient_onboarding_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester, Widget page) async {
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: page)));
    await tester.pump();
  }

  testWidgets('welcome and normal login expose the designed actions', (
    tester,
  ) async {
    await pumpPage(tester, const PatientWelcomePage());
    expect(find.text('Welcome to PainSense'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Back'), findsNothing);
    expect(find.text('Next'), findsNothing);

    await pumpPage(tester, const PatientLoginPage());
    expect(find.text('E-Mail'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsNWidgets(2));
    expect(find.text('Next'), findsNothing);
  });

  testWidgets('registration and profile screens expose all designed fields', (
    tester,
  ) async {
    await pumpPage(tester, const PatientAccountCreationPage());
    for (final label in [
      'First Name',
      'Last Name',
      'E-Mail',
      'Password',
      'Re-Enter Password',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    await pumpPage(tester, const PatientProfileSetupPage());
    for (final label in [
      'Age',
      'Emergency Contact',
      'EC E-Mail',
      'EC Phone #',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('survey steps expose their matching questions', (tester) async {
    await pumpPage(
      tester,
      const PatientSurveyPage(step: PatientSurveyStep.painDuration),
    );
    expect(find.text('1/5'), findsOneWidget);
    expect(
      find.text('How long have you been dealing with lower back pain?'),
      findsOneWidget,
    );

    await pumpPage(
      tester,
      const PatientSurveyPage(step: PatientSurveyStep.painLevel),
    );
    expect(find.text('2/5'), findsOneWidget);
    expect(
      find.text(
        'Rate your back pain on a scale from 1-10, 10 being the worst.',
      ),
      findsOneWidget,
    );

    await pumpPage(
      tester,
      const PatientSurveyPage(step: PatientSurveyStep.activityLevels),
    );
    expect(find.text('3/5'), findsOneWidget);
    expect(
      find.text('How many hours a day do you spend sitting?'),
      findsOneWidget,
    );
    expect(
      find.text('How many hours a day do you spend walking?'),
      findsOneWidget,
    );

    await pumpPage(
      tester,
      const PatientSurveyPage(step: PatientSurveyStep.activity),
    );
    expect(find.text('4/5'), findsOneWidget);
    expect(
      find.text(
        'Approximately how much time do you spend in a day actively exercising?',
      ),
      findsOneWidget,
    );
  });
}
