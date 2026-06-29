import 'package:app_doctor/common/widgets/custom_app_bar.dart';
import 'package:app_doctor/common/widgets/error_retry_view.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/core/network/errors/exception_handler.dart';
import 'package:app_doctor/core/utils/utils.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';
import 'package:app_doctor/features/tracking/presentation/provider/tracking_providers.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/adherence_metrics_card.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/ai_recommendation.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/lbp_score_card.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/relief_card.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/seven_7_day_trend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientDashboard extends ConsumerWidget {
  final Patient patient;

  const PatientDashboard({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(
      patientTrackingSummary7DaysProvider(patient.id),
    );
    final adherenceAsync = ref.watch(diaryAdherenceProvider(patient.id));
    final adherenceData = adherenceAsync.asData?.value;

    return Scaffold(
      backgroundColor: context.background,
      appBar: CustomAppBar(
        title: patient.fullName,
        subtitle: 'Low Back Pain Dashboard',
        showBackButton: true,
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorRetryView(
          message: ExceptionHandler.handle(error).message,
          onRetry: () =>
              ref.invalidate(patientTrackingSummary7DaysProvider(patient.id)),
        ),
        data: (items) {
          final avgLbpScore = items.isEmpty
              ? null
              : (items.map((e) => e.summary.lbpScore).reduce((a, b) => a + b) /
                        items.length)
                    .round();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(patientTrackingSummary7DaysProvider(patient.id));
              ref.invalidate(diaryAdherenceProvider(patient.id));
            },
            child: SingleChildScrollView(
              padding: context.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.s20,
                children: [
                  LbpScoreCard(
                    averageScore: avgLbpScore,
                    isAvg: true,
                    status: adherenceData?.status,
                    scoreColor: colorFromHex(adherenceData?.color),
                    lbpFormula: summaryAsync
                        .asData
                        ?.value
                        .firstOrNull
                        ?.summary
                        .lbpFormula,
                  ),
                  ReliefComponentsCard(adherenceData: adherenceData),

                  if (adherenceData != null)
                    AdherenceMetricsCard(adherenceData: adherenceData),

                  SevenDayTrendCard(items: items),
                  const AiRecommendationsSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
