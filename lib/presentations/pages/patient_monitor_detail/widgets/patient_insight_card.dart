import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/core/utils/utils.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:flutter/material.dart';

class PatientInsightsCard extends StatelessWidget {
  final TrackingLogs? logs;

  const PatientInsightsCard({super.key, this.logs});

  @override
  Widget build(BuildContext context) {
    final lbpScore = '${logs?.lbpScoreValue ?? 0}';

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.sensors, size: 17, color: context.primary),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient Insights',
                      style: context.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Real-time data pulled from dashboard\ntrends, diary, and sensors',
                      style: context.bodySmall?.copyWith(
                        color: context.onSurface.withValues(alpha: 0.5),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(color: context.border, height: 1, thickness: 1),

          Padding(
            padding: const EdgeInsets.all(10),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _InsightCell(
                  label: 'LBP Score',
                  value: lbpScore,
                  valueColor: logs?.scoreColor,
                ),
                _InsightCell(
                  label: 'Risk Level',
                  customWidget: _RiskBadge(logs: logs),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCell extends StatelessWidget {
  final String label;
  final String? value;
  final Color? valueColor;
  final Widget? customWidget;

  const _InsightCell({
    required this.label,
    this.value,
    this.valueColor,
    this.customWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: context.labelLarge?.copyWith(
              color: context.onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 4),
          if (customWidget != null)
            customWidget!
          else
            Text(
              value ?? '',
              style: context.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor ?? context.onSurface,
              ),
            ),
        ],
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final TrackingLogs? logs;
  const _RiskBadge({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: colorFromHex(logs?.color), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        logs?.status ?? 'N/A',
        style: context.labelMedium?.copyWith(
          color: colorFromHex(logs?.color),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
