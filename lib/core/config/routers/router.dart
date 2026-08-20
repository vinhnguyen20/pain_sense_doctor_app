import 'package:app_doctor/core/config/routers/bottom_navigation.dart';
import 'package:app_doctor/core/config/routers/router_notifier.dart';
import 'package:app_doctor/features/auth/presentation/pages/login_page.dart';
import 'package:app_doctor/features/auth/presentation/provider/auth_notifier.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/presentation/pages/chat_room_page.dart';
import 'package:app_doctor/features/chats/presentation/pages/image_viewer_page.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/presentation/provider/user_providers.dart';
import 'package:app_doctor/presentations/pages/appointments/page/appointments_page.dart';
import 'package:app_doctor/presentations/pages/appointments/page/patient_appointments_page.dart';
import 'package:app_doctor/presentations/pages/dashboard/page/patient_dashboard_page.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/patient_dashboard_scaffold.dart';
import 'package:app_doctor/presentations/pages/goals/page/clinician_goals_page.dart';
import 'package:app_doctor/presentations/pages/home/page/home_page.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/page/goal_form_page.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/page/patient_monitor_detail_page.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart';
import 'package:app_doctor/presentations/pages/connect/page/clinician_connect_page.dart';
import 'package:app_doctor/presentations/pages/patient_connect/page/patient_connect_page.dart';
import 'package:app_doctor/presentations/pages/patient_goals/page/patient_goals_page.dart';
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

        if (authState.isAuthenticated && isOnLogin) {
          return '/home';
        }

        if (authState.isUnauthenticated && !isOnLogin) {
          return '/login';
        }

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
            Patient? patient;
            if (state.extra is Patient) {
              patient = state.extra as Patient;
            } else if (state.extra is Map) {
              patient = (state.extra as Map)['patient'] as Patient?;
            }

            if (patient == null) {
              return const Scaffold(
                body: Center(child: Text('Patient not found')),
              );
            }

            return PatientMonitorDetail(patient: patient);
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return PatientDashboardScaffold(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/patient-dashboard',
                  name: 'patient-dashboard',
                  builder: (context, state) {
                    Patient? patient;
                    if (state.extra is Patient) {
                      patient = state.extra as Patient;
                    } else if (state.extra is Map) {
                      patient = (state.extra as Map)['patient'] as Patient?;
                    }
                    patient ??= ref.read(selectedPatientProvider);

                    if (patient == null) {
                      return const Scaffold(
                        body: Center(child: Text('Patient not found')),
                      );
                    }

                    return PatientDashboardPage(patient: patient);
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/patient-connect',
                  name: 'patient-connect',
                  builder: (context, state) {
                    Patient? patient;
                    if (state.extra is Patient) {
                      patient = state.extra as Patient;
                    } else if (state.extra is Map) {
                      patient = (state.extra as Map)['patient'] as Patient?;
                    }
                    patient ??= ref.read(selectedPatientProvider);
                    return PatientConnectPage(patient: patient);
                  },
                  routes: [
                    GoRoute(
                      path: 'chat',
                      name: 'patient-connect-chat',
                      builder: (context, state) {
                        Conversation? conversation;
                        Patient? patient;
                        if (state.extra is Map) {
                          final map = state.extra as Map;
                          conversation = map['conversation'] as Conversation?;
                          patient = map['patient'] as Patient?;
                        } else if (state.extra is Conversation) {
                          conversation = state.extra as Conversation;
                        }
                        patient ??= ref.read(selectedPatientProvider);

                        if (conversation == null) {
                          return const Scaffold(
                            body: Center(child: Text('Conversation not found')),
                          );
                        }

                        return ChatRoomPage(
                          conversation: conversation,
                          patient: patient,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/patient-exercises',
                  name: 'patient-exercises',
                  builder: (context, state) =>
                      const Scaffold(body: Center(child: Text('Exercises'))),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/patient-goals',
                  name: 'patient-goals',
                  builder: (context, state) {
                    Patient? patient;
                    if (state.extra is Patient) {
                      patient = state.extra as Patient;
                    } else if (state.extra is Map) {
                      patient = (state.extra as Map)['patient'] as Patient?;
                    }
                    patient ??= ref.read(selectedPatientProvider);

                    if (patient == null) {
                      return const Scaffold(
                        body: Center(child: Text('Patient not found')),
                      );
                    }

                    return PatientGoalsPage(patient: patient);
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/patient-settings',
                  name: 'patient-settings',
                  builder: (context, state) =>
                      const Scaffold(body: Center(child: Text('Settings'))),
                ),
              ],
            ),
          ],
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
                  path: '/connect',
                  name: 'clinician-connect',
                  builder: (context, state) => const ClinicianConnectPage(),
                  routes: [
                    GoRoute(
                      path: 'chat',
                      name: 'clinician-chat',
                      builder: (context, state) {
                        Conversation? conversation;
                        Patient? patient;
                        if (state.extra is Map) {
                          final map = state.extra as Map;
                          conversation = map['conversation'] as Conversation?;
                          patient = map['patient'] as Patient?;
                        } else if (state.extra is Conversation) {
                          conversation = state.extra as Conversation;
                        }

                        if (conversation == null) {
                          return const Scaffold(
                            body: Center(child: Text('Conversation not found')),
                          );
                        }

                        return ChatRoomPage(
                          conversation: conversation,
                          patient: patient,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/exercises',
                  name: 'clinician-exercises',
                  builder: (context, state) =>
                      const Scaffold(body: Center(child: Text('Exercises'))),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/goals',
                  name: 'clinician-goals',
                  builder: (context, state) => const ClinicianGoalsPage(),
                  routes: [
                    GoRoute(
                      path: 'patient',
                      name: 'clinician-patient-goals',
                      builder: (context, state) {
                        Patient? patient;
                        if (state.extra is Patient) {
                          patient = state.extra as Patient;
                        } else if (state.extra is Map) {
                          patient = (state.extra as Map)['patient'] as Patient?;
                        }
                        patient ??= ref.read(selectedPatientProvider);

                        if (patient == null) {
                          return const Scaffold(
                            body: Center(child: Text('Patient not found')),
                          );
                        }

                        return ClinicianGoalsPage(initialPatient: patient);
                      },
                    ),
                    GoRoute(
                      path: 'form',
                      name: 'clinician-goal-form',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>?;

                        return GoalFormPage(
                          mode: extra?['mode'] ?? GoalFormMode.create,
                          initialGoal: extra?['initialGoal'],
                          originalGoalItems: extra?['originalGoalItems'],
                          patientId:
                              (extra?['patientId'] as String?)?.trim() ?? '',
                          prefillGoalItems:
                              (extra?['prefillGoalItems'] as List<dynamic>? ??
                                      const [])
                                  .whereType<Map<String, dynamic>>()
                                  .toList(),
                          useClinicianLayout: true,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/appointments',
                  name: 'appointments',
                  builder: (context, state) => const AppointmentsPage(),
                  routes: [
                    GoRoute(
                      path: 'patient',
                      name: 'patient-appointments',
                      builder: (context, state) {
                        Patient? patient;
                        if (state.extra is Patient) {
                          patient = state.extra as Patient;
                        } else if (state.extra is Map) {
                          patient = (state.extra as Map)['patient'] as Patient?;
                        }

                        if (patient == null) {
                          return const Scaffold(
                            body: Center(child: Text('Patient not found')),
                          );
                        }

                        return PatientAppointmentsPage(patient: patient);
                      },
                    ),
                  ],
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
