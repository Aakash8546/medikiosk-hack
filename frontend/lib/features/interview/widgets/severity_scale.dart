import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SeverityScale extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const SeverityScale({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _labels = ['None', 'Mild', 'Moderate', 'Severe', 'Worst'];
  static const _colors = [
    AppColors.success500,
    Color(0xFF84CC16),
    AppColors.warning500,
    Color(0xFFF97316),
    AppColors.critical500,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final isSelected = value == i;
            return GestureDetector(
              onTap: () => onChanged(i),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected ? _colors[i] : AppColors.neutral100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? _colors[i] : AppColors.neutral300,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$i',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppColors.white : AppColors.neutral700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _labels[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? _colors[i] : AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}