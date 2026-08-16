import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';

class ActivityTracker extends StatelessWidget {
  final List<double?> values;
  final List<String> labels;
  final double barWidth;
  final double maxBarHeight;
  final double dotSize;
  final double itemGap;
  final double labelGap;
  final Color? barColor;
  final Color? inactiveColor;
  final List<Color>? barColors;
  final bool expand;

  const ActivityTracker({
    super.key,
    required this.values,
    this.labels = const ['T', 'F', 'S', 'S', 'M', 'T', 'W'],
    this.barWidth = 16,
    this.maxBarHeight = 44,
    this.dotSize = 14,
    this.itemGap = 8,
    this.labelGap = 4,
    this.barColor,
    this.inactiveColor,
    this.barColors,
    this.expand = false,
  }) : assert(values.length == labels.length);

  @override
  Widget build(BuildContext context) {
    final warningColor = inactiveColor ?? AppPalette.surfaceLight;

    return SizedBox(
      height: maxBarHeight + labelGap + 18,
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: expand
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(values.length, (index) {
          final value = values[index];
          final isInactive = value == null || value <= 0;
          final activeColor = barColors != null && index < barColors!.length
              ? barColors![index]
              : (barColor ?? AppPalette.secondaryBlue);

          return Padding(
            padding: EdgeInsets.only(
              right: expand || index == values.length - 1 ? 0 : itemGap,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: barWidth,
                  height: maxBarHeight,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: isInactive
                        ? Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                              color: warningColor,
                              shape: BoxShape.circle,
                            ),
                          )
                        : Container(
                            width: barWidth,
                            height: value.clamp(0, maxBarHeight),
                            decoration: BoxDecoration(
                              color: activeColor,
                              borderRadius: BorderRadius.circular(49),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: labelGap),
                Text(
                  labels[index],
                  style: AppTypography.captionBody1.copyWith(
                    color: AppPalette.secondaryBlue,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
