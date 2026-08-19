import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/presentation/provider/user_providers.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/patient_dashboard_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientDashboardPage extends ConsumerStatefulWidget {
  final Patient patient;

  const PatientDashboardPage({super.key, required this.patient});

  @override
  ConsumerState<PatientDashboardPage> createState() =>
      _PatientDashboardPageState();
}

class _PatientDashboardPageState extends ConsumerState<PatientDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(selectedPatientProvider.notifier).setPatient(widget.patient);
    });
  }

  @override
  void didUpdateWidget(covariant PatientDashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patient.id != widget.patient.id) {
      Future.microtask(() {
        ref.read(selectedPatientProvider.notifier).setPatient(widget.patient);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PatientDashboardContent(patient: widget.patient);
  }
}
