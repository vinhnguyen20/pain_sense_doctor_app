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
    return const AppointmentState();
  }

  Future<void> fetchAppointments({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = const AppointmentState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await ref.read(getAppointmentsUseCaseProvider)(
        cursor: refresh ? null : state.nextCursor,
        limit: AppConstants.defaultPageSize,
      );

      if (response.isSuccess && response.data != null) {
        final paginated = response.data!;
        final nextCursor = paginated.nextCursor?.trim();
        state = state.copyWith(
          appointments: refresh
              ? paginated.items
              : [...state.appointments, ...paginated.items],
          isLoading: false,
          nextCursor: nextCursor?.isEmpty == true ? null : nextCursor,
          hasMore: nextCursor != null && nextCursor.isNotEmpty,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> refresh() => fetchAppointments(refresh: true);

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await fetchAppointments();
  }

  Future<void> loadAllUpcoming() async {
    if (state.appointments.isEmpty) {
      await refresh();
    }

    final seenCursors = <String>{};
    var pageCount = 0;

    while (state.hasMore && pageCount < 50) {
      final cursor = state.nextCursor;
      if (cursor == null || cursor.isEmpty || !seenCursors.add(cursor)) return;
      await loadMore();
      pageCount++;
    }
  }

  void upsertAppointment(Appointment appointment) {
    final appointments = [...state.appointments];
    final index = appointments.indexWhere((item) => item.id == appointment.id);
    if (index >= 0) {
      appointments[index] = appointment;
    } else {
      appointments.add(appointment);
    }
    state = state.copyWith(
      appointments: appointments,
      isLoading: false,
      error: null,
    );
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
      final nextCursor = paginated.nextCursor?.trim();
      state = state.copyWith(
        appointments: refresh
            ? paginated.items
            : [...state.appointments, ...paginated.items],
        isLoading: false,
        nextCursor: nextCursor?.isEmpty == true ? null : nextCursor,
        hasMore: nextCursor != null && nextCursor.isNotEmpty,
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

  void upsertAppointment(Appointment appointment) {
    final appointments = [...state.appointments];
    final index = appointments.indexWhere((item) => item.id == appointment.id);
    if (index >= 0) {
      appointments[index] = appointment;
    } else {
      appointments.add(appointment);
    }
    state = state.copyWith(
      appointments: appointments,
      isLoading: false,
      error: null,
    );
  }
}
