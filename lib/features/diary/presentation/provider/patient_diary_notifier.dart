import 'package:app_doctor/core/constants/app_constants.dart';
import 'package:app_doctor/core/network/errors/exception_handler.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_entry.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'patient_diary_notifier.g.dart';

class PatientDiaryState {
  final List<PatientDiaryEntry> entries;
  final bool isLoading;
  final String? error;
  final String? nextCursor;
  final bool hasMore;

  const PatientDiaryState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
    this.nextCursor,
    this.hasMore = true,
  });

  PatientDiaryState copyWith({
    List<PatientDiaryEntry>? entries,
    bool? isLoading,
    String? error,
    String? nextCursor,
    bool? hasMore,
  }) {
    return PatientDiaryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

@riverpod
class PatientDiaryNotifier extends _$PatientDiaryNotifier {
  static const Duration _cacheTtl = Duration(seconds: 45);
  DateTime? _lastFetchedAt;
  String? _lastRequestedCursor;

  bool get _isCacheFresh {
    final lastFetchedAt = _lastFetchedAt;
    if (lastFetchedAt == null) return false;
    return DateTime.now().difference(lastFetchedAt) < _cacheTtl;
  }

  @override
  PatientDiaryState build(String patientId) {
    ref.keepAlive();
    fetchPatientDiaries(refresh: true);
    return const PatientDiaryState();
  }

  Future<void> fetchPatientDiaries({
    bool refresh = false,
    bool forceRefresh = false,
  }) async {
    if (state.isLoading) return;

    if (patientId.isEmpty) {
      state = const PatientDiaryState(
        entries: [],
        isLoading: false,
        error: 'Patient id is required to load diary.',
        hasMore: false,
      );
      return;
    }

    final currentCursor = refresh ? null : state.nextCursor;
    if (!refresh) {
      if (currentCursor == null || currentCursor.trim().isEmpty) {
        return;
      }

      if (_lastRequestedCursor == currentCursor && state.entries.isNotEmpty) {
        return;
      }
    }

    final isInitialPageFetch = refresh || state.nextCursor == null;
    if (!forceRefresh &&
        isInitialPageFetch &&
        state.entries.isNotEmpty &&
        _isCacheFresh) {
      return;
    }

    if (refresh) {
      state = const PatientDiaryState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await ref.read(getPatientDiariesUseCaseProvider)(
        cursor: currentCursor,
        limit: AppConstants.defaultPageSize,
        patientId: patientId,
      );

      if (response.isSuccess && response.data != null) {
        final paginated = response.data!;
        _lastFetchedAt = DateTime.now();
        _lastRequestedCursor = currentCursor;
        state = PatientDiaryState(
          entries: refresh
              ? paginated.items
              : [...state.entries, ...paginated.items],
          isLoading: false,
          error: null,
          nextCursor: paginated.nextCursor,
          hasMore: paginated.hasMore,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: ExceptionHandler.handle(error).message,
      );
    }
  }

  Future<void> refresh() =>
      fetchPatientDiaries(refresh: true, forceRefresh: true);

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await fetchPatientDiaries();
  }
}
