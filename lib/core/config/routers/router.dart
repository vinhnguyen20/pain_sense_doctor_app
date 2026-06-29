import 'package:app_doctor/core/config/routers/bottom_navigation.dart';
import 'package:app_doctor/core/config/routers/router_notifier.dart';
import 'package:app_doctor/features/auth/presentation/pages/login_page.dart';
import 'package:app_doctor/features/auth/presentation/provider/auth_notifier.dart';
import 'package:app_doctor/features/chats/presentation/pages/image_viewer_page.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/page/goal_form_page.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/page/patient_monitor_detail_page.dart';
import 'package:app_doctor/presentations/pages/dashboard/page/patient_dashboard_page.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/presentations/pages/home/page/home_page.dart';
import 'package:app_doctor/presentations/pages/settings/page/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter createRouter(WidgetRef ref) {
    final notifier = ref.read(routerProvider.notifier);

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/login',
      refreshListenable: notifier,
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        final location = state.matchedLocation;
        final isOnLogin = location == '/login';

        if (authState.isInitial) return null;

        if (authState.isAuthenticated && isOnLogin) return '/home';
        if (authState.isUnauthenticated && !isOnLogin) return '/login';

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/goal-form',
          name: 'goal-form',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;

            return GoalFormPage(
              mode: extra?['mode'] ?? GoalFormMode.create,
              initialGoal: extra?['initialGoal'],
              originalGoalItems: extra?['originalGoalItems'],
              patientId: (extra?['patientId'] as String?)?.trim() ?? '',
              prefillGoalItems:
                  (extra?['prefillGoalItems'] as List<dynamic>? ?? const [])
                      .whereType<Map<String, dynamic>>()
                      .toList(),
            );
          },
        ),
        GoRoute(
          path: '/patient-monitor-detail',
          name: 'patient-monitor-detail',
          builder: (context, state) {
            final patient = state.extra as Patient;

            return PatientMonitorDetail(patient: patient);
          },
        ),
        GoRoute(
          path: '/patient-dashboard',
          name: 'patient-dashboard',
          builder: (context, state) {
            final patient = state.extra as Patient;

            return PatientDashboard(patient: patient);
          },
        ),
        GoRoute(
          path: '/image-viewer',
          pageBuilder: (context, state) {
            final extra = state.extra as ImageViewerArgs;
            return CustomTransitionPage(
              fullscreenDialog: true,
              opaque: false,
              barrierColor: Colors.black87,
              transitionsBuilder: (context, animation, _, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: ImageViewerPage(
                urls: extra.urls,
                initialIndex: extra.initialIndex,
                messageId: extra.messageId,
              ),
            );
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return BottomNavigationScaffold(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  name: 'home',
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/setting',
                  name: 'setting',
                  builder: (context, state) => const SettingsPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
