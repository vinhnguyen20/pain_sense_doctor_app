import 'package:app_doctor/core/constants/app_constants.dart';
import 'package:app_doctor/features/education/domain/entites/exercise.dart';
import 'package:app_doctor/features/education/presentation/provider/education_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'exercise_picker_notifier.g.dart';

const kPickerPageSize = AppConstants.defaultPageSize;

class ExercisePickerState {
  final List<Exercise> exercises;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String? nextCursor;

  const ExercisePickerState({
    this.exercises = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.nextCursor,
  });

  ExercisePickerState copyWith({
    List<Exercise>? exercises,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    String? nextCursor,
    bool clearError = false,
    bool clearCursor = false,
  }) {
    return ExercisePickerState(
      exercises: exercises ?? this.exercises,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : error ?? this.error,
      nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
    );
  }
}

@riverpod
class ExercisePickerNotifier extends _$ExercisePickerNotifier {
  @override
  ExercisePickerState build() {
    return const ExercisePickerState();
  }

  Future<void> ensureLoaded() async {
    if (state.isLoading || state.exercises.isNotEmpty) return;
    await fetchExercises();
  }

  Future<void> ensureIdsLoaded(List<String> requiredIds) async {
    if (requiredIds.isEmpty) return;

    if (state.exercises.isEmpty && !state.isLoading) {
      await fetchExercises();
    }

    final loadedIds = state.exercises.map((e) => e.id).toSet();
    final missing = requiredIds.where((id) => !loadedIds.contains(id)).toList();
    if (missing.isEmpty) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final repository = ref.read(exerciseRepositoryProvider);
      final results = await Future.wait(
        missing.map((id) => repository.getExerciseById(id)),
      );
      final fetched = results
          .where((r) => r.isSuccess && r.data != null)
          .map((r) => r.data!)
          .toList();
      state = state.copyWith(
        exercises: fetched.isNotEmpty
            ? [...state.exercises, ...fetched]
            : state.exercises,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> fetchExercises() async {
    state = const ExercisePickerState(isLoading: true);

    final response = await ref.read(getExercisesUseCaseProvider)(
      cursor: null,
      limit: kPickerPageSize,
    );

    if (response.isSuccess && response.data != null) {
      final paginated = response.data!;
      state = state.copyWith(
        exercises: paginated.items,
        isLoading: false,
        hasMore: paginated.hasMore,
        nextCursor: paginated.nextCursor,
        clearError: true,
      );
    } else {
      state = state.copyWith(isLoading: false, error: response.message);
    }
  }

  Future<void> loadMore() async {
    final s = state;
    if (!s.hasMore || s.isLoadingMore || s.isLoading) return;

    state = s.copyWith(isLoadingMore: true);

    final response = await ref.read(getExercisesUseCaseProvider)(
      cursor: s.nextCursor,
      limit: kPickerPageSize,
    );

    if (response.isSuccess && response.data != null) {
      final paginated = response.data!;
      state = state.copyWith(
        exercises: [...state.exercises, ...paginated.items],
        isLoadingMore: false,
        hasMore: paginated.hasMore,
        nextCursor: paginated.nextCursor,
      );
    } else {
      state = state.copyWith(isLoadingMore: false, error: response.message);
    }
  }

  Future<void> refresh() => fetchExercises();
}
