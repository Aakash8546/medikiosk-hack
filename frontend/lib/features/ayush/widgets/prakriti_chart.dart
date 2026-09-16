import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PrakritiChart extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const PrakritiChart({
    super.key,
    this.selected,
    required this.onSelected,
  });

  static const _types = [
    ('Vata', 'वात', AppColors.accent500, Icons.air_rounded),
    ('Pitta', 'पित्त', AppColors.critical500, Icons.local_fire_department_rounded),
    ('Kapha', 'कफ', AppColors.success500, Icons.water_drop_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _types.map((t) {
        final (name, hindi, color, icon) = t;
        final isSelected = selected == name;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(name),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.1) : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? color : AppColors.neutral200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(hindi, style: const TextStyle(fontSize: 12, color: AppColors.neutral500)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}