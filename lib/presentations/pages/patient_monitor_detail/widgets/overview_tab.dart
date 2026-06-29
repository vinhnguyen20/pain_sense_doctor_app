import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/diary/data/models/diary_adherence_model.dart';
import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';
import 'package:app_doctor/features/tracking/presentation/provider/tracking_providers.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/lbp_score_card.dart';
import 'package:app_doctor/presentations/pages/dashboard/widgets/seven_7_day_trend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverviewTab extends ConsumerStatefulWidget {
  final Patient patient;
  const OverviewTab({super.key, required this.patient});

  @override
  ConsumerState<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends ConsumerState<OverviewTab> {
  String get _patientId => widget.patient.id.trim();

  @override
  Widget build(BuildContext context) {
    final trackingAsync = ref.watch(
      patientTrackingSummary7DaysProvider(_patientId),
    );
    final adherenceAsync = ref.watch(diaryAdherenceProvider(_patientId));
    final logs = widget.patient.trackingLogs;
    final lbpFormula =
        trackingAsync.asData?.value.firstOrNull?.summary.lbpFormula ?? '';
    final isTablet = context.isTablet;
    Future<void> handleRefresh() async {
      ref.invalidate(patientTrackingSummary7DaysProvider(_patientId));
      ref.invalidate(diaryAdherenceProvider(_patientId));
      try {
        await Future.wait([
          ref.read(patientTrackingSummary7DaysProvider(_patientId).future),
          ref.read(diaryAdherenceProvider(_patientId).future),
        ]);
      } catch (_) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }

    final topCards = isTablet
        ? IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: LbpScoreCard(
                    averageScore: logs?.lbpScoreValue,
                    status: logs?.status,
                    scoreColor: logs?.scoreColor,
                    lbpFormula: lbpFormula,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: adherenceAsync.when(
                    loading: () => const _LoadingCard(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (adherence) =>
                        _AdherenceOverallCard(overall: adherence?.overall),
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              LbpScoreCard(
                averageScore: logs?.lbpScoreValue,
                status: logs?.status,
                scoreColor: logs?.scoreColor,
                lbpFormula: lbpFormula,
              ),
              const SizedBox(height: AppSpacing.s12),
              adherenceAsync.when(
                loading: () => const _LoadingCard(),
                error: (_, __) => const SizedBox.shrink(),
                data: (adherence) =>
                    _AdherenceOverallCard(overall: adherence?.overall),
              ),
            ],
          );

    return RefreshIndicator(
      onRefresh: handleRefresh,

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: context.responsive(
            mobile: AppSpacing.s16,
            tablet: AppSpacing.s32,
          ),
          vertical: AppSpacing.s16,
        ),
        children: [
          topCards,
          const SizedBox(height: AppSpacing.s12),
          adherenceAsync.when(
            loading: () => const _LoadingCard(),
            error: (_, __) => const SizedBox.shrink(),
            data: (adherence) => adherence != null
                ? _ReliefTrackingCard(adherence: adherence)
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.s12),
          trackingAsync.when(
            loading: () => const _LoadingCard(),
            error: (e, _) => _ErrorCard(message: e.toString()),
            data: (items) => SevenDayTrendCard(items: items),
          ),
          const SizedBox(height: AppSpacing.s16),
        ],
      ),
    );
  }
}

class _AdherenceOverallCard extends StatelessWidget {
  final double? overall;

  const _AdherenceOverallCard({this.overall});

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      label: 'Adherence',
      value: '${(overall ?? 0).toInt()}%',
      unit: 'this week',
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.labelMedium?.copyWith(
              color: context.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: context.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: context.bodySmall?.copyWith(
              color: context.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReliefTrackingCard extends StatelessWidget {
  final PatientDiaryAdherenceModel adherence;

  const _ReliefTrackingCard({required this.adherence});

  Color _colorForIndex(int index, BuildContext context) {
    return switch (index % 3) {
      0 => context.dashboardColors.chartPrimary,
      1 => context.dashboardColors.chartSecondary,
      _ => context.dashboardColors.chartTertiary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final reliefItems = adherence.byType.entries.indexed.map((entry) {
      final (index, e) = entry;
      return _ReliefItem(
        label: GoalType.fromString(e.key).displayName,
        value: e.value.avgPercent,
        color: _colorForIndex(index, context),
      );
    }).toList();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Relief Tracking',
            style: context.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...reliefItems.map((item) => _ReliefRow(item: item)),
        ],
      ),
    );
  }
}

class _ReliefItem {
  final String label;
  final double value;
  final Color color;

  const _ReliefItem({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _ReliefRow extends StatelessWidget {
  final _ReliefItem item;

  const _ReliefRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.s12,
        horizontal: AppSpacing.s14,
      ),
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.onSurface.withValues(alpha: 0.04),
        borderRadius: AppCorners.r10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: context.labelMedium?.copyWith(
              color: context.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: item.value.toInt().toString(),
                  style: context.headlineSmall?.copyWith(
                    color: item.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: '/100',
                  style: context.titleMedium?.copyWith(
                    color: item.color.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(
            color: context.dashboardColors.chartPrimary,
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Failed to load tracking data:\n$message',
          style: context.bodySmall?.copyWith(
            color: context.dashboardColors.riskHigh,
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppInsets.card,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: AppCorners.r12,
        border: Border.all(color: context.border),
      ),
      child: child,
    );
  }
}
