import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AudioPlayerWidget extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onToggle;
  final String? label;

  const AudioPlayerWidget({
    super.key,
    this.isPlaying = false,
    required this.onToggle,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isPlaying ? AppColors.primary100 : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary500),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPlaying ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
              color: AppColors.primary700,
              size: 24,
            ),
            if (label != null) ...[
              const SizedBox(width: 8),
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}