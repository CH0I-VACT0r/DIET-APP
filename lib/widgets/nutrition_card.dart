import 'package:flutter/material.dart';

/// 영양소 정보 카드 위젯
class NutritionCard extends StatelessWidget {
  final String title;
  final double value;
  final double? target;
  final String unit;
  final Color? color;

  const NutritionCard({
    super.key,
    required this.title,
    required this.value,
    this.target,
    required this.unit,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = target != null && target! > 0 ? value / target! : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${value.toStringAsFixed(1)}$unit',
                  style: theme.textTheme.headlineMedium,
                ),
                if (target != null)
                  Text(
                    '/ ${target!.toStringAsFixed(1)}$unit',
                    style: theme.textTheme.bodyMedium,
                  ),
              ],
            ),
            if (target != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

