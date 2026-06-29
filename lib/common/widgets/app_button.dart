import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, destructive }

enum AppButtonScale { small, medium, large }

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final AppButtonVariant variant;
  final AppButtonScale size;
  final bool isLoading;
  final bool expand;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final Color? loadingColor;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonScale.medium,
    this.isLoading = false,
    this.expand = true,
    this.height,
    this.padding,
    this.icon,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.loadingColor,
  });

  double get _height {
    if (height != null) return height!;
    return switch (size) {
      AppButtonScale.small => AppButtonSize.sm,
      AppButtonScale.medium => AppButtonSize.md,
      AppButtonScale.large => AppButtonSize.lg,
    };
  }

  EdgeInsetsGeometry get _padding {
    if (padding != null) return padding!;
    return switch (size) {
      AppButtonScale.small => AppButtonInset.sm,
      AppButtonScale.medium => AppButtonInset.md,
      AppButtonScale.large => AppButtonInset.lg,
    };
  }

  BorderRadius get _radius {
    return BorderRadius.circular(switch (size) {
      AppButtonScale.small => AppButtonRadius.sm,
      AppButtonScale.medium => AppButtonRadius.md,
      AppButtonScale.large => AppButtonRadius.lg,
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = _ButtonContent(
      label: label,
      loading: isLoading,
      icon: icon,
      leading: leading,
      trailing: trailing,
      loadingColor: loadingColor,
    );

    final widget = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: _filledStyle(context),
        child: child,
      ),
      AppButtonVariant.secondary => FilledButton.tonal(
        onPressed: isLoading ? null : onPressed,
        style: _filledTonalStyle(context),
        child: child,
      ),
      AppButtonVariant.outline => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: _outlinedStyle(context),
        child: child,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: isLoading ? null : onPressed,
        style: _textStyle(context),
        child: child,
      ),
      AppButtonVariant.destructive => FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: _destructiveStyle(context),
        child: child,
      ),
    };

    if (!expand) return widget;
    return SizedBox(width: double.infinity, height: _height, child: widget);
  }

  ButtonStyle _filledStyle(BuildContext context) {
    return FilledButton.styleFrom(
      minimumSize: Size(0, _height),
      padding: _padding,
      shape: RoundedRectangleBorder(borderRadius: _radius),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }

  ButtonStyle _filledTonalStyle(BuildContext context) {
    final cs = context.colors;
    return FilledButton.styleFrom(
      minimumSize: Size(0, _height),
      padding: _padding,
      shape: RoundedRectangleBorder(borderRadius: _radius),
      backgroundColor: backgroundColor ?? cs.secondary.withValues(alpha: 0.14),
      foregroundColor: foregroundColor ?? cs.onSurface,
    );
  }

  ButtonStyle _outlinedStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      minimumSize: Size(0, _height),
      padding: _padding,
      shape: RoundedRectangleBorder(borderRadius: _radius),
      side: borderColor == null
          ? null
          : BorderSide(color: borderColor!, width: AppBorder.regular),
      foregroundColor: foregroundColor,
    );
  }

  ButtonStyle _textStyle(BuildContext context) {
    return TextButton.styleFrom(
      minimumSize: Size(0, _height),
      padding: _padding,
      shape: RoundedRectangleBorder(borderRadius: _radius),
      foregroundColor: foregroundColor,
    );
  }

  ButtonStyle _destructiveStyle(BuildContext context) {
    final cs = context.colors;
    return FilledButton.styleFrom(
      minimumSize: Size(0, _height),
      padding: _padding,
      shape: RoundedRectangleBorder(borderRadius: _radius),
      backgroundColor: backgroundColor ?? cs.error,
      foregroundColor: foregroundColor ?? cs.onError,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final bool loading;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final Color? loadingColor;

  const _ButtonContent({
    required this.label,
    required this.loading,
    this.icon,
    this.leading,
    this.trailing,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasLeading = loading || leading != null || icon != null;
    final foreground = IconTheme.of(context).color ?? context.onPrimary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasLeading) ...[
          if (loading)
            SizedBox(
              width: AppSize.progressIndicator,
              height: AppSize.progressIndicator,
              child: CircularProgressIndicator(
                strokeWidth: AppSpacing.s2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  loadingColor ?? foreground,
                ),
              ),
            )
          else if (leading != null)
            leading!
          else
            Icon(icon, size: AppSize.iconSm),
          const SizedBox(width: AppSpacing.s8),
        ],
        Text(label),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.s8),
          trailing!,
        ],
      ],
    );
  }
}
