import 'package:app_doctor/common/widgets/section.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/diary/data/models/diary_adherence_model.dart';
import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AdherenceMetricsCard extends StatefulWidget {
  final PatientDiaryAdherenceModel adherenceData;

  const AdherenceMetricsCard({super.key, required this.adherenceData});

  @override
  State<AdherenceMetricsCard> createState() => _AdherenceMetricsCardState();
}

class _AdherenceMetricsCardState extends State<AdherenceMetricsCard> {
  int _selectedMetricIndex = 0;

  List<(String, double)> get _metrics {
    return widget.adherenceData.byType.entries
        .map((e) => (e.key, e.value.avgPercent))
        .toList();
  }

  String _displayName(String key) => GoalType.fromString(key).displayName;

  @override
  Widget build(BuildContext context) {
    if (_metrics.isEmpty) return const SizedBox.shrink();

    final overall = widget.adherenceData.overall;

    final values = _metrics
        .map((item) => item.$2.clamp(0, 100).toDouble())
        .toList();

    final tone = overall >= 75
        ? context.success
        : overall >= 60
        ? context.warning
        : context.error;

    final highlightedValues = List<double>.generate(
      _metrics.length,
      (index) => index == _selectedMetricIndex ? values[index] : 0,
    );

    final selectedMetric = _metrics[_selectedMetricIndex];
    final selectedDetail = widget.adherenceData.byType[selectedMetric.$1];

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Adherence Metrics',
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s10,
                vertical: AppSpacing.s6,
              ),
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.14),
                borderRadius: AppCorners.r16,
              ),
              child: Text(
                '${overall.toInt()}%',
                style: context.labelLarge?.copyWith(
                  color: tone,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s14),

          GestureDetector(
            onTap: () {
              setState(() {
                _selectedMetricIndex =
                    (_selectedMetricIndex + 1) % _metrics.length;
              });
            },
            child: SizedBox(
              height: 250,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  tickCount: 5,
                  titlePositionPercentageOffset: 0.18,
                  gridBorderData: BorderSide(
                    color: context.border.withValues(alpha: 0.55),
                    width: 1,
                  ),
                  tickBorderData: BorderSide(
                    color: context.border.withValues(alpha: 0.45),
                    width: 1,
                  ),
                  radarBorderData: BorderSide(
                    color: context.border.withValues(alpha: 0.65),
                    width: 1.2,
                  ),
                  titleTextStyle: context.labelSmall?.copyWith(
                    color: context.onSurface.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w600,
                  ),
                  ticksTextStyle: context.labelSmall?.copyWith(
                    color: context.onSurface.withValues(alpha: 0.42),
                    fontSize: 10,
                  ),
                  getTitle: (index, angle) => RadarChartTitle(
                    text: _displayName(_metrics[index].$1),
                    angle: 0,
                  ),
                  dataSets: [
                    RadarDataSet(
                      fillColor: context.primary.withValues(alpha: 0.20),
                      borderColor: context.primary,
                      borderWidth: 2.2,
                      entryRadius: 3,
                      dataEntries: values
                          .map((v) => RadarEntry(value: v))
                          .toList(),
                    ),
                    RadarDataSet(
                      fillColor: context.info.withValues(alpha: 0.08),
                      borderColor: context.info,
                      borderWidth: 2.4,
                      entryRadius: 4,
                      dataEntries: highlightedValues
                          .map((v) => RadarEntry(value: v))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.s10),

          if (selectedDetail != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s8),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: context.info.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: AppSpacing.s6),
                  Text(
                    '${_displayName(selectedMetric.$1)}: '
                    '${selectedDetail.avgPercent.toInt()}% avg '
                    '· ${selectedDetail.totalDays} day${selectedDetail.totalDays > 1 ? 's' : ''}',
                    style: context.labelSmall?.copyWith(
                      color: context.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: List.generate(_metrics.length, (index) {
              final metric = _metrics[index];
              final isSelected = index == _selectedMetricIndex;
              return InkWell(
                borderRadius: AppCorners.r10,
                onTap: () => setState(() => _selectedMetricIndex = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s10,
                    vertical: AppSpacing.s8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.info.withValues(alpha: 0.12)
                        : context.onSurface.withValues(alpha: 0.04),
                    borderRadius: AppCorners.r10,
                    border: Border.all(
                      color: isSelected
                          ? context.info.withValues(alpha: 0.35)
                          : context.border.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Text(
                    '${_displayName(metric.$1)}: ${metric.$2.toInt()}%',
                    style: context.labelSmall?.copyWith(
                      color: isSelected
                          ? context.info
                          : context.onSurface.withValues(alpha: 0.74),
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: AppSpacing.s10),
        ],
      ),
    );
  }
}
