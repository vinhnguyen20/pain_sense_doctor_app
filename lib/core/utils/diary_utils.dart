import 'package:app_doctor/features/diary/domain/entites/patient_diary_entry.dart';

abstract final class DiaryUtils {
  static double? calculateDailyAdherence(PatientDiaryEntry entry) {
    if (entry.diary.isEmpty) {
      return null;
    }

    double totalPercent = 0.0;
    int validCount = 0;

    for (final activity in entry.diary) {
      totalPercent += activity.percent;
      validCount++;
    }

    if (validCount == 0) return null;

    return totalPercent / validCount;
  }
}
