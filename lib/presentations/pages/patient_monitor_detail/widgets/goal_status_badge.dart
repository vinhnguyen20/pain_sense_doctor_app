import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';

class GoalStatusBadge extends StatelessWidget {
  final GoalModel goal;

  const GoalStatusBadge({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final active = goal.patientConsent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? AppPalette.primaryBlue.withValues(alpha: 0.1)
            : context.goalColors.paused.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active
              ? AppPalette.primaryBlue.withValues(alpha: 0.4)
              : context.goalColors.paused.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle_outline : Icons.pending_outlined,
            size: 14,
            color: active ? AppPalette.primaryBlue : context.goalColors.paused,
          ),
          const SizedBox(width: 6),
          Text(
            active ? 'Active — Patient Consented' : 'Pending Consent',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active
                  ? AppPalette.primaryBlue
                  : context.goalColors.paused,
            ),
          ),
        ],
      ),
    );
  }
}

class GoalStatusDot extends StatefulWidget {
  final GoalFormMode mode;

  const GoalStatusDot({super.key, required this.mode});

  @override
  State<GoalStatusDot> createState() => _GoalStatusDotState();
}

class _GoalStatusDotState extends State<GoalStatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode != GoalFormMode.create) return const SizedBox.shrink();

    return Row(
      children: [
        FadeTransition(opacity: _anim, child: const _PulseDot()),
        const SizedBox(width: 4),
        Text(
          'Creating...',
          style: TextStyle(
            fontSize: 11,
            color: context.goalColors.paused,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.goalColors.paused,
      ),
    );
  }
}
