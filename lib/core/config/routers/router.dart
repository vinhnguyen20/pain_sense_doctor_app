import 'package:app_doctor/core/config/routers/bottom_navigation.dart';
import 'package:app_doctor/core/config/routers/router_notifier.dart';
import 'package:app_doctor/features/auth/presentation/pages/patient_onboarding_pages.dart';
import 'package:app_doctor/features/auth/presentation/provider/auth_notifier.dart';
import 'package:app_doctor/features/chats/domain/entites/conversation.dart';
import 'package:app_doctor/features/chats/presentation/pages/chat_room_page.dart';
import 'package:app_doctor/features/chats/presentation/provider/conversation_notifier.dart';
import 'package:app_doctor/features/chats/presentation/pages/image_viewer_page.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';
import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/presentation/provider/user_providers.dart';
import 'package:app_doctor/presentations/pages/appointments/page/appointments_page.dart';
import 'package:app_doctor/presentations/pages/appointments/page/patient_appointments_page.dart';
import 'package:app_doctor/presentations/pages/dashboard/page/patient_dashboard_page.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/patient_dashboard_scaffold.dart';
import 'package:app_doctor/presentations/pages/goals/page/clinician_goals_page.dart';
import 'package:app_doctor/presentations/pages/goals/page/clinician_goal_detail_page.dart';
import 'package:app_doctor/presentations/pages/home/page/home_page.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/page/goal_form_page.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/page/patient_monitor_detail_page.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart';
import 'package:app_doctor/presentations/pages/connect/page/clinician_connect_page.dart';
import 'package:app_doctor/presentations/pages/patient_connect/page/patient_connect_page.dart';
import 'package:app_doctor/presentations/pages/patient_goals/page/patient_goals_page.dart';
import 'package:app_doctor/presentations/pages/settings/page/settings_page.dart';
import 'package:app_doctor/presentations/pages/settings/page/clinician_settings_page.dart';
import 'package:app_doctor/presentations/pages/exercises/page/patient_exercises_page.dart';
import 'package:app_doctor/presentations/pages/exercises/page/clinician_exercises_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter createRouter(WidgetRef ref) {
    final notifier = ref.read(routerProvider.notifier);

    Patient? resolvePatient(GoRouterState state) {
      Patient? patient;
      if (state.extra is Patient) {
        patient = state.extra as Patient;
      } else if (state.extra is Map) {
        patient = (state.extra as Map)['patient'] as Patient?;
      }

      final patientId =
          state.uri.queryParameters['patientId']?.trim() ?? patient?.id.trim();
      final selectedPatient = ref.read(selectedPatientProvider);
      if (patient == null &&
          patientId != null &&
          patientId.isNotEmpty &&
          selectedPatient?.id.trim() == patientId) {
        patient = selectedPatient;
      }
      return patient;
    }

    String resolvePatientId(
      Map<String, dynamic>? extra, [
      GoRouterState? state,
    ]) {
      final urlId = state?.uri.queryParameters['patientId']?.trim();
      if (urlId != null && urlId.isNotEmpty) return urlId;
      final stateExtra = state?.extra;
      if (stateExtra is Patient && stateExtra.id.trim().isNotEmpty) {
        return stateExtra.id.trim();
      }
      if (stateExtra is Map) {
        final stateExtraId = (stateExtra['patientId'] as String?)?.trim();
        if (stateExtraId != null && stateExtraId.isNotEmpty) {
          return stateExtraId;
        }
        final statePatient = stateExtra['patient'] as Patient?;
        if (statePatient != null && statePatient.id.trim().isNotEmpty) {
          return statePatient.id.trim();
        }
      }
      final explicitId = (extra?['patientId'] as String?)?.trim();
      if (explicitId != null && explicitId.isNotEmpty) return explicitId;
      final patient = extra?['patient'] as Patient?;
      if (patient != null && patient.id.trim().isNotEmpty) {
        return patient.id.trim();
      }
      return ref.read(selectedPatientProvider)?.id.trim() ?? '';
    }

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/intro',
      refreshListenable: notifier,
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        final location = state.matchedLocation;
        final isOnPublicAuthRoute =
            location == '/login' ||
            location == '/intro' ||
            location == '/welcome' ||
            location == '/register' ||
            location == '/profile-setup' ||
            location.startsWith('/survey/');

        if (authState.isInitial) return null;

        if (authState.isAuthenticated && isOnPublicAuthRoute) {
          return '/home';
        }

        if (authState.isUnauthenticated && !isOnPublicAuthRoute) {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const PatientLoginPage(),
        ),
        GoRoute(
          path: '/intro',
          name: 'patient-intro',
          builder: (context, state) => const PatientIntroPage(),
        ),
        GoRoute(
          path: '/welcome',
          name: 'patient-welcome',
          builder: (context, state) => const PatientWelcomePage(),
        ),
        GoRoute(
          path: '/register',
          name: 'patient-register',
          builder: (context, state) => const PatientAccountCreationPage(),
        ),
        GoRoute(
          path: '/profile-setup',
          name: 'patient-profile-setup',
          builder: (context, state) => const PatientProfileSetupPage(),
        ),
        GoRoute(
          path: '/survey/pain-duration',
          name: 'patient-survey-pain-duration',
          builder: (context, state) =>
              const PatientSurveyPage(step: PatientSurveyStep.painDuration),
        ),
        GoRoute(
          path: '/survey/pain-level',
          name: 'patient-survey-pain-level',
          builder: (context, state) =>
              const PatientSurveyPage(step: PatientSurveyStep.painLevel),
        ),
        GoRoute(
          path: '/survey/activity-levels',
          name: 'patient-survey-activity-levels',
          builder: (context, state) =>
              const PatientSurveyPage(step: PatientSurveyStep.activityLevels),
        ),
        GoRoute(
          path: '/survey/activity',
          name: 'patient-survey-activity',
          builder: (context, state) =>
              const PatientSurveyPage(step: PatientSurveyStep.activity),
        ),
        GoRoute(
          path: '/survey/complete',
          name: 'patient-survey-complete',
          builder: (context, state) => const PatientSurveyCompletePage(),
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
              editGoalType: extra?['editGoalType'],
              patientId: resolvePatientId(extra, state),
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
                    return _PatientRoute(
                      patientId: resolvePatientId(null, state),
                      initialPatient: resolvePatient(state),
                      builder: (patient) =>
                          PatientDashboardPage(patient: patient),
                    );
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
                    return _PatientRoute(
                      patientId: resolvePatientId(null, state),
                      initialPatient: resolvePatient(state),
                      builder: (patient) =>
                          PatientConnectPage(patient: patient),
                    );
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
                        return _PatientChatRoute(
                          patientId: resolvePatientId(null, state),
                          conversationId:
                              state.uri.queryParameters['conversationId']
                                  ?.trim() ??
                              conversation?.id ??
                              '',
                          initialPatient: patient ?? resolvePatient(state),
                          initialConversation: conversation,
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
                  builder: (context, state) {
                    return _PatientRoute(
                      patientId: resolvePatientId(null, state),
                      initialPatient: resolvePatient(state),
                      builder: (patient) =>
                          PatientExercisesPage(patient: patient),
                    );
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/patient-goals',
                  name: 'patient-goals',
                  builder: (context, state) {
                    return _PatientRoute(
                      patientId: resolvePatientId(null, state),
                      initialPatient: resolvePatient(state),
                      builder: (patient) => PatientGoalsPage(patient: patient),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'form',
                      name: 'patient-goal-form',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>?;
                        final patientId = resolvePatientId(extra, state);
                        return _PatientRoute(
                          patientId: patientId,
                          initialPatient: resolvePatient(state),
                          builder: (patient) => _PatientGoalFormContent(
                            patientId: patient.id,
                            goalId:
                                state.uri.queryParameters['goalId']?.trim() ??
                                '',
                            goalType: state.uri.queryParameters['goalType']
                                ?.trim(),
                            extra: extra,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      path: 'detail',
                      name: 'patient-goal-detail',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>?;
                        final goal = extra?['goal'] as UserGoalModel?;
                        final patient = extra?['patient'] as Patient?;
                        return _PatientRoute(
                          patientId: resolvePatientId(extra, state),
                          initialPatient: patient ?? resolvePatient(state),
                          builder: (loadedPatient) => _PatientGoalDetailContent(
                            patient: loadedPatient,
                            goalId:
                                state.uri.queryParameters['goalId']?.trim() ??
                                goal?.id ??
                                '',
                            initialGoal: goal,
                          ),
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
                  path: '/patient-settings',
                  name: 'patient-settings',
                  builder: (context, state) => _PatientRoute(
                    patientId: resolvePatientId(null, state),
                    initialPatient: resolvePatient(state),
                    builder: (_) => const SettingsPage(),
                  ),
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
                  builder: (context, state) => const ClinicianExercisesPage(),
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
                          editGoalType: extra?['editGoalType'],
                          patientId: resolvePatientId(extra, state),
                          prefillGoalItems:
                              (extra?['prefillGoalItems'] as List<dynamic>? ??
                                      const [])
                                  .whereType<Map<String, dynamic>>()
                                  .toList(),
                          useClinicianLayout: true,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'detail',
                      name: 'clinician-goal-detail',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>?;
                        final goal = extra?['goal'] as UserGoalModel?;
                        final patient = extra?['patient'] as Patient?;
                        if (goal == null || patient == null) {
                          return const Scaffold(
                            body: Center(child: Text('Goal not found')),
                          );
                        }
                        return ClinicianGoalDetailPage(
                          goal: goal,
                          patient: patient,
                          insidePatientDashboard:
                              extra?['insidePatientDashboard'] as bool? ??
                              false,
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
                  builder: (context, state) => const ClinicianSettingsPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _PatientRoute extends ConsumerWidget {
  final String patientId;
  final Patient? initialPatient;
  final Widget Function(Patient patient) builder;

  const _PatientRoute({
    required this.patientId,
    required this.initialPatient,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (patientId.isEmpty) {
      return const Scaffold(body: Center(child: Text('Patient not found')));
    }

    final patient = initialPatient;
    if (patient != null && patient.id == patientId) {
      _rememberPatient(ref, patient);
      return builder(patient);
    }

    final patientAsync = ref.watch(patientDetailProvider(patientId));
    return patientAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load patient information.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(patientDetailProvider(patientId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (loadedPatient) {
        if (loadedPatient == null) {
          return const Scaffold(body: Center(child: Text('Patient not found')));
        }
        _rememberPatient(ref, loadedPatient);
        return builder(loadedPatient);
      },
    );
  }

  void _rememberPatient(WidgetRef ref, Patient patient) {
    if (ref.read(selectedPatientProvider)?.id == patient.id) return;
    Future.microtask(() {
      ref.read(selectedPatientProvider.notifier).setPatient(patient);
    });
  }
}

class _PatientChatRoute extends ConsumerWidget {
  final String patientId;
  final String conversationId;
  final Patient? initialPatient;
  final Conversation? initialConversation;

  const _PatientChatRoute({
    required this.patientId,
    required this.conversationId,
    required this.initialPatient,
    required this.initialConversation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PatientRoute(
      patientId: patientId,
      initialPatient: initialPatient,
      builder: (patient) {
        final conversationState = ref.watch(conversationsProvider);
        Conversation? conversation = initialConversation;
        if (conversation == null ||
            (conversationId.isNotEmpty && conversation.id != conversationId)) {
          for (final item in conversationState.conversations) {
            final matchesConversation =
                conversationId.isNotEmpty && item.id == conversationId;
            final matchesPatient = item.participants.contains(patient.id);
            if (matchesConversation || matchesPatient) {
              conversation = item;
              break;
            }
          }
        }

        if (conversation != null) {
          return ChatRoomPage(conversation: conversation, patient: patient);
        }
        if (conversationState.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to load conversation.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => ref
                        .read(conversationsProvider.notifier)
                        .fetchConversations(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _PatientGoalFormContent extends ConsumerWidget {
  final String patientId;
  final String goalId;
  final String? goalType;
  final Map<String, dynamic>? extra;

  const _PatientGoalFormContent({
    required this.patientId,
    required this.goalId,
    required this.goalType,
    required this.extra,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialGoal = extra?['initialGoal'];
    final hasInitialGoal = initialGoal != null;
    if (goalId.isEmpty || hasInitialGoal) {
      return _buildForm();
    }

    final goalsAsync = ref.watch(patientUserGoalsProvider(patientId));
    return goalsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => _GoalLoadError(
        onRetry: () => ref.invalidate(patientUserGoalsProvider(patientId)),
      ),
      data: (goals) {
        final goal = goals.where((item) => item.id == goalId).firstOrNull;
        if (goal == null) {
          return const Scaffold(body: Center(child: Text('Goal not found')));
        }
        return GoalFormPage(
          mode: GoalFormMode.edit,
          initialGoal: goal.toGoalModel(),
          originalGoalItems: goal.goalItems,
          editGoalType: _resolvedGoalType,
          patientId: patientId,
          useClinicianLayout: true,
          showClinicianHeader: false,
        );
      },
    );
  }

  GoalType? get _resolvedGoalType {
    final type = GoalType.fromString(goalType);
    return type == GoalType.unknown ? null : type;
  }

  Widget _buildForm() {
    return GoalFormPage(
      mode: extra?['mode'] ?? GoalFormMode.create,
      initialGoal: extra?['initialGoal'],
      originalGoalItems: extra?['originalGoalItems'],
      editGoalType: extra?['editGoalType'],
      patientId: patientId,
      prefillGoalItems:
          (extra?['prefillGoalItems'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .toList(),
      useClinicianLayout: true,
      showClinicianHeader: false,
    );
  }
}

class _PatientGoalDetailContent extends ConsumerWidget {
  final Patient patient;
  final String goalId;
  final UserGoalModel? initialGoal;

  const _PatientGoalDetailContent({
    required this.patient,
    required this.goalId,
    required this.initialGoal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = initialGoal;
    if (goal != null && (goalId.isEmpty || goal.id == goalId)) {
      return ClinicianGoalDetailPage(
        goal: goal,
        patient: patient,
        insidePatientDashboard: true,
      );
    }

    final goalsAsync = ref.watch(patientUserGoalsProvider(patient.id));
    return goalsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => _GoalLoadError(
        onRetry: () => ref.invalidate(patientUserGoalsProvider(patient.id)),
      ),
      data: (goals) {
        final loadedGoal = goals.where((item) => item.id == goalId).firstOrNull;
        if (loadedGoal == null) {
          return const Scaffold(body: Center(child: Text('Goal not found')));
        }
        return ClinicianGoalDetailPage(
          goal: loadedGoal,
          patient: patient,
          insidePatientDashboard: true,
        );
      },
    );
  }
}

class _GoalLoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _GoalLoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Unable to load goal.'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
