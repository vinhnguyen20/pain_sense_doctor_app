import 'package:flutter/material.dart';

enum GoalType {
  stepsWalking,
  yogaMeditation,
  activityWalk,
  unknown;

  static GoalType fromString(String? value) =>
      switch (value?.trim().toLowerCase()) {
        'steps' || 'steps/walking' || 'walking' => GoalType.stepsWalking,
        'yoga' || 'yoga/meditation' || 'meditation' => GoalType.yogaMeditation,
        'walk' ||
        'activity_walk' ||
        'activity walk' ||
        'walking time' => GoalType.activityWalk,
        _ => GoalType.unknown,
      };

  String toApiString() => switch (this) {
    GoalType.stepsWalking => 'Steps',
    GoalType.yogaMeditation => 'Yoga',
    GoalType.activityWalk => 'Walk',
    GoalType.unknown => '',
  };

  String get displayName => switch (this) {
    GoalType.stepsWalking => 'Daily Steps',
    GoalType.yogaMeditation => 'Yoga',
    GoalType.activityWalk => 'Walking Time',
    GoalType.unknown => 'Unknown',
  };

  IconData get icon => switch (this) {
    GoalType.stepsWalking => Icons.directions_walk,
    GoalType.yogaMeditation => Icons.self_improvement,
    GoalType.activityWalk => Icons.timer_outlined,
    GoalType.unknown => Icons.help_outline,
  };
}
