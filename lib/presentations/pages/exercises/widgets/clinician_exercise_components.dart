import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable exercise card used by the exercise library and routine picker.
class ClinicianExerciseCard extends StatelessWidget {
  final String name;
  final String asset;
  final String? subtitle;
  final VoidCallback onTap;
  final double width;
  final double height;

  const ClinicianExerciseCard({
    super.key,
    required this.name,
    required this.asset,
    required this.onTap,
    this.subtitle,
    this.width = 165,
    this.height = 179,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppPalette.secondaryBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SvgPicture.asset(
                'assets/images/icon/exercises/$asset',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              textAlign: TextAlign.center,
              style: AppTypography.defaultBody1.copyWith(color: Colors.white),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTypography.defaultBody2.copyWith(color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ClinicianCreateProgramCard extends StatelessWidget {
  final VoidCallback onTap;
  final double width;
  final double height;

  const ClinicianCreateProgramCard({
    super.key,
    required this.onTap,
    this.width = 165,
    this.height = 179,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 54, color: Color(0xFFC5C5C5)),
            SizedBox(height: 8),
            Text(
              'Create\nProgram',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFC5C5C5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClinicianRoutineTypeCard extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final double width;

  const ClinicianRoutineTypeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: width,
        height: 150,
        decoration: BoxDecoration(
          color: AppPalette.secondaryBlue,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 48, color: Colors.white),
            if (icon != null) const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.heading1.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class ClinicianExerciseCounter extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;

  const ClinicianExerciseCounter({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 115,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CounterIcon(icon: Icons.remove, onTap: () => onChanged?.call(-1)),
          Text('$value', style: AppTypography.titleBig2),
          _CounterIcon(icon: Icons.add, onTap: () => onChanged?.call(1)),
        ],
      ),
    );
  }
}

class ClinicianExerciseActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double gap;
  final bool isVertical;
  final double? iconSize;
  final TextStyle? textStyle;

  const ClinicianExerciseActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width,
    this.height = 54,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    this.borderRadius = 20,
    this.gap = 10,
    this.isVertical = false,
    this.iconSize,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle =
        textStyle ?? AppTypography.titleBig1.copyWith(color: Colors.white);

    Widget content;
    if (isVertical) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: iconSize ?? 30),
            SizedBox(height: gap),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: effectiveTextStyle,
            ),
          ),
        ],
      );
    } else {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: iconSize),
            SizedBox(width: gap),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: effectiveTextStyle,
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.secondaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
        ),
        child: content,
      ),
    );
  }
}

class ClinicianResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ClinicianResponsiveWrap({
    super.key,
    required this.children,
    this.spacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: spacing, runSpacing: 20, children: children);
  }
}

class _CounterIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Icon(icon, size: 14, color: AppPalette.secondaryBlue),
    );
  }
}
