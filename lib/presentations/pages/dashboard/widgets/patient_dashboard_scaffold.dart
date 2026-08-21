import 'package:app_doctor/common/widgets/compact_navigation_bar.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/patient_dashboard_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientDashboardScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PatientDashboardScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    if (context.isCompactShell) {
      return Scaffold(
        backgroundColor: context.background,
        body: navigationShell,
        bottomNavigationBar: CompactNavigationBar(
          currentIndex: navigationShell.currentIndex,
          destinations: const [
            CompactNavDestination(
              icon: Icons.dashboard_outlined,
              label: 'Overview',
              branchIndex: 0,
            ),
            CompactNavDestination(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Connect',
              branchIndex: 1,
            ),
            CompactNavDestination(
              icon: Icons.accessibility_new_rounded,
              label: 'Exercises',
              branchIndex: 2,
            ),
            CompactNavDestination(
              icon: Icons.flag_outlined,
              label: 'Goals',
              branchIndex: 3,
            ),
          ],
          overflowDestinations: [
            const CompactNavDestination(
              icon: Icons.settings_outlined,
              label: 'Settings',
              branchIndex: 4,
            ),
            CompactNavDestination(
              icon: Icons.arrow_back_rounded,
              label: 'Back to Patients',
              onTap: () => context.go('/home'),
            ),
          ],
          onSelectBranch: (branchIndex) {
            FocusManager.instance.primaryFocus?.unfocus();
            navigationShell.goBranch(
              branchIndex,
              initialLocation: branchIndex == navigationShell.currentIndex,
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.background,
      body: Row(
        children: [
          PatientDashboardSidebar(navigationShell: navigationShell),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
