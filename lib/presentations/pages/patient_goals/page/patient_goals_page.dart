import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/presentations/pages/goals/page/clinician_goals_page.dart';
import 'package:flutter/material.dart';

class PatientGoalsPage extends StatelessWidget {
  final Patient patient;

  const PatientGoalsPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return ClinicianGoalsPage(initialPatient: patient);
  }
}
