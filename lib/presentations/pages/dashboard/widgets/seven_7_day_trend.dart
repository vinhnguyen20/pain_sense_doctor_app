import 'package:app_doctor/features/tracking/presentation/provider/tracking_providers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SevenDayTrendCard extends ConsumerWidget {
  final String patientId;

  const SevenDayTrendCard({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingAsync = ref.watch(
      patientTrackingSummary7DaysProvider(patientId),
    );

    if (trackingAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final trackingData = trackingAsync.value ?? [];

    final now = DateTime.now();
    final List<double> postureScores = [];
    final List<double> adherenceScores = [];
    final List<String> dateLabels = [];

    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final labelIndex = day.weekday == 7 ? 0 : day.weekday;
      dateLabels.add(weekdays[labelIndex]);

      final dayKey =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

      final trackItem = trackingData.where((t) {
        final d = t.logDate;
        final dKey =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        final dLocal = d.toLocal();
        final dLocalKey =
            '${dLocal.year}-${dLocal.month.toString().padLeft(2, '0')}-${dLocal.day.toString().padLeft(2, '0')}';
        return dKey == dayKey ||
            dLocalKey == dayKey ||
            (d.year == day.year && d.month == day.month && d.day == day.day);
      }).firstOrNull;

      postureScores.add(trackItem?.summary.posture.toDouble() ?? 0.0);

      // Adherence is returned together with each day in the tracking summary.
      double adherence =
          trackItem?.adherence?.overall.toDouble() ??
          trackItem?.summary.adherence.toDouble() ??
          0.0;
      adherenceScores.add(adherence);
    }

    const postureColor = Color(0xFF58E8EA);
    const adherenceColor = Color(0xFF206EB0);

    final postureSpots = List.generate(
      7,
      (i) => FlSpot(i.toDouble(), postureScores[i]),
    );
    final adherenceSpots = List.generate(
      7,
      (i) => FlSpot(i.toDouble(), adherenceScores[i]),
    );

    final postureLine = LineChartBarData(
      spots: postureSpots,
      isCurved: false,
      color: postureColor,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 5.5,
            color: postureColor,
            strokeWidth: 0,
          );
        },
      ),
    );

    final adherenceLine = LineChartBarData(
      spots: adherenceSpots,
      isCurved: false,
      color: adherenceColor,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 5.5,
            color: adherenceColor,
            strokeWidth: 0,
          );
        },
      ),
    );

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 10,
            ), // Prevent right marker clipping
            child: LineChart(
              LineChartData(
                clipData: const FlClipData.none(),
                lineBarsData: [postureLine, adherenceLine],
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Color(0xFFC8C8C8), width: 1),
                    bottom: BorderSide(color: Color(0xFFC8C8C8), width: 1),
                    right: BorderSide.none,
                    top: BorderSide.none,
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'Cabin',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF206EB0),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= 7) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            dateLabels[index],
                            style: const TextStyle(
                              fontFamily: 'Cabin',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF206EB0),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                minY: 0,
                maxY: 100,
                minX: 0,
                maxX: 6,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const _LegendItem(color: postureColor, label: 'Posture History'),
        const SizedBox(height: 10),
        const _LegendItem(color: adherenceColor, label: 'Adherence History'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 20, height: 3, color: color),
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cabin',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF206EB0),
          ),
        ),
      ],
    );
  }
}
