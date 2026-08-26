import 'package:app_doctor/core/providers/dio_provider.dart';
import 'package:app_doctor/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app_doctor/features/auth/data/repository/auth_repository_impl.dart';
import 'package:app_doctor/features/auth/domain/repository/auth_repository.dart';
import 'package:app_doctor/features/auth/domain/usecases/sign_in_with_email_password_usecase.dart';
import 'package:app_doctor/features/auth/domain/usecases/register_patient_usecase.dart';
import 'package:app_doctor/features/user/domain/usecases/get_current_user_usecase.dart';
import 'package:app_doctor/features/user/presentation/provider/user_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

// DATA SOURCES

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSource(client: ref.read(dioClientProvider));
}

// REPOSITORIES

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider));
}

// USE CASES

@riverpod
RegisterPatientUseCase registerPatientUseCase(Ref ref) {
  return RegisterPatientUseCase(ref.read(authRepositoryProvider));
}

@riverpod
SignInWithEmailPasswordUseCase signInWithEmailPasswordUseCase(Ref ref) {
  return SignInWithEmailPasswordUseCase(ref.read(authRepositoryProvider));
}

@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) {
  return GetCurrentUserUseCase(ref.read(userRepositoryProvider));
}
