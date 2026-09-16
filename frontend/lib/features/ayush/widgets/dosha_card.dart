import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DoshaCard extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const DoshaCard({
    super.key,
    required this.label,
    this.selectedValue,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((opt) {
                final isSelected = selectedValue == opt;
                return GestureDetector(
                  onTap: () => onSelected(opt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary500 : AppColors.neutral100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? AppColors.white : AppColors.neutral700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}