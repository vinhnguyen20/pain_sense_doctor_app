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
  String? _currentPatientId;
  final Map<String, DateTime> _lastFetchedAtByPatient = {};
  final Map<String, String?> _lastRequestedCursorByPatient = {};

  bool _isCacheFreshForPatient(String patientId) {
    final lastFetchedAt = _lastFetchedAtByPatient[patientId];
    if (lastFetchedAt == null) return false;
    return DateTime.now().difference(lastFetchedAt) < _cacheTtl;
  }

  @override
  PatientDiaryState build() {
    ref.keepAlive();
    return const PatientDiaryState();
  }

  Future<void> fetchPatientDiaries({
    bool refresh = false,
    bool forceRefresh = false,
    String? patientId,
  }) async {
    if (state.isLoading) return;

    final normalizedPatientId = patientId?.trim();
    final hasPatientId =
        normalizedPatientId != null && normalizedPatientId.isNotEmpty;
    if (hasPatientId) {
      final patientChanged = normalizedPatientId != _currentPatientId;
      _currentPatientId = normalizedPatientId;
      if (patientChanged) {
        refresh = true;
      }
    }

    final effectivePatientId = _currentPatientId;
    if (effectivePatientId == null || effectivePatientId.isEmpty) {
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

      final lastRequestedCursor =
          _lastRequestedCursorByPatient[effectivePatientId];
      if (lastRequestedCursor == currentCursor && state.entries.isNotEmpty) {
        return;
      }
    }

    final isInitialPageFetch = refresh || state.nextCursor == null;
    if (!forceRefresh &&
        isInitialPageFetch &&
        state.entries.isNotEmpty &&
        _isCacheFreshForPatient(effectivePatientId)) {
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
        patientId: effectivePatientId,
      );

      if (response.isSuccess && response.data != null) {
        final paginated = response.data!;
        _lastFetchedAtByPatient[effectivePatientId] = DateTime.now();
        _lastRequestedCursorByPatient[effectivePatientId] = currentCursor;
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
        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
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

  Future<void> loadForPatient(String patientId) async {
    final normalizedPatientId = patientId.trim();
    if (normalizedPatientId.isEmpty) {
      state = const PatientDiaryState(
        entries: [],
        isLoading: false,
        error: 'Patient id is missing.',
        hasMore: false,
      );
      return;
    }

    final samePatient = _currentPatientId == normalizedPatientId;
    final hasUsableCache =
        samePatient &&
        state.entries.isNotEmpty &&
        _isCacheFreshForPatient(normalizedPatientId);
    if (hasUsableCache) return;

    await fetchPatientDiaries(
      refresh: true,
      patientId: normalizedPatientId,
      forceRefresh: false,
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await fetchPatientDiaries();
  }
}
