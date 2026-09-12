import 'package:app_doctor/features/diary/domain/entites/user_goal_request.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';
import 'package:app_doctor/features/education/presentation/provider/education_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void applyPatientGoalUpdateToOverview(
  WidgetRef ref,
  UpdateUserGoalRequest request,
) {
  final patientId = request.patientId.trim();
  if (patientId.isEmpty) return;

  ref.read(patientUserGoalsProvider(patientId).notifier).applyUpdate(request);
  _refreshTodayExerciseGoals(ref, patientId);
}

void refreshPatientGoalOverview(WidgetRef ref, String patientId) {
  final normalizedPatientId = patientId.trim();
  if (normalizedPatientId.isEmpty) return;

  ref.invalidate(patientUserGoalsProvider(normalizedPatientId));
  _refreshTodayExerciseGoals(ref, normalizedPatientId);
}

void _refreshTodayExerciseGoals(WidgetRef ref, String patientId) {
  ref.invalidate(
    patientExercisesByPatientDateProvider((
      patientId: patientId,
      date: DateUtils.dateOnly(DateTime.now()),
    )),
  );
}
