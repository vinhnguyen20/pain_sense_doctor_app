import 'dart:async';

import 'package:app_doctor/common/widgets/error_retry_view.dart';
import 'package:app_doctor/core/services/auth/token_service.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/presentation/provider/patients_notifier.dart';
import 'package:app_doctor/presentations/pages/home/widgets/patient_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(patientsProvider);
      if (!state.isLoading && state.patients.isEmpty) {
        ref.read(patientsProvider.notifier).fetchPatients();
      }
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(patientsProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(patientsProvider.notifier).search(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildPatientGrid(BuildContext context, List<Patient> patients) {
    if (!context.isTablet) {
      return Column(
        children: patients
            .map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                child: PatientCard(patient: p),
              ),
            )
            .toList(),
      );
    }
    return LayoutBuilder(
      builder: (_, constraints) {
        final cardWidth = (constraints.maxWidth - AppSpacing.s12) / 2;
        return Wrap(
          spacing: AppSpacing.s12,
          runSpacing: AppSpacing.s12,
          children: patients
              .map(
                (p) => SizedBox(
                  width: cardWidth,
                  child: PatientCard(patient: p),
                ),
              )
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientsState = ref.watch(patientsProvider);
    final tokenAsync = ref.watch(tokenServiceProvider);
    final token = tokenAsync.asData?.value;
    print('HomePage - Access Token: $token');

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Padding(
          padding: context.responsive(
            mobile: AppInsets.screenHorizontal,
            tablet: const EdgeInsets.symmetric(horizontal: AppSpacing.s32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo/ps_logo.jpg', height: 48),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Patient Monitor', style: context.titleMedium),
                        Text(
                          'Track low back pain for your patients',
                          style: context.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),

              _SearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: AppSpacing.s12),

              Expanded(
                child: patientsState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : patientsState.error != null
                    ? ErrorRetryView(
                        message: patientsState.error!,
                        onRetry: () =>
                            ref.read(patientsProvider.notifier).refresh(),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(patientsProvider.notifier).refresh(),
                        child: ListView(
                          controller: _scrollController,
                          children: [
                            _buildPatientGrid(context, patientsState.patients),

                            if (patientsState.isLoadingMore)
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.s16,
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),

                            if (!patientsState.hasMore &&
                                patientsState.patients.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.s16,
                                ),
                                child: Center(
                                  child: Text(
                                    'No more patients',
                                    style: context.bodyMedium?.copyWith(
                                      color: context.onSurface.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: AppSpacing.s16),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: context.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Search patients...',
        hintStyle: context.bodyMedium?.copyWith(
          color: context.onSurface.withValues(alpha: 0.4),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: context.onSurface.withValues(alpha: 0.4),
          size: AppSize.inputIcon,
        ),
      ),
    );
  }
}
