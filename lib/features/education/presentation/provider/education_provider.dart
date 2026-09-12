import 'package:app_doctor/core/providers/dio_provider.dart';
import 'package:app_doctor/features/education/data/datasources/exercise_remote_datasource.dart';
import 'package:app_doctor/features/education/data/repository/excercise_repository_impl.dart';
import 'package:app_doctor/features/education/data/models/user_exercise_model.dart';
import 'package:app_doctor/features/education/domain/repository/exercise_repository.dart';
import 'package:app_doctor/features/education/domain/usecases/get_user_exercises.dart';
import 'package:app_doctor/features/education/domain/usecases/get_exercises.dart';
import 'package:app_doctor/core/utils/date_utils_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'education_provider.g.dart';

@riverpod
ExerciseRemoteDataSource exerciseRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return ExerciseRemoteDataSource(dio);
}

@riverpod
ExerciseRepository exerciseRepository(Ref ref) {
  final remoteDataSource = ref.watch(exerciseRemoteDataSourceProvider);
  return ExerciseRepositoryImpl(remoteDataSource);
}

// UseCase Providers

@riverpod
GetExercisesUseCase getExercisesUseCase(Ref ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return GetExercisesUseCase(repository);
}

@riverpod
GetUserExercisesUseCase getUserExercisesUseCase(Ref ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return GetUserExercisesUseCase(repository);
}

typedef PatientExerciseDateQuery = ({String patientId, DateTime date});

class TodayExerciseGoalItem {
  final String id;
  final String label;
  final bool isCompleted;

  const TodayExerciseGoalItem({
    required this.id,
    required this.label,
    required this.isCompleted,
  });
}

final patientExercisesByPatientDateProvider =
    FutureProvider.family<
      List<TodayExerciseGoalItem>,
      PatientExerciseDateQuery
    >((ref, query) async {
      final requestedDate = DateUtils.dateOnly(query.date);
      final response = await ref
          .watch(exerciseRemoteDataSourceProvider)
          .getUserExercisesByPatientDate(
            patientId: query.patientId,
            currentDate: DateUtilsHelper.formatDateApi(requestedDate),
            limit: 100,
          );

      if (response.isFailure) {
        throw Exception(response.message);
      }

      return (response.data?.items ?? const <UserExerciseModel>[]).map((item) {
        final schedules = item.scheduleConfig.where(
          (schedule) => DateUtils.isSameDay(
            schedule.exerciseDate.toLocal(),
            requestedDate,
          ),
        );
        final isCompleted = schedules.any(
          (schedule) =>
              schedule.sessionsCompleted > 0 ||
              schedule.slots.any((slot) => slot.isCompleted),
        );
        final title = item.dataExercise?.title.trim();

        return TodayExerciseGoalItem(
          id: item.id,
          label: title == null || title.isEmpty ? 'Exercise' : title,
          isCompleted: isCompleted,
        );
      }).toList();
    }, retry: (retryCount, error) => null);
