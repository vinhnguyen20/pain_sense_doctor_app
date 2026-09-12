import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps compact API goal types to their matching icons', () {
    expect(GoalType.fromString('Steps'), GoalType.stepsWalking);
    expect(GoalType.fromString('Walk'), GoalType.activityWalk);
    expect(GoalType.fromString('Yoga'), GoalType.yogaMeditation);
    expect(GoalType.fromString('Steps/Walking'), GoalType.stepsWalking);
    expect(GoalType.fromString('Activity_Walk'), GoalType.activityWalk);
    expect(GoalType.fromString('Yoga/Meditation'), GoalType.yogaMeditation);

    expect(GoalType.stepsWalking.toApiString(), 'Steps/Walking');
    expect(GoalType.activityWalk.toApiString(), 'Activity_Walk');
    expect(GoalType.yogaMeditation.toApiString(), 'Yoga/Meditation');

    expect(GoalType.fromString('Steps').icon, Icons.directions_walk);
    expect(GoalType.fromString('Walk').icon, Icons.timer_outlined);
    expect(GoalType.fromString('Yoga').icon, Icons.self_improvement);
  });
}
