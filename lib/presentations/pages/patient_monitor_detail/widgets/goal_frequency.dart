import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart';
import 'package:flutter/material.dart';

class GoalFrequencyDropdown extends StatelessWidget {
  final GoalFrequency value;
  final bool readOnly;
  final ValueChanged<GoalFrequency> onChanged;

  const GoalFrequencyDropdown({
    super.key,
    required this.value,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return IgnorePointer(
      ignoring: readOnly,
      child: DropdownButtonFormField<GoalFrequency>(
        initialValue: value,
        style: TextStyle(fontSize: 14, color: cs.onSurface),
        dropdownColor: Theme.of(context).scaffoldBackgroundColor,
        decoration: InputDecoration(
          filled: true,
          fillColor: readOnly ? cs.outline.withValues(alpha: 0.06) : cs.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.5)),
          ),
        ),
        items: const [
          DropdownMenuItem(value: GoalFrequency.daily, child: Text('Daily')),
          DropdownMenuItem(value: GoalFrequency.weekly, child: Text('Weekly')),
          DropdownMenuItem(
            value: GoalFrequency.monthly,
            child: Text('Monthly'),
          ),
        ],
        onChanged: readOnly ? null : (v) => onChanged(v!),
      ),
    );
  }
}
