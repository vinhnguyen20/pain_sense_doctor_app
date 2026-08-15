import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/diary/presentation/provider/patient_diary_notifier.dart';
import 'package:app_doctor/features/diary/presentation/widgets/diary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiaryTab extends ConsumerStatefulWidget {
  final String patientId;

  const DiaryTab({super.key, required this.patientId});

  @override
  ConsumerState<DiaryTab> createState() => _DiaryTabState();
}

class _DiaryTabState extends ConsumerState<DiaryTab> {
  final ScrollController _scrollController = ScrollController();
  bool _loadMoreQueued = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(patientDiaryProvider.notifier)
          .loadForPatient(widget.patientId),
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.maxScrollExtent <= 0) return;

    final state = ref.read(patientDiaryProvider);
    final shouldLoadMore =
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        state.hasMore &&
        !state.isLoading;

    if (shouldLoadMore && !_loadMoreQueued) {
      _loadMoreQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await ref.read(patientDiaryProvider.notifier).loadMore();
        if (mounted) {
          _loadMoreQueued = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.patientId.isEmpty) {
      return Center(
        child: Text(
          'Patient id is missing. Cannot load diary.',
          style: context.bodyMedium?.copyWith(color: context.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    final state = ref.watch(patientDiaryProvider);

    return RefreshIndicator(
      onRefresh: () => ref
          .read(patientDiaryProvider.notifier)
          .loadForPatient(widget.patientId),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (state.isLoading && state.entries.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.error != null && state.entries.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 44, color: context.error),
                    const SizedBox(height: 12),
                    Text(
                      state.error!,
                      style: context.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref
                          .read(patientDiaryProvider.notifier)
                          .loadForPatient(widget.patientId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (state.entries.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_note_outlined,
                        size: 40,
                        color: context.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No diary entries yet.',
                        style: context.bodyMedium?.copyWith(
                          color: context.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Builder(
              builder: (context) {
                final items = PatientDiaryGroup.buildSliverItems(
                  context,
                  state.entries,
                );
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == items.length) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!_loadMoreQueued) {
                          _loadMoreQueued = true;
                          ref
                              .read(patientDiaryProvider.notifier)
                              .loadMore()
                              .then((_) {
                                if (mounted) _loadMoreQueued = false;
                              });
                        }
                      });
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: state.isLoading
                              ? const CircularProgressIndicator()
                              : const SizedBox(height: 24),
                        ),
                      );
                    }
                    return items[index];
                  }, childCount: items.length + (state.hasMore ? 1 : 0)),
                );
              },
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
