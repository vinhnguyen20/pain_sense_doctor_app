import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';

class GoalActionButton extends StatelessWidget {
  final String label;
  final double width;
  final VoidCallback? onPressed;

  const GoalActionButton({
    super.key,
    required this.label,
    required this.width,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed == null
          ? AppPalette.medGray
          : AppPalette.secondaryBlue,
      borderRadius: AppCorners.r20,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppCorners.r20,
        child: SizedBox(
          width: width,
          height: 50,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.titleBig1.copyWith(
                color: AppPalette.white,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
