import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/patient_dashboard_content.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/patient_dashboard_sidebar.dart';
import 'package:flutter/material.dart';

class PatientDashboard extends StatelessWidget {
  final Patient patient;

  const PatientDashboard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: Row(
        children: [
          PatientDashboardSidebar(patient: patient),
          Expanded(child: PatientDashboardContent(patient: patient)),
        ],
      ),
    );
  }
}
