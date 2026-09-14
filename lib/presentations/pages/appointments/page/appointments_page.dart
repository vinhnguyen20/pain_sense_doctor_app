import 'package:app_doctor/common/widgets/clinician_header.dart';
import 'package:app_doctor/core/config/app_config.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/chats/domain/entites/appointment.dart';
import 'package:app_doctor/features/chats/presentation/provider/appointment_notifier.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/presentation/provider/patients_notifier.dart';
import 'package:app_doctor/features/user/presentation/provider/user_notifier.dart';
import 'package:app_doctor/presentations/pages/appointments/page/patient_appointments_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({super.key});

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage> {
  String _query = '';
  bool _loadingAppointments = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadAppointments();
    });
  }

  Future<void> _loadAppointments({bool refresh = false}) async {
    if (_loadingAppointments) return;
    setState(() => _loadingAppointments = true);
    try {
      final notifier = ref.read(appointmentProvider.notifier);
      if (refresh) await notifier.refresh();
      await notifier.loadAllUpcoming();
    } finally {
      if (mounted) setState(() => _loadingAppointments = false);
    }
  }

  Future<void> _startCreatingAppointment() async {
    final patientsNotifier = ref.read(patientsProvider.notifier);
    var patientsState = ref.read(patientsProvider);
    if (patientsState.patients.isEmpty) {
      await patientsNotifier.fetchPatients();
      patientsState = ref.read(patientsProvider);
    }
    if (!mounted) return;
    if (patientsState.patients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            patientsState.error ?? 'No patients are available to schedule.',
          ),
        ),
      );
      return;
    }

    final patient = await showModalBottomSheet<Patient>(
      context: context,
      backgroundColor: AppPalette.white,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 620, maxHeight: 620),
      builder: (context) => _PatientPicker(patients: patientsState.patients),
    );
    if (!mounted || patient == null) return;
    await context.pushNamed(
      'patient-appointments',
      extra: {'patient': patient, 'startWithCreateForm': true},
    );
    if (mounted) await _loadAppointments(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentProvider);
    final user = ref.watch(userProvider).user;
    final doctorName = user?.fullName.isNotEmpty == true
        ? 'Dr. ${user!.fullName}'
        : 'Doctor';
    final visibleAppointments = appointmentState.appointments.where((item) {
      if (item.status == AppointmentStatus.cancelled) return false;
      if (_query.isEmpty) return true;
      return [
        item.patientName,
        item.title,
        item.description,
      ].join(' ').toLowerCase().contains(_query);
    }).toList();

    final visibleState = AppointmentState(
      appointments: visibleAppointments,
      isLoading:
          (_loadingAppointments || appointmentState.isLoading) &&
          appointmentState.appointments.isEmpty,
      error: appointmentState.error,
      hasMore: false,
    );

    return Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (context.isCompactShell) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s16,
                  AppSpacing.s16,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClinicianHeader(
                      doctorName: doctorName,
                      avatarUrl: _avatarUrl(user?.avatarUrl),
                      onSearchChanged: _setSearch,
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    Expanded(
                      child: AppointmentScheduleContent(
                        state: visibleState,
                        showPatientName: true,
                        onCreateAppointment: _startCreatingAppointment,
                        onRefresh: () => _loadAppointments(refresh: true),
                        onOpenChat: _openAppointmentChat,
                      ),
                    ),
                  ],
                ),
              );
            }

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
                        avatarUrl: _avatarUrl(user?.avatarUrl),
                        onSearchChanged: _setSearch,
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: AppointmentScheduleContent(
                          state: visibleState,
                          showPatientName: true,
                          onCreateAppointment: _startCreatingAppointment,
                          onRefresh: () => _loadAppointments(refresh: true),
                          onOpenChat: _openAppointmentChat,
                        ),
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

  void _setSearch(String value) {
    setState(() => _query = value.trim().toLowerCase());
  }

  Future<void> _openAppointmentChat(Appointment appointment) async {
    final patient = await _patientForAppointment(appointment);
    if (!mounted) return;

    if (patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to find this patient.')),
      );
      return;
    }

    await openPatientChat(context: context, ref: ref, patient: patient);
  }

  Future<Patient?> _patientForAppointment(Appointment appointment) async {
    var patients = ref.read(patientsProvider).patients;
    var match = _matchPatient(patients, appointment);
    if (match != null) return match;

    await ref.read(patientsProvider.notifier).fetchPatients();
    patients = ref.read(patientsProvider).patients;
    return _matchPatient(patients, appointment);
  }

  Patient? _matchPatient(List<Patient> patients, Appointment appointment) {
    final appointmentId = appointment.patientId.trim().toLowerCase();
    final appointmentName = _nameKey(appointment.patientName);

    for (final patient in patients) {
      if (appointmentId.isNotEmpty &&
          patient.id.trim().toLowerCase() == appointmentId) {
        return patient;
      }
      if (appointmentName.isNotEmpty &&
          _nameKey(patient.fullName) == appointmentName) {
        return patient;
      }
    }
    return null;
  }
}

String _nameKey(String value) {
  final words =
      value
          .trim()
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .toList()
        ..sort();
  return words.join(' ');
}

class _PatientPicker extends StatelessWidget {
  final List<Patient> patients;

  const _PatientPicker({required this.patients});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Patient',
              style: AppTypography.heading1.copyWith(
                color: AppPalette.secondaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose the patient for this appointment.',
              style: AppTypography.defaultBody2,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: patients.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: const CircleAvatar(
                      backgroundColor: AppPalette.surfaceLight,
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: AppPalette.secondaryBlue,
                      ),
                    ),
                    title: Text(
                      patient.fullName.trim().isEmpty
                          ? 'Patient'
                          : patient.fullName.trim(),
                    ),
                    subtitle: Text(patient.email ?? patient.phone ?? ''),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).pop(patient),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _avatarUrl(String? rawValue) {
  final raw = rawValue?.trim() ?? '';
  if (raw.isEmpty) return null;
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  return '${AppConfig.baseUrl}${raw.startsWith('/') ? '' : '/'}$raw';
}
