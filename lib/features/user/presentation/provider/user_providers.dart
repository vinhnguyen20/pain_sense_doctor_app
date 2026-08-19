import 'package:app_doctor/core/providers/dio_provider.dart';
import 'package:app_doctor/features/user/data/datasources/user_remote_datasource.dart';
import 'package:app_doctor/features/user/data/repository/user_repository_impl.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/domain/repository/user_repository.dart';
import 'package:app_doctor/features/user/domain/usecases/get_current_user_usecase.dart';
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
