import 'package:app_doctor/core/providers/dio_provider.dart';
import 'package:app_doctor/features/user/data/datasources/user_remote_datasource.dart';
import 'package:app_doctor/features/user/data/repository/user_repository_impl.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/domain/repository/user_repository.dart';
import 'package:app_doctor/features/user/domain/usecases/get_current_user_usecase.dart';
import 'package:app_doctor/features/user/domain/usecases/get_patient_by_id_usecase.dart';
import 'package:app_doctor/features/user/domain/usecases/get_patients_usecase.dart';
import 'package:app_doctor/features/user/domain/usecases/update_user_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_providers.g.dart';

// ─── SELECTED PATIENT ───
class SelectedPatientNotifier extends Notifier<Patient?> {
  @override
  Patient? build() => null;

  void setPatient(Patient? patient) {
    state = patient;
  }
}

final selectedPatientProvider =
    NotifierProvider<SelectedPatientNotifier, Patient?>(
      SelectedPatientNotifier.new,
    );

// ─── DATA SOURCES

@riverpod
UserRemoteDataSource userRemoteDataSource(Ref ref) {
  return UserRemoteDataSource(ref.watch(dioClientProvider));
}

// ─── REPOSITORIES

@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepositoryImpl(ref.read(userRemoteDataSourceProvider));
}

// ─── USE CASES ───

@riverpod
UpdateUserUseCase updateUserUseCase(Ref ref) {
  return UpdateUserUseCase(ref.read(userRepositoryProvider));
}

@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) {
  return GetCurrentUserUseCase(ref.read(userRepositoryProvider));
}

@riverpod
GetAllPatientsUseCase getAllPatientsUseCase(Ref ref) {
  return GetAllPatientsUseCase(ref.read(userRepositoryProvider));
}

@riverpod
GetPatientByIdUseCase getPatientByIdUseCase(Ref ref) {
  return GetPatientByIdUseCase(ref.read(userRepositoryProvider));
}

final patientDetailProvider = FutureProvider.autoDispose
    .family<Patient?, String>((ref, patientId) async {
      final normalizedId = patientId.trim();
      if (normalizedId.isEmpty) return null;

      // This provider is used when a patient dashboard is opened from a URL
      // after a browser reload. The per-patient endpoint can time out, while
      // the clinician's patient list is the source used throughout the app.
      // Resolve the patient from that list so every dashboard branch can be
      // restored from its `patientId` query parameter.
      String? cursor;
      final visitedCursors = <String>{};

      for (var page = 0; page < 20; page++) {
        final response = await ref
            .read(getAllPatientsUseCaseProvider)
            .call(cursor: cursor, limit: 100);
        if (!response.isSuccess || response.data == null) {
          throw Exception(response.message);
        }

        final patients = response.data!;
        for (final patient in patients.items) {
          if (patient.id.trim() == normalizedId) return patient;
        }

        final nextCursor = patients.nextCursor;
        if (nextCursor == null || !visitedCursors.add(nextCursor)) {
          return null;
        }
        cursor = nextCursor;
      }

      return null;
    });
