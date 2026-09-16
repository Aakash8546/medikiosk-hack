import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SoapSectionCard extends StatelessWidget {
  final String title;
  final String content;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String? sourceTrace;

  const SoapSectionCard({
    super.key,
    required this.title,
    required this.content,
    required this.isExpanded,
    required this.onToggle,
    this.sourceTrace,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary900,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.neutral500,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.neutral700,
                    height: 1.5,
                  ),
                ),
                if (sourceTrace != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.info100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Source: $sourceTrace',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.info700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_rounded, size: 14),
                  label: const Text('Edit', style: TextStyle(fontSize: 13)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}