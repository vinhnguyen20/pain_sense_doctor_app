import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.hintText,
  });

  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.s8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: context.bodyMedium?.copyWith(color: context.onSurface),
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: context.onSurface.withValues(alpha: 0.45),
                    size: AppSize.inputIcon,
                  )
                : null,
            hintText: hintText,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: AppCorners.r12,
              borderSide: BorderSide(color: context.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppCorners.r12,
              borderSide: BorderSide(color: context.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppCorners.r12,
              borderSide: BorderSide(
                color: context.primary,
                width: AppBorder.strong,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppCorners.r12,
              borderSide: BorderSide(color: context.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppCorners.r12,
              borderSide: BorderSide(
                color: context.error,
                width: AppBorder.strong,
              ),
            ),
            filled: true,
            fillColor: context.surface,
            contentPadding: AppInsets.inputContent,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
