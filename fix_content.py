import re

with open('lib/presentations/pages/dashboard/widgets/patient_dashboard_content.dart', 'r') as f:
    content = f.read()

content = content.replace('AppPalette.gray', 'AppPalette.medGray')
content = content.replace('AppTypography.bodyBody2', 'AppTypography.defaultBody2')
content = content.replace('GoalType.exercise.name', 'GoalType.activityWalk.name')
content = content.replace('GoalType.steps.name', 'GoalType.stepsWalking.name')
content = content.replace('GoalType.posture.name', 'GoalType.yogaMeditation.name')
content = content.replace('AppPalette.green', 'Colors.green')
content = content.replace('${exercises?.avgPercent.toInt() ?? 0}', '${(exercises?.avgPercent ?? 0).toInt()}')
content = content.replace('${steps?.avgPercent.toInt() ?? 0}', '${(steps?.avgPercent ?? 0).toInt()}')
content = content.replace('${posture?.avgPercent.toInt() ?? 0}', '${(posture?.avgPercent ?? 0).toInt()}')
content = content.replace('const SizedBox(height: 24),', 'SizedBox(height: 24),') # fix some const errors if any
content = content.replace('const DailyGoalsCard', 'DailyGoalsCard')

with open('lib/presentations/pages/dashboard/widgets/patient_dashboard_content.dart', 'w') as f:
    f.write(content)
