import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/chats/presentation/provider/conversation_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SidebarNavigation extends ConsumerWidget {
  final StatefulNavigationShell? navigationShell;

  const SidebarNavigation({super.key, this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadMessagesCountProvider);

    return Container(
      width: AppLayout.sidebarWidth,
      color: AppPalette.backgroundLight,
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 132.392,
              height: 60,
              child: Image.asset(
                'assets/images/logo/logo_full_color_no_bg.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _NavItem(
                      icon: Icons.menu_rounded,
                      label: 'Overview',
                      isSelected:
                          navigationShell == null ||
                          navigationShell!.currentIndex == 0,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        navigationShell?.goBranch(0, initialLocation: true);
                      },
                    ),
                    const SizedBox(height: 20),
                    _NavItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Connect',
                      badgeCount: unreadCount,
                      isSelected: navigationShell?.currentIndex == 1,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        navigationShell?.goBranch(1, initialLocation: true);
                      },
                    ),
                    const SizedBox(height: 20),
                    _NavItem(
                      icon: Icons.accessibility_new_rounded,
                      label: 'Exercises',
                      isSelected: navigationShell?.currentIndex == 2,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        navigationShell?.goBranch(2, initialLocation: true);
                      },
                    ),
                    const SizedBox(height: 20),
                    _NavItem(
                      icon: Icons.flag_outlined,
                      label: 'Goals',
                      isSelected: navigationShell?.currentIndex == 3,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        navigationShell?.goBranch(3, initialLocation: true);
                      },
                    ),
                    const SizedBox(height: 20),
                    _NavItem(
                      icon: Icons.calendar_month_outlined,
                      label: 'Schedule',
                      isSelected: navigationShell?.currentIndex == 4,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        navigationShell?.goBranch(4, initialLocation: true);
                      },
                    ),
                    const SizedBox(height: 20),
                    _NavItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      isSelected: navigationShell?.currentIndex == 5,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        navigationShell?.goBranch(5, initialLocation: true);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int? badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppPalette.secondaryBlue : AppPalette.medGray;
    final hasBadge = badgeCount != null && badgeCount! > 0;

    return Material(
      color: isSelected ? AppPalette.white : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 192,
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(icon, size: 36, color: color),
                        if (hasBadge)
                          Positioned(
                            top: -2,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppPalette.white
                                      : AppPalette.backgroundLight,
                                  width: 1.5,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                badgeCount! > 99
                                    ? '99+'
                                    : badgeCount.toString(),
                                style: const TextStyle(
                                  color: AppPalette.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    style: AppTypography.buttonLarge.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
