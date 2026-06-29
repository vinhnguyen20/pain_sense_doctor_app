import 'package:app_doctor/common/widgets/section.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/core/utils/date_utils_helper.dart';
import 'package:app_doctor/core/utils/utils.dart';
import 'package:app_doctor/features/tracking/data/models/tracking_summary_item_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SevenDayTrendCard extends StatefulWidget {
  final List<TrackingSummaryItemModel> items;

  const SevenDayTrendCard({super.key, required this.items});

  @override
  State<SevenDayTrendCard> createState() => _SevenDayTrendCardState();
}

class _SevenDayTrendCardState extends State<SevenDayTrendCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final lbpColor = context.error;
    final postureColor = context.info;

    if (widget.items.isEmpty) {
      return const SectionCard(
        child: SectionHeader(
          title: '7-Day Trend',
          subtitle: 'No tracking data in the last 7 days.',
        ),
      );
    }

    final items = widget.items.reversed.toList();
    final dates = items.map((e) {
      return '${monthAbbr(e.logDate.month)} ${e.logDate.day.toString().padLeft(2, '0')}';
    }).toList();
    final lbpScores = items.map((e) => e.summary.lbpScore.toDouble()).toList();
    final postureScores = items
        .map((e) => e.summary.posture.toDouble())
        .toList();
    final pointCount = dates.length;
    final maxX = pointCount > 1 ? (pointCount - 1).toDouble() : 0.0;
    final selectedIndex = _touchedIndex >= 0 && _touchedIndex < pointCount
        ? _touchedIndex
        : pointCount - 1;

    final lbpSpots = List.generate(
      lbpScores.length,
      (i) => FlSpot(i.toDouble(), lbpScores[i].clamp(0, 100)),
    );
    final postureSpots = List.generate(
      postureScores.length,
      (i) => FlSpot(i.toDouble(), postureScores[i].clamp(0, 100)),
    );

    final lbpBarData = LineChartBarData(
      spots: lbpSpots,
      isCurved: true,
      preventCurveOverShooting: true,
      color: lbpColor,
      barWidth: 2.6,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
          radius: selectedIndex == index ? 5.6 : 4.1,
          color: lbpColor,
          strokeColor: context.dashboardColors.chartStroke,
          strokeWidth: 1.7,
        ),
      ),
      belowBarData: BarAreaData(show: false),
    );
    final postureBarData = LineChartBarData(
      spots: postureSpots,
      isCurved: true,
      preventCurveOverShooting: true,
      color: postureColor,
      barWidth: 2.6,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
          radius: selectedIndex == index ? 5.6 : 4.1,
          color: postureColor,
          strokeColor: context.dashboardColors.chartStroke,
          strokeWidth: 1.7,
        ),
      ),
      belowBarData: BarAreaData(show: false),
    );

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '7-Day Trend',
            style: context.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            height: 228,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maxX,
                minY: 0,
                maxY: 100,
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchSpotThreshold: 18,
                  touchCallback: (event, response) {
                    setState(() {
                      _touchedIndex =
                          (event is FlPointerExitEvent ||
                              response?.lineBarSpots == null)
                          ? -1
                          : response!.lineBarSpots!.first.spotIndex;
                    });
                  },
                  getTouchedSpotIndicator: (barData, spotIndexes) {
                    return spotIndexes.map((spotIndex) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: context.onSurface.withValues(alpha: 0.22),
                          strokeWidth: 1.4,
                          dashArray: const [4, 4],
                        ),
                        FlDotData(
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(
                                radius: 5.5,
                                color: bar.color ?? context.primary,
                                strokeWidth: 2,
                                strokeColor:
                                    context.dashboardColors.chartStroke,
                              ),
                        ),
                      );
                    }).toList();
                  },
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBorderRadius: BorderRadius.circular(AppRadius.r10),
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s10,
                      vertical: AppSpacing.s8,
                    ),
                    tooltipMargin: AppSpacing.s10,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    tooltipBorder: BorderSide(
                      color: context.border.withValues(alpha: 0.45),
                    ),
                    getTooltipColor: (_) =>
                        context.dashboardColors.tooltipBackground,
                    getTooltipItems: (spots) {
                      final orderedSpots = [...spots]
                        ..sort((a, b) => a.barIndex.compareTo(b.barIndex));
                      final i = orderedSpots.first.spotIndex;
                      return orderedSpots.asMap().entries.map((entry) {
                        final itemIndex = entry.key;
                        final spot = entry.value;
                        final isLbp = spot.barIndex == 0;
                        final value = isLbp ? lbpScores[i] : postureScores[i];
                        return LineTooltipItem(
                          '${itemIndex == 0 ? '${dates[i]}\n' : ''}${isLbp ? 'LBP' : 'Posture'}: ${value.toStringAsFixed(0)}',
                          TextStyle(
                            color: context.dashboardColors.tooltipForeground,
                            fontSize: 12,
                            fontWeight: itemIndex == 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                showingTooltipIndicators: selectedIndex >= 0
                    ? [
                        ShowingTooltipIndicators([
                          LineBarSpot(lbpBarData, 0, lbpSpots[selectedIndex]),
                        ]),
                        ShowingTooltipIndicators([
                          LineBarSpot(
                            postureBarData,
                            1,
                            postureSpots[selectedIndex],
                          ),
                        ]),
                      ]
                    : const [],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 20,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toInt()}',
                        style: context.labelLarge?.copyWith(
                          color: context.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 40,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (i < 0 || i >= dates.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.s8),
                          child: Text(
                            DateUtilsHelper.formatDayMonth(items[i].logDate),
                            textAlign: TextAlign.center,
                            style: context.labelLarge?.copyWith(
                              color: i == selectedIndex
                                  ? context.onSurface
                                  : context.onSurface.withValues(alpha: 0.62),
                              fontWeight: i == selectedIndex
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 10,
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
                  drawVerticalLine: true,
                  verticalInterval: 1,
                  horizontalInterval: 20,
                  getDrawingVerticalLine: (_) => FlLine(
                    color: context.border.withValues(alpha: 0.28),
                    strokeWidth: 0.7,
                  ),
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: context.border.withValues(alpha: 0.5),
                    strokeWidth: 0.8,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [lbpBarData, postureBarData],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TrendLegendItem(color: lbpColor, label: 'LBP Score'),
              const SizedBox(width: AppSpacing.s12),
              TrendLegendItem(color: postureColor, label: 'Posture'),
            ],
          ),
        ],
      ),
    );
  }
}

class TrendMilestoneChip extends StatelessWidget {
  final String date;
  final double lbp;
  final double posture;
  final Color lbpColor;
  final Color postureColor;
  final bool isSelected;

  const TrendMilestoneChip({
    super.key,
    required this.date,
    required this.lbp,
    required this.posture,
    required this.lbpColor,
    required this.postureColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? context.primary.withValues(alpha: 0.08)
            : context.onSurface.withValues(alpha: 0.04),
        borderRadius: AppCorners.r10,
        border: Border.all(
          color: isSelected
              ? context.primary.withValues(alpha: 0.5)
              : context.border.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: context.labelLarge?.copyWith(
              color: isSelected
                  ? context.primary
                  : context.onSurface.withValues(alpha: 0.62),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            'LBP ${lbp.toStringAsFixed(0)}',
            style: context.labelLarge?.copyWith(
              color: lbpColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            'Posture ${posture.toStringAsFixed(0)}',
            style: context.labelLarge?.copyWith(
              color: postureColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class TrendLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const TrendLegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 2, color: color),
        const SizedBox(width: 2),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: context.labelLarge?.copyWith(
            color: context.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
