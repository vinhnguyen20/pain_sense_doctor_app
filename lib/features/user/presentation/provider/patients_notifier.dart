import 'package:app_doctor/core/network/errors/exception_handler.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/presentation/provider/user_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'patients_notifier.g.dart';

const kPatientPageSize = 10;

class PatientsState {
  final List<Patient> patients;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String? nextCursor;
  final String searchQuery;

  const PatientsState({
    this.patients = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.nextCursor,
    this.searchQuery = '',
  });

  bool get isEmpty => patients.isEmpty && !isLoading;
  bool get isSearching => searchQuery.isNotEmpty;

  PatientsState copyWith({
    List<Patient>? patients,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    String? nextCursor,
    String? searchQuery,
    bool clearError = false,
  }) {
    return PatientsState(
      patients: patients ?? this.patients,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : error ?? this.error,
      nextCursor: nextCursor ?? this.nextCursor,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

@riverpod
class PatientsNotifier extends _$PatientsNotifier {
  static const Duration _cacheTtl = Duration(seconds: 45);
  DateTime? _lastFetchedAt;

  bool get _isCacheFresh {
    final lastFetchedAt = _lastFetchedAt;
    if (lastFetchedAt == null) return false;
    return DateTime.now().difference(lastFetchedAt) < _cacheTtl;
  }

  @override
  PatientsState build() {
    ref.keepAlive();
    return const PatientsState();
  }

  Future<void> _fetch({
    required String query,
    required bool reset,
    String? cursor,
  }) async {
    if (reset) {
      state = PatientsState(isLoading: true, searchQuery: query);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final response = await ref.read(getAllPatientsUseCaseProvider)(
        search: query,
        cursor: cursor,
        limit: kPatientPageSize,
      );

      if (response.isSuccess && response.data != null) {
        final paginated = response.data!;
        _lastFetchedAt = DateTime.now();
        state = state.copyWith(
          patients: reset
              ? paginated.items
              : [...state.patients, ...paginated.items],
          isLoading: false,
          isLoadingMore: false,
          hasMore: paginated.hasMore,
          nextCursor: paginated.nextCursor,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: response.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: ExceptionHandler.handle(e).message,
      );
    }
  }

  Future<void> fetchPatients({bool forceRefresh = false}) async {
    if (state.isLoading || state.isLoadingMore) return;
    if (!forceRefresh && state.patients.isNotEmpty && _isCacheFresh) return;

    await _fetch(query: '', reset: true);
  }

  Future<void> search(String query) async {
    await _fetch(query: query.trim(), reset: true);
  }

  Future<void> loadMore() async {
    final s = state;
    if (!s.hasMore || s.isLoadingMore || s.isLoading) return;

    await _fetch(query: s.searchQuery, reset: false, cursor: s.nextCursor);
  }

  Future<void> refresh() => _fetch(query: state.searchQuery, reset: true);
}
