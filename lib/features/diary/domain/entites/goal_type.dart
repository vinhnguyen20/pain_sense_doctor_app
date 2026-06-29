import 'package:flutter/material.dart';

enum GoalType {
  stepsWalking,
  yogaMeditation,
  activityWalk,
  unknown;

  static GoalType fromString(String? value) => switch (value?.trim()) {
    'Steps/Walking' => GoalType.stepsWalking,
    'Yoga/Meditation' => GoalType.yogaMeditation,
    'Activity_Walk' => GoalType.activityWalk,
    _ => GoalType.unknown,
  };

  String toApiString() => switch (this) {
    GoalType.stepsWalking => 'Steps/Walking',
    GoalType.yogaMeditation => 'Yoga/Meditation',
    GoalType.activityWalk => 'Activity_Walk',
    GoalType.unknown => '',
  };

  String get displayName => switch (this) {
    GoalType.stepsWalking => 'Steps / Walking',
    GoalType.yogaMeditation => 'Yoga / Meditation',
    GoalType.activityWalk => 'Activity Walk',
    GoalType.unknown => 'Unknown',
  };

  IconData get icon => switch (this) {
    GoalType.stepsWalking => Icons.directions_walk,
    GoalType.yogaMeditation => Icons.self_improvement,
    GoalType.activityWalk => Icons.fitness_center,
    GoalType.unknown => Icons.help_outline,
  };
}
