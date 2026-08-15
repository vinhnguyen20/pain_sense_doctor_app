import 'package:app_doctor/common/widgets/section.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LbpScoreCard extends StatelessWidget {
  final int? averageScore;
  final String? status;
  final Color? scoreColor;
  final bool? isAvg;
  final String? lbpFormula;

  const LbpScoreCard({
    super.key,
    this.averageScore,
    this.status,
    this.scoreColor,
    this.isAvg = false,
    this.lbpFormula,
  });

  void _showFormulaSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r16),
        ),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: AppSize.bottomSheetHandleWidth,
                  height: AppSize.bottomSheetHandleHeight,
                  decoration: BoxDecoration(
                    color: context.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
              Text(
                'What is LBP Score?',
                style: context.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                lbpFormula ?? 'No formula available.',
                style: context.bodyMedium?.copyWith(
                  color: context.onSurface.withValues(alpha: 0.7),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: lbpFormula != null ? () => _showFormulaSheet(context) : null,
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Low Back Pain Score',
                  style: context.labelLarge?.copyWith(
                    color: context.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const Spacer(),
                if (lbpFormula != null)
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: context.onSurface.withValues(alpha: 0.3),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            Center(
              child: SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: -90,
                        sectionsSpace: 0,
                        centerSpaceRadius: 52,
                        sections: [
                          PieChartSectionData(
                            value: averageScore?.toDouble() ?? 0,
                            color: scoreColor,
                            radius: 10,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: (100 - (averageScore ?? 0)).toDouble(),
                            color: context.border,
                            radius: 10,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${averageScore ?? 0}',
                      style: context.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Center(
              child: Text(
                status ?? 'N/A',
                style: context.titleMedium?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            if (isAvg == true)
              Center(
                child: Text(
                  'Based on 7-day average',
                  style: context.bodySmall?.copyWith(
                    color: context.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
