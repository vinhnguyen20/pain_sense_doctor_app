class PatientDiaryAdherenceModel {
  final double overall;

  final String status;

  final String color;

  final Map<String, ActivityAdherence> byType;

  const PatientDiaryAdherenceModel({
    required this.overall,
    required this.status,
    required this.color,
    required this.byType,
  });

  factory PatientDiaryAdherenceModel.fromJson(Map<String, dynamic> json) {
    final rawByType = json['by_type'];
    final byType = <String, ActivityAdherence>{};
    if (rawByType is Map) {
      for (final entry in rawByType.entries) {
        final value = entry.value;
        if (value is Map) {
          byType[entry.key.toString()] = ActivityAdherence.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      }
    }

    return PatientDiaryAdherenceModel(
      overall: _toDouble(json['overall']),
      status: json['status']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      byType: byType,
    );
  }

  Map<String, dynamic> toJson() => {
    'overall': overall,
    'status': status,
    'color': color,
    'by_type': byType.map((key, value) => MapEntry(key, value.toJson())),
  };

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ActivityAdherence {
  final double avgPercent;

  final int totalDays;

  final String status;

  final String color;

  const ActivityAdherence({
    required this.avgPercent,
    required this.totalDays,
    required this.status,
    required this.color,
  });

  factory ActivityAdherence.fromJson(Map<String, dynamic> json) {
    final rawPercent = json['avg_percent'] ?? json['percent'];
    final rawDays = json['total_days'];
    return ActivityAdherence(
      avgPercent: PatientDiaryAdherenceModel._toDouble(rawPercent),
      totalDays: rawDays is num
          ? rawDays.toInt()
          : int.tryParse(rawDays?.toString() ?? '') ?? 1,
      status: json['status']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'avg_percent': avgPercent,
    'total_days': totalDays,
    'status': status,
    'color': color,
  };
}
