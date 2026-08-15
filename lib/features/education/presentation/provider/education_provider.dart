import 'package:app_doctor/core/providers/dio_provider.dart';
import 'package:app_doctor/features/education/data/datasources/exercise_remote_datasource.dart';
import 'package:app_doctor/features/education/data/repository/excercise_repository_impl.dart';
import 'package:app_doctor/features/education/domain/repository/exercise_repository.dart';
import 'package:app_doctor/features/education/domain/usecases/get_user_exercises.dart';
import 'package:app_doctor/features/education/domain/usecases/get_exercises.dart';
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
