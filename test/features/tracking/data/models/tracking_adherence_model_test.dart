import 'package:app_doctor/features/diary/data/models/diary_adherence_model.dart';
import 'package:app_doctor/features/tracking/data/models/tracking_summary_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses adherence shape returned by tracking summary 7 days', () {
    final item = TrackingSummaryItemModel.fromJson({
      'log_date': '2026-08-26',
      'summary': {
        'latest_label': 'Unknown',
        'avg_pressure': 0,
        'avg_temp': 0,
        'avg_humidity': 0,
        'total_min_walk': 0,
        'total_steps': 0,
        'total_time_alive': 0,
        'lbp_score': 0,
        'posture': 0,
      },
      'adherence': {
        'overall': 100.0,
        'status': 'high',
        'color': '#00FF00',
        'by_type': {
          'Yoga/Meditation': {
            'percent': 100,
            'status': 'high',
            'color': '#00FF00',
          },
        },
      },
    });

    expect(item.adherence?.overall, 100);
    expect(item.adherence?.byType['Yoga/Meditation']?.avgPercent, 100);
    expect(item.adherence?.byType['Yoga/Meditation']?.totalDays, 1);
  });

  test('still accepts legacy diary avg_percent shape', () {
    final adherence = PatientDiaryAdherenceModel.fromJson({
      'overall': 75,
      'status': 'medium',
      'color': '#FFFF00',
      'by_type': {
        'Steps/Walking': {
          'avg_percent': 75,
          'total_days': 7,
          'status': 'medium',
          'color': '#FFFF00',
        },
      },
    });

    expect(adherence.byType['Steps/Walking']?.avgPercent, 75);
    expect(adherence.byType['Steps/Walking']?.totalDays, 7);
  });
}
