import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/tracking/presentation/provider/tracking_providers.dart';
import 'package:app_doctor/features/diary/presentation/provider/patient_diary_notifier.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SevenDayTrendCard extends ConsumerWidget {
  final String patientId;

  const SevenDayTrendCard({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingAsync = ref.watch(patientTrackingSummary7DaysProvider(patientId));
    final diaryState = ref.watch(patientDiaryProvider);

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

      final trackItem = trackingData.where((t) {
        final d = t.logDate;
        return d.year == day.year && d.month == day.month && d.day == day.day;
      }).firstOrNull;

      postureScores.add(trackItem?.summary.posture.toDouble() ?? 0.0);

      final diaryItem = diaryState.entries.where((d) {
        return d.date.year == day.year && d.date.month == day.month && d.date.day == day.day;
      }).firstOrNull;

      double adherence = 0;
      if (diaryItem != null && diaryItem.diary.isNotEmpty) {
        double total = 0;
        int valid = 0;
        for (final a in diaryItem.diary) {
          total += a.percent;
          valid++;
        }
        if (valid > 0) adherence = total / valid;
      }
      adherenceScores.add(adherence);
    }

    const postureColor = Color(0xFF58E8EA);
    const adherenceColor = Color(0xFF206EB0);

    final postureSpots = List.generate(7, (i) => FlSpot(i.toDouble(), postureScores[i]));
    final adherenceSpots = List.generate(7, (i) => FlSpot(i.toDouble(), adherenceScores[i]));

    final postureLine = LineChartBarData(
      spots: postureSpots,
      isCurved: true,
      color: postureColor,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
    );

    final adherenceLine = LineChartBarData(
      spots: adherenceSpots,
      isCurved: true,
      color: adherenceColor,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
    );

    return Column(
      children: [
        SizedBox(
          height: 200, 
          child: LineChart(
            LineChartData(
              lineBarsData: [postureLine, adherenceLine],
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 25,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox();
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontFamily: 'Cabin',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF206EB0),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
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
        Container(
          width: 20,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 20),
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
