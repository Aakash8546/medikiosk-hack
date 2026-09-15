import 'package:flutter/material.dart';
import '../../app/design_tokens.dart';

class SecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const SecondaryButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: DesignTokens.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}