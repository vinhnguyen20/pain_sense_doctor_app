import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showNotification;
  final bool showBackButton;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onBackPressed;
  final String? leadingImage;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showNotification = false,
    this.showBackButton = false,
    this.onNotificationPressed,
    this.onBackPressed,
    this.leadingImage = 'assets/images/logo/ps_logo.jpg',
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.background,
      surfaceTintColor: context.background,
      toolbarHeight: 72,
      titleSpacing: showBackButton ? 0 : 16,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => context.pop(),
            )
          : null,
      automaticallyImplyLeading: showBackButton,
      title: Row(
        children: [
          if (leadingImage != null) ...[
            Image.asset(leadingImage!, height: 44),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.titleMedium,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: showNotification
          ? [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: onNotificationPressed ?? () {},
              ),
              const SizedBox(width: 16),
            ]
          : null,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(color: context.colors.outline, height: 2),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72.0);
}
