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
  }) : assert(values.length == labels.length);

  @override
  Widget build(BuildContext context) {
    final activeColor = barColor ?? AppPalette.secondaryBlue;
    final warningColor = inactiveColor ?? AppPalette.yellow;

    return SizedBox(
      height: maxBarHeight + labelGap + 18,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(values.length, (index) {
          final value = values[index];
          final isInactive = value == null || value <= 0;

          return Padding(
            padding: EdgeInsets.only(
              right: index == values.length - 1 ? 0 : itemGap,
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
