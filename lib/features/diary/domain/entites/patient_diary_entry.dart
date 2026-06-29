import 'package:equatable/equatable.dart';
import 'patient_diary_activity.dart';

class PatientDiaryEntry extends Equatable {
  final String id;
  final DateTime date;
  final List<PatientDiaryActivity> diary;

  const PatientDiaryEntry({
    required this.id,
    required this.date,
    required this.diary,
  });

  @override
  List<Object?> get props => [id, date, diary];
}
