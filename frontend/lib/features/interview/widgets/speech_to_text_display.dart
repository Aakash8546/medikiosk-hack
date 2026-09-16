import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SpeechToTextDisplay extends StatelessWidget {
  final String transcript;
  final bool isActive;

  const SpeechToTextDisplay({
    super.key,
    required this.transcript,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary50 : AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.primary500 : AppColors.neutral200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isActive ? Icons.mic : Icons.mic_off,
                size: 16,
                color: isActive ? AppColors.primary500 : AppColors.neutral500,
              ),
              const SizedBox(width: 8),
              Text(
                isActive ? 'Listening...' : 'Voice input',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? AppColors.primary700 : AppColors.neutral500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            transcript.isEmpty ? 'Speak now...' : transcript,
            style: TextStyle(
              fontSize: 16,
              color: transcript.isEmpty
                  ? AppColors.neutral400
                  : AppColors.neutral950,
            ),
          ),
        ],
      ),
    );
  }
}