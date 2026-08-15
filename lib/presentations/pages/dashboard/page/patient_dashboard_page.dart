import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/patient_dashboard_content.dart';
import 'package:flutter/material.dart';

class PatientDashboardPage extends StatelessWidget {
  final Patient patient;

  const PatientDashboardPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return PatientDashboardContent(patient: patient);
  }
}
