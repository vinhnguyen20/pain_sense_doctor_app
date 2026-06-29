import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/core/utils/utils.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;

  const PatientCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppCorners.r12,
        border: Border.all(color: context.border),
      ),
      padding: AppInsets.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            patient.fullName,
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            'Age: ${patient.age}',
            style: context.bodySmall?.copyWith(
              color: context.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),

          Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: context.surface.withAlpha(200),
              borderRadius: AppCorners.r8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LBP Score',
                  style: context.labelSmall?.copyWith(
                    color: context.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: patient.trackingLogs?.lbpScore.toString(),
                            style: context.displaySmall?.copyWith(
                              color: colorFromHex(patient.trackingLogs?.color),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' /100',
                            style: context.bodyMedium?.copyWith(
                              color: context.onSurface.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s10,
                        vertical: AppSpacing.s4,
                      ),
                      decoration: BoxDecoration(
                        color: colorFromHex(
                          patient.trackingLogs?.color,
                        ).withValues(alpha: 0.15),
                        borderRadius: AppCorners.r20,
                      ),
                      child: Text(
                        patient.trackingLogs?.status ?? 'N/A',
                        style: context.labelSmall?.copyWith(
                          color: colorFromHex(patient.trackingLogs?.color),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s10),

          Text(
            'Status: ${patient.trackingLogs?.status ?? 'N/A'}',
            style: context.bodySmall?.copyWith(
              color: context.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.s14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.pushNamed('patient-monitor-detail', extra: patient);
                  },
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: AppSpacing.s10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.pushNamed('patient-dashboard', extra: patient);
                  },
                  icon: const Icon(Icons.bar_chart, size: AppSize.iconSm),
                  label: const Text('Dashboard'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
