import 'package:flutter/material.dart';
import '../../app/design_tokens.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final double height;
  final double fontSize;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.height = DesignTokens.buttonHeight,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: DesignTokens.neutral200,
          disabledForegroundColor: DesignTokens.neutral500,
          backgroundColor: DesignTokens.primary700,
          foregroundColor: DesignTokens.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: fontSize + 4),
              const SizedBox(width: DesignTokens.spacingSM),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}