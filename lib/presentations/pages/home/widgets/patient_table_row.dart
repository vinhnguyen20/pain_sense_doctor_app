import 'package:app_doctor/common/widgets/activity_tracker.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/core/utils/utils.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientTableRow extends StatelessWidget {
  final Patient patient;
  final VoidCallback? onDetails;

  const PatientTableRow({super.key, required this.patient, this.onDetails});

  @override
  Widget build(BuildContext context) {
    final statusColor = colorFromHex(patient.trackingLogs?.color);
    final painType =
        (patient.painType != null && patient.painType!.trim().isNotEmpty)
        ? patient.painType!
        : '—';

    final activityValues = _getActivityValues(patient.id);
    final barColors = activityValues.map((v) {
      if (v != null && v <= 22.0) {
        return AppPalette.yellow;
      }
      return AppPalette.secondaryBlue;
    }).toList();

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
                      child: ActivityTracker(
                        values: activityValues,
                        barColors: barColors,
                        barWidth: 16,
                        maxBarHeight: 44,
                      ),
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
                onDetails:
                    onDetails ??
                    () {
                      context.goNamed(
                        'patient-dashboard',
                        queryParameters: {'patientId': patient.id},
                        extra: patient,
                      );
                    },
                onDashboard: () {
                  context.goNamed(
                    'patient-dashboard',
                    queryParameters: {'patientId': patient.id},
                    extra: patient,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<double?> _getActivityValues(String id) {
    const patterns = [
      [14.0, 32.0, 44.0, 20.0, 38.0, 16.0, 28.0],
      [28.0, 42.0, 18.0, 36.0, 24.0, 44.0, 32.0],
      [12.0, 24.0, 38.0, 44.0, 22.0, 34.0, 18.0],
      [34.0, 18.0, 28.0, 42.0, 36.0, 20.0, 44.0],
      [22.0, 38.0, 30.0, 14.0, 42.0, 28.0, 36.0],
    ];
    final index = id.hashCode.abs() % patterns.length;
    return patterns[index];
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                Flexible(
                  child: Text(
                    'Dashboard',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                    style: AppTypography.buttonLarge.copyWith(
                      color: AppPalette.white,
                    ),
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
