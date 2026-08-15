import 'package:app_doctor/common/widgets/clinician_header.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/presentations/pages/home/widgets/patient_card.dart';
import 'package:app_doctor/presentations/pages/home/widgets/patient_table_row.dart';
import 'package:flutter/material.dart';

class ClinicianHomeView extends StatelessWidget {
  final List<Patient> patients;
  final String doctorName;
  final ValueChanged<String>? onSearchChanged;
  final void Function(Patient)? onPatientDetails;
  final void Function(Patient)? onPatientDashboard;

  const ClinicianHomeView({
    super.key,
    required this.patients,
    required this.doctorName,
    this.onSearchChanged,
    this.onPatientDetails,
    this.onPatientDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPalette.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 840;

          if (!isDesktop) {
            return _buildMobile(context);
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
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClinicianHeader(
                      doctorName: doctorName,
                      onSearchChanged: onSearchChanged,
                      onNotificationPressed: () {},
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome to your patient dashboard.',
                      style: AppTypography.titleBig1.copyWith(
                        color: AppPalette.secondaryBlue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _PatientTableHeader(),
                    const SizedBox(height: 14),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: patients.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          return PatientTableRow(patient: patients[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Column(
      children: [
        ClinicianHeader(
          doctorName: doctorName,
          onSearchChanged: onSearchChanged,
          onNotificationPressed: () {},
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: patients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return PatientCard(patient: patients[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _PatientTableHeader extends StatelessWidget {
  const _PatientTableHeader();

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.defaultBody2.copyWith(
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
                    child: Text('Name/Age', style: style),
                  ),
                ),
                Expanded(flex: 14, child: Text('Pain Type', style: style)),
                Expanded(
                  flex: 24,
                  child: Text('Activity Tracker', style: style),
                ),
                Expanded(flex: 18, child: Text('Contact', style: style)),
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
