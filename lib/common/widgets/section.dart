import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final Widget child;

  const SectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppInsets.card,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: AppCorners.r12,
        border: Border.all(color: context.border),
      ),
      child: child,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.s4),
                Text(
                  subtitle!,
                  style: context.bodySmall?.copyWith(
                    color: context.onSurface.withValues(alpha: 0.62),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.s8),
          trailing!,
        ],
      ],
    );
  }
}

class SectionLoadingState extends StatelessWidget {
  final String title;

  const SectionLoadingState({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: AppSpacing.s16),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class SectionErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const SectionErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: AppSpacing.s12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.s12),
          decoration: BoxDecoration(
            color: context.error.withValues(alpha: 0.08),
            border: Border.all(color: context.error.withValues(alpha: 0.24)),
            borderRadius: AppCorners.r10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: AppSize.iconSm,
                    color: context.error,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      message,
                      style: context.bodySmall?.copyWith(
                        color: context.onSurface.withValues(alpha: 0.78),
                      ),
                    ),
                  ),
                ],
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.s10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: AppSize.iconSm),
                    label: const Text('Retry'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
