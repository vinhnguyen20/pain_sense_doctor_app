import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/presentation/provider/user_providers.dart';
import 'package:app_doctor/presentations/pages/patient_connect/widgets/patient_connect_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientExercisesPage extends ConsumerStatefulWidget {
  final Patient? patient;

  const PatientExercisesPage({super.key, this.patient});

  @override
  ConsumerState<PatientExercisesPage> createState() =>
      _PatientExercisesPageState();
}

class _PatientExercisesPageState extends ConsumerState<PatientExercisesPage> {
  final Set<String> _assignedExercises = {'30 Minute Yoga', 'Front Plank'};
  bool _showLibrary = false;

  @override
  void initState() {
    super.initState();
  }

  void _toggleExercise(String title) {
    setState(() {
      if (_assignedExercises.contains(title)) {
        _assignedExercises.remove(title);
      } else {
        _assignedExercises.add(title);
      }
    });
  }

  List<_ExerciseItem> _itemsForTitles(Iterable<String> titles) {
    return titles
        .map(
          (title) => _ExerciseItem(
            title: title,
            description: title == '30 Minute Yoga'
                ? 'A yoga program built\njust for you'
                : null,
            asset: _assetForExercise(title),
          ),
        )
        .toList();
  }

  String _assetForExercise(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('yoga')) return 'yoga.svg';
    if (normalized.contains('shoulder') || normalized.contains('shrug')) {
      return 'shoulder_shrugs.svg';
    }
    if (normalized.contains('bridge')) return 'bridges.svg';
    if (normalized.contains('plank')) return 'front_plank.svg';
    if (normalized.contains('stretch')) return 'side_stretch.svg';
    if (normalized.contains('lunge')) return 'lunges.svg';
    if (normalized.contains('run')) return 'running.svg';
    return 'side_stretch.svg';
  }

  List<_ExerciseItem> _libraryItems() {
    return _itemsForTitles(const [
      '30 Minute Yoga',
      'Shoulder Shrugs',
      'Bridges',
      'Front Plank',
      'Side Stretch',
      'Lunges',
      'Running',
    ]);
  }

  List<_ExerciseItem> _assignedItems() {
    return _itemsForTitles(_assignedExercises);
  }

  bool _isStretching(_ExerciseItem item) {
    final text = '${item.title} ${item.description ?? ''}'.toLowerCase();
    return text.contains('yoga') ||
        text.contains('shoulder') ||
        text.contains('stretch') ||
        text.contains('giãn cơ') ||
        text.contains('giãn') ||
        text.contains('cột sống');
  }

  bool _isStrengthTraining(_ExerciseItem item) {
    final text = '${item.title} ${item.description ?? ''}'.toLowerCase();
    return text.contains('bridge') ||
        text.contains('plank') ||
        text.contains('lunge') ||
        text.contains('squat') ||
        text.contains('strength') ||
        text.contains('sức mạnh');
  }

  @override
  Widget build(BuildContext context) {
    final selectedPatient =
        widget.patient ?? ref.watch(selectedPatientProvider);
    final patient = selectedPatient;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 600;
            final horizontalPadding = isCompact ? 16.0 : 30.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                isCompact ? 16 : 30,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PatientConnectHeader(patient: patient),
                      const SizedBox(height: 22),
                      _ExerciseTabs(
                        librarySelected: _showLibrary,
                        onChanged: (value) =>
                            setState(() => _showLibrary = value),
                      ),
                      const SizedBox(height: 22),
                      if (!_showLibrary) ...[
                        const _AddExerciseTile(),
                        const SizedBox(height: 24),
                        _ExerciseSection(
                          title: 'Stretching',
                          icon: Icons.accessibility_new_rounded,
                          exercises: _assignedItems()
                              .where(_isStretching)
                              .toList(),
                          assignedExercises: _assignedExercises,
                          onToggle: _toggleExercise,
                        ),
                        const SizedBox(height: 24),
                        _ExerciseSection(
                          title: 'Strength Training',
                          icon: Icons.fitness_center_rounded,
                          exercises: _assignedItems()
                              .where(_isStrengthTraining)
                              .toList(),
                          assignedExercises: _assignedExercises,
                          onToggle: _toggleExercise,
                        ),
                        const SizedBox(height: 24),
                        const _ExerciseSectionLabel(title: 'General'),
                        const SizedBox(height: 20),
                        const _EmptyExerciseMessage(),
                      ] else ...[
                        _ExerciseSection(
                          title: 'Exercise Library',
                          icon: Icons.menu_book_outlined,
                          exercises: _libraryItems(),
                          assignedExercises: _assignedExercises,
                          onToggle: _toggleExercise,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExerciseTabs extends StatelessWidget {
  final bool librarySelected;
  final ValueChanged<bool> onChanged;

  const _ExerciseTabs({required this.librarySelected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          height: 50,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: 'Assigned Exercises',
                  selected: !librarySelected,
                  onTap: () => onChanged(false),
                ),
              ),
              Expanded(
                child: _TabButton(
                  label: 'Exercise Library',
                  selected: librarySelected,
                  onTap: () => onChanged(true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppPalette.secondaryBlue : Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.titleBig1.copyWith(
              color: selected ? Colors.white : const Color(0xFFC5C5C5),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddExerciseTile extends StatelessWidget {
  const _AddExerciseTile();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 124,
      height: 134,
      child: Material(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 42, color: Color(0xFFC9C9C9)),
              const SizedBox(height: 2),
              Text(
                'Add\nExercise',
                textAlign: TextAlign.center,
                style: AppTypography.titleBig1.copyWith(
                  color: const Color(0xFFC9C9C9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_ExerciseItem> exercises;
  final Set<String> assignedExercises;
  final ValueChanged<String> onToggle;

  const _ExerciseSection({
    required this.title,
    required this.icon,
    required this.exercises,
    required this.assignedExercises,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ExerciseSectionLabel(title: title, icon: icon),
        const SizedBox(height: 20),
        if (exercises.isEmpty)
          const _EmptyExerciseMessage()
        else
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: exercises
                .map(
                  (exercise) => _ExerciseCard(
                    item: exercise,
                    selected: assignedExercises.contains(exercise.title),
                    onTap: () => onToggle(exercise.title),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _ExerciseSectionLabel extends StatelessWidget {
  final String title;
  final IconData? icon;

  const _ExerciseSectionLabel({required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 24, color: AppPalette.secondaryBlue),
              const SizedBox(width: 10),
            ],
            Text(
              title,
              style: AppTypography.titleBig1.copyWith(
                color: AppPalette.secondaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 1,
          color: AppPalette.secondaryBlue,
        ),
      ],
    );
  }
}

class _EmptyExerciseMessage extends StatelessWidget {
  const _EmptyExerciseMessage();

  @override
  Widget build(BuildContext context) {
    return Text(
      'No exercises assigned in this section.',
      style: AppTypography.denseBody1.copyWith(
        color: AppPalette.secondaryBlue.withValues(alpha: .7),
      ),
    );
  }
}

class _ExerciseItem {
  final String title;
  final String? description;
  final String asset;

  const _ExerciseItem({
    required this.title,
    required this.asset,
    this.description,
  });
}

class _ExerciseCard extends StatelessWidget {
  final _ExerciseItem item;
  final bool selected;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      height: 178,
      child: Material(
        color: AppPalette.secondaryBlue,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 70,
                      child: SvgPicture.asset(
                        'assets/images/icon/exercises/${item.asset}',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.defaultBody1.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    if (item.description != null) ...[
                      Text(
                        item.description!,
                        textAlign: TextAlign.center,
                        style: AppTypography.denseBody1.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 20,
                right: 14,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF18588C)
                        : const Color(0xFF18588C).withValues(alpha: .75),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
