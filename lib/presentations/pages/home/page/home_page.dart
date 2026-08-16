import 'dart:async';

import 'package:app_doctor/common/widgets/clinician_header.dart';
import 'package:app_doctor/common/widgets/error_retry_view.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/presentation/provider/patients_notifier.dart';
import 'package:app_doctor/presentations/pages/home/widgets/patient_table_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClinicianHomeView extends StatelessWidget {
  final List<Patient> patients;
  final String doctorName;
  final ValueChanged<String>? onSearchChanged;
  final Future<void> Function()? onRefresh;
  final ScrollController? scrollController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool isLoadingMore;
  final bool hasMore;
  final ValueChanged<Patient>? onPatientDetails;

  const ClinicianHomeView({
    super.key,
    required this.patients,
    required this.doctorName,
    this.onSearchChanged,
    this.onRefresh,
    this.scrollController,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.onPatientDetails,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      content = ErrorRetryView(
        message: errorMessage!,
        onRetry: onRetry ?? () {},
      );
    } else {
      content = ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: 20),
        physics: const AlwaysScrollableScrollPhysics(), keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount:
            patients.length +
            (isLoadingMore || !hasMore && patients.isNotEmpty ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          if (index < patients.length) {
            final patient = patients[index];

            return PatientTableRow(
              patient: patient,
              onDetails: onPatientDetails == null
                  ? null
                  : () => onPatientDetails!(patient),
            );
          }

          if (isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No more patients',
                style: AppTypography.defaultBody2.copyWith(
                  color: AppPalette.medGray,
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth < 1208
                ? 1208.0
                : constraints.maxWidth;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                height: constraints.maxHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClinicianHeader(
                        doctorName: doctorName,
                        onSearchChanged: onSearchChanged,
                        onNotificationPressed: () {},
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Welcome to your patient dashboard.',
                        style: AppTypography.titleBig1.copyWith(
                          color: AppPalette.secondaryBlue,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const _PatientTableHeader(),
                      const SizedBox(height: 14),
                      Expanded(
                        child:
                            onRefresh != null &&
                                !isLoading &&
                                errorMessage == null
                            ? RefreshIndicator(
                                onRefresh: onRefresh!,
                                child: content,
                              )
                            : content,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PatientTableHeader extends StatelessWidget {
  const _PatientTableHeader();

  @override
  Widget build(BuildContext context) {
    final headerStyle = AppTypography.defaultBody2.copyWith(
      color: AppPalette.secondaryBlue,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 18,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 34),
                    child: Text('Name/Age', style: headerStyle),
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: Text('Pain Type', style: headerStyle),
                ),
                Expanded(
                  flex: 24,
                  child: Text('Activity Tracker', style: headerStyle),
                ),
                Expanded(flex: 18, child: Text('Contact', style: headerStyle)),
              ],
            ),
          ),
          const SizedBox(width: 40),
          const SizedBox(width: 304),
        ],
      ),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
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
    );
  }
}
