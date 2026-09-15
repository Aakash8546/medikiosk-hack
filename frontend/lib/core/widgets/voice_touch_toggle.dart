import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum InputMode { voice, touch }

class VoiceTouchToggle extends StatelessWidget {
  final InputMode currentMode;
  final ValueChanged<InputMode> onChanged;

  const VoiceTouchToggle({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(InputMode.voice),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: currentMode == InputMode.voice
                      ? AppColors.primary500
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mic_rounded,
                      size: 18,
                      color: currentMode == InputMode.voice
                          ? AppColors.white
                          : AppColors.neutral500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Voice',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: currentMode == InputMode.voice
                            ? AppColors.white
                            : AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(InputMode.touch),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: currentMode == InputMode.touch
                      ? AppColors.primary500
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 18,
                      color: currentMode == InputMode.touch
                          ? AppColors.white
                          : AppColors.neutral500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Touch',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: currentMode == InputMode.touch
                            ? AppColors.white
                            : AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}