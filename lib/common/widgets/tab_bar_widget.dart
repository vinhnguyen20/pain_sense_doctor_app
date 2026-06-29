import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';

class TabBarWidget extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final Color? activeColor;
  final Color? inactiveColor;

  const TabBarWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? context.primary;
    final selectedIndex = categories.indexOf(selectedCategory);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(categories.length, (index) {
            final category = categories[index];
            final isSelected = selectedCategory == category;
            final inactive =
                inactiveColor ?? context.onSurface.withValues(alpha: 0.45);
            return Expanded(
              child: InkWell(
                onTap: () => onCategorySelected(category),
                splashColor: active.withValues(alpha: 0.1),
                highlightColor: active.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                  child: AnimatedDefaultTextStyle(
                    duration: AppDuration.fast,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? active : inactive,
                    ),
                    child: Text(category, textAlign: TextAlign.center),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / categories.length;
            return Stack(
              children: [
                Container(
                  height: AppSpacing.s2,
                  color: context.onSurface.withValues(alpha: 0.1),
                ),
                AnimatedPositioned(
                  duration: AppDuration.medium,
                  curve: Curves.easeInOut,
                  left: selectedIndex * tabWidth,
                  child: Container(
                    width: tabWidth,
                    height: AppSpacing.s2,
                    color: active,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
