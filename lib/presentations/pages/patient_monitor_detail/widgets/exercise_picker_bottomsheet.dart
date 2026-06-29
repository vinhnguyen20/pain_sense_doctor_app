import 'package:app_doctor/features/education/domain/entites/exercise.dart';
import 'package:app_doctor/features/education/presentation/provider/exercise_picker_notifier.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<Set<String>?> showExercisePickerSheet({
  required BuildContext context,
  required Set<String> initialSelected,
}) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ExercisePickerSheet(initialSelected: initialSelected),
  );
}

class ExercisePickerSheet extends ConsumerStatefulWidget {
  final Set<String> initialSelected;

  const ExercisePickerSheet({super.key, required this.initialSelected});

  @override
  ConsumerState<ExercisePickerSheet> createState() =>
      _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<ExercisePickerSheet> {
  late final Set<String> _selected;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelected);
    _scrollCtrl.addListener(_onScroll);
    Future.microtask(
      () => ref.read(exercisePickerProvider.notifier).ensureLoaded(),
    );
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.extentAfter < 200) {
      ref.read(exercisePickerProvider.notifier).loadMore();
    }
  }

  void _toggle(String id) => setState(() {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
  });

  void _confirm() => Navigator.of(context).pop(Set<String>.from(_selected));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    final pickerState = ref.watch(exercisePickerProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, __) => Column(
        children: [
          _DragHandle(),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assign Exercises',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_selected.length} selected',
                        style: TextStyle(
                          fontSize: 13,
                          color: _selected.isEmpty
                              ? cs.onSurface.withValues(alpha: 0.45)
                              : cs.primary,
                          fontWeight: _selected.isEmpty
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selected.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _selected.clear()),
                    child: Text(
                      'Clear all',
                      style: TextStyle(fontSize: 13, color: cs.error),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: switch (true) {
              _ when pickerState.isLoading => const Center(
                child: CircularProgressIndicator(),
              ),

              _
                  when pickerState.error != null &&
                      pickerState.exercises.isEmpty =>
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: cs.error, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        pickerState.error!,
                        style: TextStyle(color: cs.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () =>
                            ref.read(exercisePickerProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),

              _ => ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.only(bottom: 8),
                itemCount:
                    pickerState.exercises.length +
                    (pickerState.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (pickerState.isLoadingMore &&
                      index == pickerState.exercises.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  final ex = pickerState.exercises[index];
                  return _ExerciseTile(
                    exercise: ex,
                    isSelected: _selected.contains(ex.id),
                    onTap: () => _toggle(ex.id),
                  );
                },
              ),
            },
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + mq.viewInsets.bottom),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selected.isEmpty ? null : _confirm,
                child: Text(
                  _selected.isEmpty
                      ? 'Select at least one exercise'
                      : 'Confirm ${_selected.length} exercise${_selected.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExerciseTile({
    required this.exercise,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? cs.primary.withValues(alpha: 0.08)
            : context.commonColors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? cs.primary.withValues(alpha: 0.35)
              : context.commonColors.transparent,
          width: 1.2,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? cs.primary.withValues(alpha: 0.15)
                : cs.outline.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.fitness_center,
            size: 20,
            color: isSelected
                ? cs.primary
                : cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
        title: Text(
          exercise.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? cs.primary : cs.onSurface,
          ),
        ),
        subtitle: Text(
          '${exercise.durationSeconds / 60} min',
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
        trailing: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isSelected
              ? Icon(
                  Icons.check_circle_rounded,
                  color: cs.primary,
                  size: 22,
                  key: const ValueKey('checked'),
                )
              : Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: cs.outline.withValues(alpha: 0.5),
                  size: 22,
                  key: const ValueKey('unchecked'),
                ),
        ),
      ),
    );
  }
}
