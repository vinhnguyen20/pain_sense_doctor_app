import 'package:app_doctor/common/widgets/app_button.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? imageAsset;
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? loadingColor;
  final Color? borderColor;
  final bool isLoading;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.imageAsset,
    this.color,
    this.backgroundColor,
    this.foregroundColor,
    this.loadingColor,
    this.borderColor,
    this.isLoading = false,
    this.height = AppSize.buttonHeight,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final leadingWidget = _buildIcon();
    final hasCustomOutline =
        borderColor != null && borderColor != Colors.transparent;

    return AppButton(
      onPressed: onPressed,
      label: label,
      variant: hasCustomOutline
          ? AppButtonVariant.outline
          : AppButtonVariant.primary,
      isLoading: isLoading,
      leading: leadingWidget,
      height: height,
      padding: padding,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor ?? color ?? context.onPrimary,
      borderColor: borderColor,
      loadingColor: loadingColor,
    );
  }

  Widget? _buildIcon() {
    if (imageAsset != null) {
      return Image.asset(
        imageAsset!,
        height: AppSize.iconLg,
        width: AppSize.iconLg,
      );
    }

    if (icon != null) {
      return Icon(icon, size: 22);
    }

    return null;
  }
}
