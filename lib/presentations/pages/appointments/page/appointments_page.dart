import 'dart:async';

import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/presentation/provider/patients_notifier.dart';
import 'package:app_doctor/presentations/pages/home/page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({super.key});

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final state = ref.read(patientsProvider);

      if (!state.isLoading && state.patients.isEmpty) {
        ref.read(patientsProvider.notifier).fetchPatients();
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(patientsProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(patientsProvider.notifier).search(value);
    });
  }

  Future<void> _openPatientSchedule(Patient patient) async {
    FocusManager.instance.primaryFocus?.unfocus();

    await Future<void>.delayed(
      const Duration(milliseconds: 100),
    );

    if (!mounted) return;

    context.pushNamed('patient-appointments', extra: patient);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsState = ref.watch(patientsProvider);

    return ClinicianHomeView(
      patients: patientsState.patients,
      doctorName: 'Dr. Cameron Taylor',
      onSearchChanged: _onSearchChanged,
      scrollController: _scrollController,
      isLoading: patientsState.isLoading,
      errorMessage: patientsState.error,
      isLoadingMore: patientsState.isLoadingMore,
      hasMore: patientsState.hasMore,
      onRetry: () => ref.read(patientsProvider.notifier).refresh(),
      onRefresh: () => ref.read(patientsProvider.notifier).refresh(),
      onPatientDetails: _openPatientSchedule,
    );
  }
}
