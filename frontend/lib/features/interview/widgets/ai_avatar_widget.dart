import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AiAvatarWidget extends StatelessWidget {
  final bool isSpeaking;
  const AiAvatarWidget({super.key, this.isSpeaking = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary100,
        boxShadow: isSpeaking
            ? [
                BoxShadow(
                  color: AppColors.primary500.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: const Icon(
        Icons.smart_toy_rounded,
        size: 40,
        color: AppColors.primary700,
      ),
    );
  }
}