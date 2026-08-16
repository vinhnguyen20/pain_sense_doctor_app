import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/patient_dashboard_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientDashboardScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PatientDashboardScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Row(
            children: [
              PatientDashboardSidebar(navigationShell: navigationShell),
              Expanded(child: navigationShell),
            ],
          ),
        ),
      ),
    );
  }
}
