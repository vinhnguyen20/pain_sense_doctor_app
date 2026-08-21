import 'package:app_doctor/common/widgets/clinician_header.dart';
import 'package:app_doctor/core/config/theme/app_theme.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/presentations/pages/home/page/home_page.dart';
import 'package:app_doctor/presentations/pages/home/widgets/patient_card.dart';
import 'package:app_doctor/presentations/pages/patient_connect/page/patient_connect_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const patient = Patient(
    id: 'patient-1',
    firstName: 'Alexandria',
    lastName: 'Montgomery',
    email: 'alexandria.montgomery@example.com',
    phone: '+1 555 010 9999',
    trackingLogs: TrackingLogs(
      lbpScore: '42/100',
      status: 'Improving',
      color: '#206EB0',
    ),
  );

  for (final size in [
    const Size(320, 700),
    const Size(360, 800),
    const Size(390, 844),
    const Size(768, 1024),
  ]) {
    testWidgets('compact widgets do not overflow at ${size.width.toInt()}px', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const ClinicianHeader(
                    doctorName: 'Dr. Montgomery-With-A-Long-Name',
                  ),
                  const SizedBox(height: 16),
                  PatientConnectTabs(
                    selectedTab: PatientConnectTab.chat,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  const PatientCard(patient: patient),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Search Patients...'), findsOneWidget);
      expect(find.text('Alexandria Montgomery'), findsOneWidget);
    });
  }

  testWidgets('compact patient list uses cards without horizontal overflow', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ClinicianHomeView(
          patients: [patient],
          doctorName: 'Dr. Montgomery-With-A-Long-Name',
        ),
      ),
    );

    expect(find.byType(PatientCard), findsOneWidget);
    expect(find.text('Welcome to your patient dashboard.'), findsOneWidget);
  });
}
