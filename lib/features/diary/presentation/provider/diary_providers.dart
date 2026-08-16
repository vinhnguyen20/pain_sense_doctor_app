import 'package:app_doctor/core/providers/dio_provider.dart';
import 'package:app_doctor/features/diary/data/datasources/diary_remote_datasource.dart';
import 'package:app_doctor/features/diary/data/models/diary_adherence_model.dart';
import 'package:app_doctor/features/diary/data/models/patient_diary_activity_model.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';
import 'package:app_doctor/features/diary/data/repository/diary_repository_impl.dart';
import 'package:app_doctor/features/diary/domain/entites/diary_current_date.dart';
import 'package:app_doctor/features/diary/domain/repository/diary_repository.dart';
import 'package:app_doctor/features/diary/domain/usecases/delete_user_goal.dart';
import 'package:app_doctor/features/diary/domain/usecases/get_diaries_usecase.dart';
import 'package:app_doctor/features/diary/domain/usecases/get_diary_by_id_usecase.dart';
import 'package:app_doctor/features/diary/domain/usecases/get_patient_diaries_usecase.dart';
import 'package:app_doctor/features/diary/domain/usecases/get_user_goals_by_patient_id.dart';
import 'package:app_doctor/features/diary/domain/usecases/update_diary_usecase.dart';
import 'package:app_doctor/features/diary/domain/usecases/update_user_goal_usecase.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'diary_providers.g.dart';

@riverpod
DiaryRemoteDataSource diaryRemoteDataSource(Ref ref) {
  return DiaryRemoteDataSource(ref.watch(dioClientProvider));
}

// REPOSITORIES
@riverpod
DiaryRepository diaryRepository(Ref ref) {
  return DiaryRepositoryImpl(ref.read(diaryRemoteDataSourceProvider));
}

// USE CASES
@riverpod
GetDiariesUseCase getDiariesUseCase(Ref ref) {
  return GetDiariesUseCase(ref.read(diaryRepositoryProvider));
}

@riverpod
GetPatientDiariesUseCase getPatientDiariesUseCase(Ref ref) {
  return GetPatientDiariesUseCase(ref.read(diaryRepositoryProvider));
}

@riverpod
GetDiaryByIdUseCase getDiaryByIdUseCase(Ref ref) {
  return GetDiaryByIdUseCase(ref.read(diaryRepositoryProvider));
}

@riverpod
UpdateDiaryUseCase updateDiaryUseCase(Ref ref) {
  return UpdateDiaryUseCase(ref.read(diaryRepositoryProvider));
}

@riverpod
GetUserGoalsByPatientIdUseCase getUserGoalsByPatientIdUseCase(Ref ref) {
  return GetUserGoalsByPatientIdUseCase(ref.read(diaryRepositoryProvider));
}

final diaryAdherenceProvider =
    FutureProvider.family<PatientDiaryAdherenceModel?, String>((
      ref,
      patientId,
    ) async {
      final dataSource = ref.read(diaryRemoteDataSourceProvider);
      final response = await dataSource.getDiaryAdherenceRate(patientId);
      return response.isSuccess ? response.data : null;
    });

@riverpod
class PatientUserGoalsNotifier extends _$PatientUserGoalsNotifier {
  static const _defaultLimit = 20;

  String? _nextCursor;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  @override
  Future<List<UserGoalModel>> build(String patientId) async {
    _nextCursor = null;
    _hasMore = true;
    return _fetchPage(cursor: null);
  }

  Future<List<UserGoalModel>> _fetchPage({String? cursor}) async {
    final useCase = ref.read(getUserGoalsByPatientIdUseCaseProvider);
    final response = await useCase(
      patientId: patientId,
      cursor: cursor,
      limit: _defaultLimit,
    );

    if (response.isFailure) throw Exception(response.message);

    final paginated = response.data;
    if (paginated == null) return [];

    _nextCursor = paginated.nextCursor?.isEmpty == true
        ? null
        : paginated.nextCursor;
    _hasMore = _nextCursor != null;

    return paginated.items;
  }

  Future<void> fetchMore() async {
    if (!_hasMore || _isFetchingMore) return;
    final current = state.maybeWhen(data: (list) => list, orElse: () => null);
    if (current == null) return;

    _isFetchingMore = true;
    try {
      final more = await _fetchPage(cursor: _nextCursor);
      state = AsyncData([...current, ...more]);
    } catch (e, st) {
      debugPrint('fetchMore error: $e');
    } finally {
      _isFetchingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isFetchingMore => _isFetchingMore;
}

@riverpod
DeleteUserGoalUseCase deleteUserGoalUseCase(Ref ref) {
  return DeleteUserGoalUseCase(ref.read(diaryRepositoryProvider));
}

@riverpod
UpdateUserGoalUseCase updateUserGoalUseCase(Ref ref) {
  return UpdateUserGoalUseCase(ref.read(diaryRepositoryProvider));
}
