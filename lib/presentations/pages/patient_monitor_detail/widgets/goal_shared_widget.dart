import 'package:flutter/material.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';

class SectionCard extends StatelessWidget {
  final List<Widget> children;

  const SectionCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppInsets.card,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: AppCorners.r12,
        border: Border.all(color: context.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String label;

  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.onSurface.withValues(alpha: 0.7),
      ),
    );
  }
}

class GoalFormTextField extends StatelessWidget {
  final String? label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final bool readOnly;
  final bool numbersOnly;

  const GoalFormTextField({
    super.key,
    this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.readOnly = false,
    this.numbersOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: context.bodyMedium),
          const SizedBox(height: AppSpacing.s6),
        ],
        TextFormField(
          keyboardType: numbersOnly ? TextInputType.number : TextInputType.text,
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          style: TextStyle(fontSize: 14, color: context.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: context.onSurface.withValues(alpha: 0.38),
            ),
            filled: true,
            fillColor: readOnly
                ? context.border.withValues(alpha: 0.06)
                : context.surface,
            contentPadding: AppInsets.inputContent,
            border: _border(context),
            enabledBorder: _border(context),
            focusedBorder: _border(context, focused: true),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppCorners.r12,
              borderSide: BorderSide(
                color: context.border.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(BuildContext context, {bool focused = false}) =>
      OutlineInputBorder(
        borderRadius: AppCorners.r12,
        borderSide: BorderSide(
          color: focused
              ? context.primary
              : context.border.withValues(alpha: 0.5),
          width: focused ? AppBorder.strong : AppBorder.regular,
        ),
      );
}
