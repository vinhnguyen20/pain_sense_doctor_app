class DiaryActivity {
  final String description;
  final String type;
  final int durationMinutes;

  const DiaryActivity({
    required this.description,
    required this.type,
    required this.durationMinutes,
  });
}

class Diary {
  final String id;
  final String userId;
  final String? comment;
  final String? note;
  final DateTime createdAt;
  final DateTime entryDate;
  final DiaryActivity activity;

  const Diary({
    required this.id,
    required this.userId,
    this.comment,
    this.note,
    required this.createdAt,
    required this.entryDate,
    required this.activity,
  });
}
