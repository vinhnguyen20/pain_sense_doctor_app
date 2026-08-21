import 'package:app_doctor/common/widgets/clinician_header.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/education/domain/entites/exercise.dart';
import 'package:app_doctor/features/education/presentation/provider/education_provider.dart';
import 'package:app_doctor/presentations/pages/exercises/widgets/clinician_exercise_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Clinician exercise and routine flow.
///
/// The exercise library is loaded from `/exercises`; routine persistence stays
/// local until the backend provides a routine resource.
class ClinicianExercisesPage extends ConsumerStatefulWidget {
  const ClinicianExercisesPage({super.key});

  @override
  ConsumerState<ClinicianExercisesPage> createState() =>
      _ClinicianExercisesPageState();
}

enum _ExerciseView {
  overview,
  routineType,
  routinePicker,
  exerciseSetup,
  routineExercises,
  editExercise,
}

class _ClinicianExercisesPageState
    extends ConsumerState<ClinicianExercisesPage> {
  _ExerciseView _view = _ExerciseView.overview;
  String _routineName = '';
  String _selectedExercise = 'Shoulder Shrugs';
  int _reps = 5;
  int _sets = 3;
  List<_ExerciseData> _apiExercises = const [];
  bool _isLoadingExercises = true;
  String? _exerciseApiError;

  String get _displayRoutineName =>
      _routineName.trim().isEmpty ? 'My New Strength Routine' : _routineName;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadExercises);
  }

  Future<void> _loadExercises() async {
    final response = await ref
        .read(getExercisesUseCaseProvider)
        .call(limit: 100);
    if (!mounted) return;

    if (response.isSuccess && response.data != null) {
      setState(() {
        _apiExercises = response.data!.items.map(_toExerciseData).toList();
        _isLoadingExercises = false;
        _exerciseApiError = null;
      });
    } else {
      setState(() {
        _isLoadingExercises = false;
        _exerciseApiError = response.message;
      });
    }
  }

  _ExerciseData _toExerciseData(Exercise exercise) => _ExerciseData(
    exercise.title,
    _assetForExercise(exercise.title),
    exercise.description.trim().isEmpty ? null : exercise.description,
    id: exercise.id,
  );

  void _open(_ExerciseView view) => setState(() => _view = view);

  void _changeReps(int amount) {
    setState(() => _reps = (_reps + amount).clamp(1, 99));
  }

  void _changeSets(int amount) {
    setState(() => _sets = (_sets + amount).clamp(1, 99));
  }

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompactShell;
    return Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            compact ? AppSpacing.s16 : 30,
            compact ? AppSpacing.s16 : 30,
            compact ? AppSpacing.s16 : 30,
            AppSpacing.s32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ClinicianHeader(doctorName: 'Dr. Cameron Taylor'),
              if (!compact) ...[
                const SizedBox(height: 30),
                Text(
                  'Dr. Cameron Taylor',
                  style: AppTypography.titleBig1.copyWith(
                    color: AppPalette.secondaryBlue,
                  ),
                ),
                const SizedBox(height: 30),
              ] else
                const SizedBox(height: 16),
              DefaultTextStyle.merge(
                style: const TextStyle(color: AppPalette.secondaryBlue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoadingExercises)
                      const LinearProgressIndicator(minHeight: 2),
                    if (_exerciseApiError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Không tải được thư viện bài tập, đang hiển thị dữ liệu mẫu.',
                        style: AppTypography.denseBody1.copyWith(
                          color: AppPalette.medGray,
                        ),
                      ),
                    ],
                    _buildView(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildView(BuildContext context) {
    switch (_view) {
      case _ExerciseView.overview:
        return _OverviewView(
          exercises: _apiExercises,
          onCreateRoutine: () => _open(_ExerciseView.routineType),
          onEditExercise: (name) {
            _selectedExercise = name;
            _open(_ExerciseView.editExercise);
          },
        );
      case _ExerciseView.routineType:
        return _RoutineTypeView(
          routineName: _routineName,
          onNameChanged: (value) => _routineName = value,
          onBack: () => _open(_ExerciseView.overview),
          onTypeSelected: (_) => _open(_ExerciseView.routinePicker),
        );
      case _ExerciseView.routinePicker:
        return _RoutinePickerView(
          routineName: _displayRoutineName,
          exercises: _apiExercises,
          onBack: () => _open(_ExerciseView.routineType),
          onExerciseSelected: (name) {
            _selectedExercise = name;
            _open(_ExerciseView.exerciseSetup);
          },
        );
      case _ExerciseView.exerciseSetup:
        return _ExerciseSetupView(
          exercise: _selectedExercise,
          reps: _reps,
          sets: _sets,
          onBack: () => _open(_ExerciseView.routinePicker),
          onRepsChanged: _changeReps,
          onSetsChanged: _changeSets,
          onAdd: () => _open(_ExerciseView.routineExercises),
          addLabel: 'Add',
        );
      case _ExerciseView.routineExercises:
        return _RoutineExercisesView(
          routineName: _displayRoutineName,
          onBack: () => _open(_ExerciseView.routinePicker),
          onAddExercise: () => _open(_ExerciseView.routinePicker),
          onEdit: (name) {
            _selectedExercise = name;
            _open(_ExerciseView.exerciseSetup);
          },
        );
      case _ExerciseView.editExercise:
        return _ExerciseSetupView(
          exercise: _selectedExercise,
          reps: _reps,
          sets: _sets,
          onBack: () => _open(_ExerciseView.overview),
          onRepsChanged: _changeReps,
          onSetsChanged: _changeSets,
          onAdd: () {},
          addLabel: 'Record Reference Video',
          showVideoIcon: true,
        );
    }
  }
}

