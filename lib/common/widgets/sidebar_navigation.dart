import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SidebarNavigation extends StatelessWidget {
  final StatefulNavigationShell? navigationShell;

  const SidebarNavigation({super.key, this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
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
                'assets/images/logo/ps_logo_full.png',
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
                navigationShell == null || navigationShell!.currentIndex == 0,
            onTap: () {
              navigationShell?.goBranch(0, initialLocation: false);
            },
          ),
          const SizedBox(height: 20),
          _NavItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Connect',
            isSelected: navigationShell?.currentIndex == 1,
            onTap: () {
              navigationShell?.goBranch(1, initialLocation: false);
            },
          ),
          const SizedBox(height: 20),
          _NavItem(
            icon: Icons.accessibility_new_rounded,
            label: 'Exercises',
            isSelected: navigationShell?.currentIndex == 2,
            onTap: () {
              navigationShell?.goBranch(2, initialLocation: false);
            },
          ),
          const SizedBox(height: 20),
          _NavItem(
            icon: Icons.flag_outlined,
            label: 'Goals',
            isSelected: navigationShell?.currentIndex == 3,
            onTap: () {
              navigationShell?.goBranch(3, initialLocation: false);
            },
          ),
          const SizedBox(height: 20),
          _NavItem(
            icon: Icons.calendar_month_outlined,
            label: 'Schedule',
            isSelected: navigationShell?.currentIndex == 4,
            onTap: () {
              navigationShell?.goBranch(4, initialLocation: false);
            },
          ),
          const SizedBox(height: 20),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isSelected: navigationShell?.currentIndex == 5,
            onTap: () {
              navigationShell?.goBranch(5, initialLocation: false);
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
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppPalette.secondaryBlue : AppPalette.medGray;

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
                  child: Center(child: Icon(icon, size: 36, color: color)),
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
