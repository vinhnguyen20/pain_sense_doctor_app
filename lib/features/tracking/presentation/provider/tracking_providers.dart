import 'package:app_doctor/core/providers/dio_provider.dart';
import 'package:app_doctor/features/tracking/data/datasources/tracking_remote_datasource.dart';
import 'package:app_doctor/features/tracking/data/models/tracking_summary_item_model.dart';
import 'package:app_doctor/features/tracking/data/repository/tracking_repository_impl.dart';
import 'package:app_doctor/features/tracking/domain/repository/tracking_repository.dart';
import 'package:app_doctor/features/tracking/domain/usecases/get_patient_tracking_summary_7days_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tracking_providers.g.dart';

// DATA SOURCES

@riverpod
TrackingRemoteDataSource trackingRemoteDataSource(Ref ref) {
  return TrackingRemoteDataSource(ref.watch(dioClientProvider));
}

// REPOSITORIES

@riverpod
TrackingRepository trackingRepository(Ref ref) {
  return TrackingRepositoryImpl(ref.read(trackingRemoteDataSourceProvider));
}

// USE CASES

@riverpod
GetPatientTrackingSummary7DaysUseCase getPatientTrackingSummary7Days(Ref ref) {
  return GetPatientTrackingSummary7DaysUseCase(
    ref.read(trackingRepositoryProvider),
  );
}

final patientTrackingSummary7DaysProvider =
    FutureProvider.family<List<TrackingSummaryItemModel>, String>((
      ref,
      patientId,
    ) async {
      final result = await ref
          .read(getPatientTrackingSummary7DaysProvider)
          .call(patientId: patientId);

      if (result.isFailure) {
        throw result.message;
      }

      return result.data ?? [];
    }, retry: (retryCount, error) => null);
