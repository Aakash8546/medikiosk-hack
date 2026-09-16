import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/confidence_badge.dart';

class EntityCard extends StatelessWidget {
  final String label;
  final String value;
  final double confidence;
  final bool isLow;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onVerify;

  const EntityCard({
    super.key,
    required this.label,
    required this.value,
    required this.confidence,
    this.isLow = false,
    this.onChanged,
    this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.neutral500)),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: isLow
                      ? TextFormField(
                          initialValue: value,
                          onChanged: onChanged,
                          style: TextStyle(color: AppColors.warning700),
                        )
                      : Text(
                          value,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral950,
                          ),
                        ),
                ),
                ConfidenceBadge(confidence: confidence),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onVerify,
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Correct'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}