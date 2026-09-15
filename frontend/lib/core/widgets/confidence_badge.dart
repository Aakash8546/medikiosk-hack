import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ConfidenceBadge extends StatelessWidget {
  final double confidence;
  final bool showLabel;

  const ConfidenceBadge({
    super.key,
    required this.confidence,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (confidence * 100).round();
    final isLow = confidence < 0.75;
    final isMedium = confidence >= 0.75 && confidence < 0.9;

    final color = isLow
        ? AppColors.warning500
        : isMedium
            ? AppColors.info500
            : AppColors.success500;

    final bgColor = isLow
        ? AppColors.warning100
        : isMedium
            ? AppColors.info100
            : AppColors.success100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLow ? Icons.warning_rounded : Icons.check_circle_rounded,
            size: 14,
            color: color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}