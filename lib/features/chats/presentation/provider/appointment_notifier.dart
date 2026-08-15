import 'package:app_doctor/core/constants/app_constants.dart';
import 'package:app_doctor/features/chats/domain/entites/appointment.dart';
import 'package:app_doctor/features/chats/presentation/provider/chat_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'appointment_notifier.g.dart';

class AppointmentState {
  final List<Appointment> appointments;
  final bool isLoading;
  final String? error;
  final String? nextCursor;
  final bool hasMore;

  const AppointmentState({
    this.appointments = const [],
    this.isLoading = false,
    this.error,
    this.nextCursor,
    this.hasMore = true,
  });

  AppointmentState copyWith({
    List<Appointment>? appointments,
    bool? isLoading,
    String? error,
    String? nextCursor,
    bool? hasMore,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

@riverpod
class AppointmentNotifier extends _$AppointmentNotifier {
  @override
  AppointmentState build() {
    Future.microtask(fetchAppointments);
    return const AppointmentState();
  }

  Future<void> fetchAppointments({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = const AppointmentState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    final response = await ref.read(getAppointmentsUseCaseProvider)(
      cursor: refresh ? null : state.nextCursor,
      limit: AppConstants.defaultPageSize,
    );

    if (response.isSuccess && response.data != null) {
      final paginated = response.data!;
      state = state.copyWith(
        appointments: refresh
            ? paginated.items
            : [...state.appointments, ...paginated.items],
        isLoading: false,
        nextCursor: paginated.nextCursor,
        hasMore: paginated.nextCursor != null,
      );
    } else {
      state = state.copyWith(isLoading: false, error: response.message);
    }
  }

  Future<void> refresh() => fetchAppointments(refresh: true);

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await fetchAppointments();
  }
}

@riverpod
class AppointmentsByPatientNotifier extends _$AppointmentsByPatientNotifier {
  @override
  AppointmentState build(String patientId) {
    Future.microtask(fetchAppointments);
    return const AppointmentState();
  }

  Future<void> fetchAppointments({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = const AppointmentState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    final response = await ref.read(getAppointmentsByPatientIdUseCaseProvider)(
      patientId: patientId,
      cursor: refresh ? null : state.nextCursor,
      limit: AppConstants.defaultPageSize,
    );

    if (response.isSuccess && response.data != null) {
      final paginated = response.data!;
      state = state.copyWith(
        appointments: refresh
            ? paginated.items
            : [...state.appointments, ...paginated.items],
        isLoading: false,
        nextCursor: paginated.nextCursor,
        hasMore: paginated.nextCursor != null,
      );
    } else {
      state = state.copyWith(isLoading: false, error: response.message);
    }
  }

  Future<void> refresh() => fetchAppointments(refresh: true);

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await fetchAppointments();
  }
}
