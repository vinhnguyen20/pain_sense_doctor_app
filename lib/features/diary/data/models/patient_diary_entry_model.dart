import 'package:app_doctor/features/diary/data/models/patient_diary_activity_model.dart';
import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_entry.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../../core/utils/entity_convertible.dart';

part 'patient_diary_entry_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PatientDiaryEntryModel extends PatientDiaryEntry
    with EntityConvertible<PatientDiaryEntryModel, PatientDiaryEntry> {
  @JsonKey(name: 'id')
  @override
  final String id;

  @JsonKey(name: '_date')
  @override
  final DateTime date;

  @JsonKey(name: 'diary')
  final List<PatientDiaryActivityModel> diaryModels;

  PatientDiaryEntryModel({
    required this.id,
    required this.date,
    required this.diaryModels,
  }) : super(id: id, date: date, diary: diaryModels);

  factory PatientDiaryEntryModel.fromJson(Map<String, dynamic> json) {
    if (json['diary'] is List) {
      try {
        return _$PatientDiaryEntryModelFromJson(json);
      } catch (_) {
        // Fall through to tolerant mapping below for partially-invalid payload.
      }
    }

    final id = (json['id'] ?? '').toString();
    final rawDate = (json['date'] ?? '').toString();
    final date =
        DateTime.tryParse(rawDate) ?? DateTime.fromMillisecondsSinceEpoch(0);

    final rawDiary = json['diary'] ?? json['goal_items'];
    final diaryList = rawDiary is List
        ? rawDiary
              .whereType<Map<String, dynamic>>()
              .map(_mapActivityFromAnyPayload)
              .toList()
        : const <PatientDiaryActivityModel>[];

    return PatientDiaryEntryModel(id: id, date: date, diaryModels: diaryList);
  }

  Map<String, dynamic> toJson() => _$PatientDiaryEntryModelToJson(this);

  static PatientDiaryActivityModel _mapActivityFromAnyPayload(
    Map<String, dynamic> json,
  ) {
    final label = (json['label'] ?? '').toString();
    final type = GoalType.fromString((json['type'] ?? '').toString());
    final desc = (json['desc'] ?? '').toString();
    final unit = (json['unit'] ?? '').toString();
    final minTarget = _toDouble(json['min_target']);
    final actual = _toDouble(json['actual']);
    final percent = _toDouble(json['percent']);
    final emoji = (json['emoji'] ?? '😟').toString();
    final display = (json['display'] ?? '').toString().trim().isNotEmpty
        ? (json['display'] ?? '').toString()
        : '${_formatNumber(actual)}/${_formatNumber(minTarget)} $unit'.trim();

    return PatientDiaryActivityModel(
      label: label,
      type: type,
      desc: desc,
      unit: unit,
      minTarget: minTarget,
      actual: actual,
      percent: percent,
      emoji: emoji,
      display: display,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _formatNumber(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  @override
  PatientDiaryEntryModel fromEntity(PatientDiaryEntry model) {
    return PatientDiaryEntryModel(
      id: model.id,
      date: model.date,
      diaryModels: model.diary
          .map(
            (a) => PatientDiaryActivityModel(
              label: a.label,
              type: a.type,
              desc: a.desc,
              unit: a.unit,
              minTarget: a.minTarget,
              actual: a.actual,
              percent: a.percent,
              emoji: a.emoji,
              display: a.display,
            ),
          )
          .toList(),
    );
  }

  @override
  PatientDiaryEntry toEntity() {
    return PatientDiaryEntry(
      id: id,
      date: date,
      diary: diaryModels.map((m) => m.toEntity()).toList(),
    );
  }
}
