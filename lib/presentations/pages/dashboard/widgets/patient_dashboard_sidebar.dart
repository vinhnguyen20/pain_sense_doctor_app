import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientDashboardSidebar extends StatelessWidget {
  final Patient patient;

  const PatientDashboardSidebar({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      color: AppPalette.secondaryBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Image.asset(
              'assets/images/logo/ps_logo_full_white.png',
              height: 48,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _NavItem(
                    icon: Icons.menu_rounded,
                    label: 'Overview',
                    isSelected: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _NavItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Connect',
                    isSelected: false,
                    onTap: () {
                      // Uses existing route for Patient Monitor details if needed
                    },
                  ),
                  const SizedBox(height: 20),
                  _NavItem(
                    icon: Icons.accessibility_new_rounded,
                    label: 'Exercises',
                    isSelected: false,
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _NavItem(
                    icon: Icons.flag_outlined,
                    label: 'Goals',
                    isSelected: false,
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    isSelected: false,
                    onTap: () {},
                  ),
                  const Spacer(),
                  _NavItem(
                    icon: Icons.arrow_back_rounded,
                    label: 'Back',
                    isSelected: false,
                    onTap: () => context.pop(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
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
    final color = isSelected ? AppPalette.secondaryBlue : AppPalette.white;

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
                  width: 32,
                  height: 36,
                  child: Center(child: Icon(icon, size: 32, color: color)),
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
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
