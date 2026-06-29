import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';

class AiRecommendationsSection extends StatelessWidget {
  static const _recommendations = [
    'Increase yoga sessions to 5 min daily',
    'Improve posture during work hours',
    'Reduce sitting time by 30 minutes',
  ];

  const AiRecommendationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Recommendations',
          style: context.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._recommendations.map(
          (rec) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: context.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(rec, style: context.bodyMedium)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