class _OverviewView extends StatelessWidget {
  final List<_ExerciseData> exercises;
  final VoidCallback onCreateRoutine;
  final ValueChanged<String> onEditExercise;

  const _OverviewView({
    required this.exercises,
    required this.onCreateRoutine,
    required this.onEditExercise,
  });

  @override
  Widget build(BuildContext context) {
    final library = exercises.isEmpty ? _fallbackExercises : exercises;
    final stretching = library.where(_isStretchingExercise).toList();
    final strength = library
        .where((item) => !_isStretchingExercise(item))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ExerciseSection(
          title: 'Stretching',
          exercises: stretching.isEmpty
              ? const [
                  _ExerciseData(
                    '30 Minute Program',
                    'side_stretch.svg',
                    'Your custom\nStretching Routine',
                  ),
                  _ExerciseData('Toe Touches', 'yoga.svg', null),
                ]
              : stretching,
          onTap: onEditExercise,
        ),
        const SizedBox(height: 30),
        _ExerciseSection(
          title: 'Strength Training',
          exercises: strength.isEmpty ? _fallbackExercises : strength,
          onTap: onEditExercise,
        ),
        const SizedBox(height: 30),
        _ExerciseSection(
          title: 'Your Programs',
          exercises: const [
            _ExerciseData(
              '30 Minute Program',
              'side_stretch.svg',
              'Your custom\nStretching Routine',
            ),
          ],
          onTap: onEditExercise,
          showCreateCard: true,
          onCreateRoutine: onCreateRoutine,
        ),
      ],
    );
  }
}

class _RoutineTypeView extends StatelessWidget {
  final String routineName;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onBack;
  final ValueChanged<String> onTypeSelected;

