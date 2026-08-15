import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/core/utils/utils.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientTableRow extends StatelessWidget {
  final Patient patient;

  const PatientTableRow({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final statusColor = colorFromHex(patient.trackingLogs?.color);

    final painType = patient.trackingLogs?.lbpScore ?? 'Pattern 1';

    return SizedBox(
      width: double.infinity,
      height: 94,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: BoxDecoration(
          color: AppPalette.surfaceLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 66,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 18,
                      child: _PatientIdentity(
                        patient: patient,
                        statusColor: statusColor,
                      ),
                    ),
                    Expanded(
                      flex: 14,
                      child: Text(
                        painType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.defaultBody2.copyWith(
                          color: AppPalette.secondaryBlue,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 24,
                      child: _ActivityTracker(patientName: patient.fullName),
                    ),
                    Expanded(
                      flex: 18,
                      child: _ContactInformation(
                        phone: patient.phone,
                        email: patient.email,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 40),
            SizedBox(
              width: 304,
              height: 50,
              child: _PatientActions(
                onDetails: () {
                  context.pushNamed('patient-monitor-detail', extra: patient);
                },
                onDashboard: () {
                  context.pushNamed('patient-dashboard', extra: patient);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientIdentity extends StatelessWidget {
  final Patient patient;
  final Color? statusColor;

  const _PatientIdentity({required this.patient, this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (statusColor != null) ...[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 24),
        ],
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleBig1.copyWith(
                  color: AppPalette.secondaryBlue,
                ),
              ),
              Text(
                '${patient.age}',
                style: AppTypography.titleBig2.copyWith(
                  color: AppPalette.secondaryBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactInformation extends StatelessWidget {
  final String? phone;
  final String? email;

  const _ContactInformation({this.phone, this.email});

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.defaultBody2.copyWith(
      color: AppPalette.secondaryBlue,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (phone?.isNotEmpty == true)
          Text(
            phone!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        const SizedBox(height: 2),
        if (email?.isNotEmpty == true)
          Text(
            email!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
      ],
    );
  }
}

class _PatientActions extends StatelessWidget {
  final VoidCallback onDetails;
  final VoidCallback onDashboard;

  const _PatientActions({required this.onDetails, required this.onDashboard});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onDetails,
          child: Container(
            width: 112,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppPalette.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Details',
              textAlign: TextAlign.center,
              style: AppTypography.buttonLarge.copyWith(
                color: AppPalette.secondaryBlue,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onDashboard,
          child: Container(
            width: 182,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppPalette.secondaryBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bar_chart_rounded,
                  size: 14,
                  color: AppPalette.white,
                ),
                const SizedBox(width: 6),
                Text(
                  'Dashboard',
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: AppTypography.buttonLarge.copyWith(
                    color: AppPalette.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityTracker extends StatelessWidget {
  final String patientName;

  const _ActivityTracker({required this.patientName});

  static const List<String> _days = ['T', 'F', 'S', 'S', 'M', 'T', 'W'];

  List<double> get _activity {
    switch (patientName) {
      case 'John Smith':
        return const [44, 28, 0, 28, 44, 44, 36];
      case 'Nora Miscavish':
        return const [36, 44, 36, 28, 0, 0, 0];
      case 'Stan Chow':
        return const [36, 44, 36, 44, 44, 44, 44];
      default:
        return const [36, 44, 36, 36, 44, 44, 36];
    }
  }

  @override
  Widget build(BuildContext context) {
    final activity = _activity;

    return SizedBox(
      height: 66,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_days.length, (index) {
          final value = activity[index];

          return Padding(
            padding: EdgeInsets.only(right: index == _days.length - 1 ? 0 : 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 44,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: value == 0
                        ? Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: AppPalette.yellow,
                              shape: BoxShape.circle,
                            ),
                          )
                        : Container(
                            width: 16,
                            height: value,
                            decoration: BoxDecoration(
                              color: AppPalette.secondaryBlue,
                              borderRadius: BorderRadius.circular(49),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _days[index],
                  style: AppTypography.captionBody1.copyWith(
                    color: AppPalette.secondaryBlue,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
