import 'package:app_doctor/core/utils/date_utils_helper.dart';
import 'package:flutter/material.dart';

class GoalDateRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool readOnly;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime?> onChanged;

  const GoalDateRow({
    super.key,
    required this.label,
    required this.date,
    required this.readOnly,
    this.firstDate,
    this.lastDate,
    required this.onChanged,
  });

  String _format(DateTime? d) => DateUtilsHelper.formatDateMDY(d);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: label),
        const SizedBox(height: 6),
        InkWell(
          onTap: readOnly ? null : () => _pickDate(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: readOnly ? cs.outline.withValues(alpha: 0.06) : cs.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _format(date),
                    style: TextStyle(fontSize: 14, color: cs.onSurface),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: cs.onSurface,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final effectiveFirstDate = firstDate ?? DateTime(2020);
    final effectiveLastDate = lastDate ?? DateTime(2035);
    final initial = date ?? DateTime.now();
    final boundedInitial = initial.isBefore(effectiveFirstDate)
        ? effectiveFirstDate
        : (initial.isAfter(effectiveLastDate) ? effectiveLastDate : initial);
    final picked = await showDatePicker(
      context: context,
      initialDate: boundedInitial,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      builder: (ctx, child) => Theme(data: Theme.of(ctx), child: child!),
    );
    onChanged(picked);
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: cs.onSurface.withValues(alpha: 0.7),
      ),
    );
  }
}