  const _RoutineTypeView({
    required this.routineName,
    required this.onNameChanged,
    required this.onBack,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _FlowColumn(
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 400,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 19),
                decoration: BoxDecoration(
                  color: AppPalette.backgroundLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: TextFormField(
                  initialValue: routineName,
                  onChanged: onNameChanged,
                  maxLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  style: AppTypography.titleBig1.copyWith(
                    color: AppPalette.black,
                    height: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Routine Name...',
                    hintStyle: AppTypography.titleBig1.copyWith(
                      color: AppPalette.medGray,
                      height: 1,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          const Text(
            'What kind of routine would you like to create?',
            style: AppTypography.defaultBody1,
          ),
          const SizedBox(height: 50),
          _ResponsiveWrap(
            spacing: context.isCompactShell ? 20 : 50,
            children: [
              _RoutineTypeCard(
                icon: Icons.fitness_center_rounded,
                label: 'Strength\nTraining',
                onTap: () => onTypeSelected('Strength'),
              ),
              _RoutineTypeCard(
                icon: Icons.self_improvement_rounded,
                label: 'Yoga',
                onTap: () => onTypeSelected('Yoga'),
              ),
              _RoutineTypeCard(
                icon: Icons.accessibility_new_rounded,
                label: 'Stretching',
                onTap: () => onTypeSelected('Stretching'),
              ),
              _RoutineTypeCard(
                icon: null,
                label: 'Custom',
                onTap: () => onTypeSelected('Custom'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutinePickerView extends StatelessWidget {
  final String routineName;
  final List<_ExerciseData> exercises;
  final VoidCallback onBack;
  final ValueChanged<String> onExerciseSelected;

  const _RoutinePickerView({
    required this.routineName,
    required this.exercises,
    required this.onBack,
    required this.onExerciseSelected,
  });

  @override
  Widget build(BuildContext context) {
    final library = exercises.isEmpty ? _fallbackExercises : exercises;
    return _FlowColumn(
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fitness_center_rounded,
                color: AppPalette.secondaryBlue,
              ),
              const SizedBox(width: 10),
              Text(routineName, style: AppTypography.titleBig1),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Assign Exercises to Your New Routine',
            style: AppTypography.defaultBody1,
          ),
          const SizedBox(height: 20),
          _ResponsiveWrap(
            children: library
                .map(
                  (exercise) => _ExerciseTile(
                    exercise: exercise,
                    onTap: () => onExerciseSelected(exercise.name),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ExerciseSetupView extends StatelessWidget {
  final String exercise;
  final int reps;
  final int sets;
  final VoidCallback onBack;
  final ValueChanged<int> onRepsChanged;
  final ValueChanged<int> onSetsChanged;
  final VoidCallback onAdd;
  final String addLabel;
  final bool showVideoIcon;

  const _ExerciseSetupView({
    required this.exercise,
    required this.reps,
    required this.sets,
    required this.onBack,
    required this.onRepsChanged,
    required this.onSetsChanged,
    required this.onAdd,
    required this.addLabel,
    this.showVideoIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final data = _exerciseData(exercise);
    return _FlowColumn(
      onBack: onBack,
      child: Center(
        child: SizedBox(
          width: 252,
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: SvgPicture.asset(
                  'assets/images/icon/exercises/${data.asset}',
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    AppPalette.secondaryBlue,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(exercise, style: AppTypography.heading1),
              const SizedBox(height: 42),
              _CounterRow(label: 'Reps', value: reps, onChanged: onRepsChanged),
              const SizedBox(height: 20),
              _CounterRow(label: 'Sets', value: sets, onChanged: onSetsChanged),
              const SizedBox(height: 48),
              _BlueButton(
                label: addLabel,
                icon: showVideoIcon ? Icons.videocam_outlined : Icons.add,
                onPressed: onAdd,
                width: showVideoIcon ? 251.11627197265625 : 252,
                height: showVideoIcon ? 134.01744079589844 : 94,
                padding: showVideoIcon
                    ? const EdgeInsets.all(20)
                    : const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                borderRadius: 20,
                gap: showVideoIcon ? 6.02 : 10,
                isVertical: showVideoIcon,
                iconSize: showVideoIcon ? 30 : null,
                textStyle: showVideoIcon
                    ? const TextStyle(
                        fontFamily: 'Cabin',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        height: 1.0,
                        letterSpacing: 0,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutineExercisesView extends StatelessWidget {
  final String routineName;
  final VoidCallback onBack;
  final VoidCallback onAddExercise;
  final ValueChanged<String> onEdit;

  const _RoutineExercisesView({
    required this.routineName,
    required this.onBack,
    required this.onAddExercise,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    const exercises = [
      _ExerciseData('Bridges', 'bridges.svg', null),
      _ExerciseData('Standing Squats', 'lunges.svg', null),
    ];
    return _FlowColumn(
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fitness_center_rounded,
                color: AppPalette.secondaryBlue,
              ),
              const SizedBox(width: 10),
              Text(routineName, style: AppTypography.titleBig1),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Assign Exercises to Your New Routine',
            style: AppTypography.defaultBody1,
          ),
          const SizedBox(height: 20),
          const _RoutineHeader(),
          ...exercises.map(
            (exercise) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _RoutineExerciseRow(
                exercise: exercise,
                onEdit: () => onEdit(exercise.name),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _BlueButton(
            label: 'Add Exercise',
            icon: Icons.add,
            onPressed: onAddExercise,
            height: 95,
          ),
        ],
      ),
    );
  }
}

class _FlowColumn extends StatelessWidget {
  final VoidCallback onBack;
  final Widget child;

  const _FlowColumn({required this.onBack, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: context.isCompactShell ? 0 : 50),
          child: child,
        ),
        const SizedBox(height: 55),
        IconButton(
          onPressed: onBack,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 36,
            color: AppPalette.secondaryBlue,
          ),
        ),
      ],
    );
  }
}

class _ExerciseSection extends StatelessWidget {
  final String title;
  final List<_ExerciseData> exercises;
  final ValueChanged<String> onTap;
  final bool showCreateCard;
  final VoidCallback? onCreateRoutine;

  const _ExerciseSection({
    required this.title,
    required this.exercises,
    required this.onTap,
    this.showCreateCard = false,
    this.onCreateRoutine,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.defaultBody1),
        const SizedBox(height: 10),
        const Divider(height: 1, color: AppPalette.secondaryBlue),
        const SizedBox(height: 22),
        _ResponsiveWrap(
          children: [
            ...exercises.map(
              (exercise) => _ExerciseTile(
                exercise: exercise,
                onTap: () => onTap(exercise.name),
              ),
            ),
            if (showCreateCard)
              _CreateProgramTile(onTap: onCreateRoutine ?? () {}),
          ],
        ),
      ],
    );
  }
}

class _ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const _ResponsiveWrap({required this.children, this.spacing = 20});

  @override
  Widget build(BuildContext context) {
    return ClinicianResponsiveWrap(spacing: spacing, children: children);
  }
}

class _ExerciseData {
  final String name;
  final String asset;
  final String? subtitle;
  final String? id;

  const _ExerciseData(this.name, this.asset, this.subtitle, {this.id});
}

const _fallbackExercises = [
  _ExerciseData('Bridges', 'bridges.svg', null),
  _ExerciseData('Front Plank', 'front_plank.svg', null),
  _ExerciseData('Standing Squats', 'lunges.svg', null),
  _ExerciseData('Standing Lunges', 'lunges.svg', null),
  _ExerciseData('Shoulder Shrugs', 'shoulder_shrugs.svg', null),
];

bool _isStretchingExercise(_ExerciseData exercise) {
  final value = '${exercise.name} ${exercise.subtitle ?? ''}'.toLowerCase();
  return value.contains('stretch') ||
      value.contains('yoga') ||
      value.contains('toe') ||
      value.contains('giãn');
}

String _assetForExercise(String title) {
  final value = title.toLowerCase();
  if (value.contains('yoga')) return 'yoga.svg';
  if (value.contains('shoulder') || value.contains('shrug')) {
    return 'shoulder_shrugs.svg';
  }
  if (value.contains('bridge')) return 'bridges.svg';
  if (value.contains('plank')) return 'front_plank.svg';
  if (value.contains('lunge') || value.contains('squat')) return 'lunges.svg';
  if (value.contains('run')) return 'running.svg';
  return 'side_stretch.svg';
}

class _ExerciseTile extends StatelessWidget {
  final _ExerciseData exercise;
  final VoidCallback onTap;

  const _ExerciseTile({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClinicianExerciseCard(
      name: exercise.name,
      asset: exercise.asset,
      subtitle: exercise.subtitle,
      onTap: onTap,
      width: context.isCompactShell ? 145 : 165,
      height: context.isCompactShell ? 165 : 179,
    );
  }
}

class _CreateProgramTile extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateProgramTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClinicianCreateProgramCard(
      onTap: onTap,
      width: context.isCompactShell ? 145 : 165,
      height: context.isCompactShell ? 165 : 179,
    );
  }
}

class _RoutineTypeCard extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;

  const _RoutineTypeCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClinicianRoutineTypeCard(
      icon: icon,
      label: label,
      onTap: onTap,
      width: context.isCompactShell ? 145 : 200,
    );
  }
}

/*
 * These local adapters keep the screen code readable while the public
 * implementations live in widgets/clinician_exercise_components.dart.
 */

class _RoutineHeader extends StatelessWidget {
  const _RoutineHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: Text('Exercise', style: AppTypography.titleBig2)),
          SizedBox(
            width: 155,
            child: Text('Reps', style: AppTypography.titleBig2),
          ),
          SizedBox(
            width: 155,
            child: Text('Sets', style: AppTypography.titleBig2),
          ),
          SizedBox(width: 270),
        ],
      ),
    );
  }
}

class _RoutineExerciseRow extends StatelessWidget {
  final _ExerciseData exercise;
  final VoidCallback onEdit;

  const _RoutineExerciseRow({required this.exercise, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.isCompactShell ? null : 94,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: context.isCompactShell
          ? Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _rowExerciseName(exercise)),
                    IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
                    const Icon(Icons.delete_outline),
                  ],
                ),
                const Row(
                  children: [
                    Text('Reps  5'),
                    SizedBox(width: 24),
                    Text('Sets  3'),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: _rowExerciseName(exercise)),
                const SizedBox(width: 155, child: _CounterPill(value: 5)),
                const SizedBox(width: 155, child: _CounterPill(value: 3)),
                SizedBox(
                  width: 270,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _BlueButton(label: 'Edit', onPressed: onEdit, width: 176),
                      const SizedBox(width: 25),
                      const Icon(
                        Icons.delete_outline,
                        color: AppPalette.secondaryBlue,
                        size: 36,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _rowExerciseName(_ExerciseData exercise) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          height: 44,
          child: SvgPicture.asset(
            'assets/images/icon/exercises/${exercise.asset}',
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              AppPalette.secondaryBlue,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(exercise.name, style: AppTypography.defaultBody1),
      ],
    );
  }
}

class _CounterRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _CounterRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.titleBig2),
        _CounterPill(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _CounterPill extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;

  const _CounterPill({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClinicianExerciseCounter(value: value, onChanged: onChanged);
  }
}

class _BlueButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double? gap;
  final bool isVertical;
  final double? iconSize;
  final TextStyle? textStyle;

  const _BlueButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.width,
    this.height = 54,
    this.padding,
    this.borderRadius,
    this.gap,
    this.isVertical = false,
    this.iconSize,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ClinicianExerciseActionButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      width: width,
      height: height,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      borderRadius: borderRadius ?? 20,
      gap: gap ?? 10,
      isVertical: isVertical,
      iconSize: iconSize,
      textStyle: textStyle,
    );
  }
}

_ExerciseData _exerciseData(String name) {
  return _fallbackExercises.firstWhere(
    (item) => item.name == name,
    orElse: () => _ExerciseData(name, _assetForExercise(name), null),
  );
}
