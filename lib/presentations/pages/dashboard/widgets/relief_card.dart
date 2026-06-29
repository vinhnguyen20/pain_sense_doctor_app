import 'package:app_doctor/common/widgets/section.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/diary/data/models/diary_adherence_model.dart';
import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReliefComponentsCard extends StatefulWidget {
  final PatientDiaryAdherenceModel? adherenceData;
  const ReliefComponentsCard({super.key, this.adherenceData});

  @override
  State<ReliefComponentsCard> createState() => _ReliefComponentsCardState();
}

class _ReliefComponentsCardState extends State<ReliefComponentsCard> {
  int _touchedIndex = -1;

  List<MapEntry<String, ActivityAdherence>> get _entries =>
      widget.adherenceData?.byType.entries.toList() ?? [];

  int _defaultSelectedIndex() {
    if (_entries.isEmpty) return -1;
    var maxIndex = 0;
    var maxValue = _entries.first.value.avgPercent;
    for (var i = 1; i < _entries.length; i++) {
      if (_entries[i].value.avgPercent > maxValue) {
        maxValue = _entries[i].value.avgPercent;
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      context.dashboardColors.chartPrimary,
      context.dashboardColors.chartSecondary,
      context.info,
      context.success,
      context.warning,
    ];

    final entries = _entries;
    final isEmpty = entries.isEmpty;
    const maxY = 100.0;
    final values = entries.map((e) => e.value.avgPercent.clamp(0.0, 100.0)).toList();

    final selectedIndex = _touchedIndex >= 0 && _touchedIndex < entries.length
        ? _touchedIndex
        : _defaultSelectedIndex();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Relief Components',
            subtitle: 'Adherence average by activity type',
          ),
          const SizedBox(height: AppSpacing.s16),
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 28,
                      color: context.onSurface.withValues(alpha: 0.25),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'No adherence data yet',
                      style: context.bodySmall?.copyWith(
                        color: context.onSurface.withValues(alpha: 0.35),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  minY: 0,
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchCallback: (event, response) {
                      setState(() {
                        _touchedIndex =
                            (event is FlPointerExitEvent ||
                                response?.spot == null)
                            ? -1
                            : response!.spot!.touchedBarGroupIndex;
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          context.dashboardColors.tooltipBackground,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final entry = entries[groupIndex];
                        final displayName =
                            GoalType.fromString(entry.key).displayName;
                        return BarTooltipItem(
                          '$displayName\n${entry.value.avgPercent.toInt()}% · ${entry.value.totalDays}d',
                          TextStyle(
                            color: context.dashboardColors.tooltipForeground,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: maxY / 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: context.labelSmall?.copyWith(
                              color: context.onSurface.withValues(alpha: 0.45),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index < 0 || index >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          final label = GoalType.fromString(entries[index].key)
                              .displayName
                              .replaceAll(' / ', '\n');
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.s6),
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: context.labelSmall?.copyWith(
                                color: index == selectedIndex
                                    ? context.onSurface
                                    : context.onSurface.withValues(alpha: 0.6),
                                fontWeight: index == selectedIndex
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: context.border.withValues(alpha: 0.5),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(entries.length, (i) {
                    final isTouched = selectedIndex == i;
                    final color = colors[i % colors.length];
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: values[i],
                          color: isTouched
                              ? color.withValues(alpha: 0.6)
                              : color,
                          width: 48,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.s10),
        ],
      ),
    );
  }
}
