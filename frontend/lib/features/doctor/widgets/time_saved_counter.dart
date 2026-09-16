import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TimeSavedCounter extends StatelessWidget {
  final int minutesSaved;
  const TimeSavedCounter({super.key, required this.minutesSaved});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_rounded, color: AppColors.success700, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MediKiosk saved $minutesSaved minutes today',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success700,
                ),
              ),
              const Text(
                'AI pre-filled clinical notes',
                style: TextStyle(fontSize: 12, color: AppColors.success700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}