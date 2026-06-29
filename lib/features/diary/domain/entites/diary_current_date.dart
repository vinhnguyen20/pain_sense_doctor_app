class DiaryTask {
  final String label;
  final String status;

  const DiaryTask({required this.label, required this.status});
}

class DiaryCurrentDate {
  final int tasksDone;
  final int tasksTotal;
  final List<DiaryTask> tasks;

  const DiaryCurrentDate({
    required this.tasksDone,
    required this.tasksTotal,
    required this.tasks,
  });
}
