import 'package:flutter/material.dart';
import '../../app/design_tokens.dart';
import '../../app/theme.dart';

class ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingMD,
        vertical: DesignTokens.spacingMD,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.white,
        border: Border(
          bottom: BorderSide(color: DesignTokens.neutral200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: DesignTokens.primary500),
          const SizedBox(width: DesignTokens.spacingMD),
          Expanded(
            child: Text(
              label,
              style: MediKioskTheme.body.copyWith(
                color: DesignTokens.neutral950,
              ),
            ),
          ),
          _Toggle(
            isYes: value,
            onTap: (isYes) => onChanged(isYes),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool isYes;
  final ValueChanged<bool> onTap;

  const _Toggle({required this.isYes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.neutral100,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onTap(true),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingMD,
                vertical: DesignTokens.spacingSM,
              ),
              decoration: BoxDecoration(
                color: isYes ? DesignTokens.primary500 : Colors.transparent,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
              ),
              child: Text(
                'Yes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isYes ? DesignTokens.white : DesignTokens.neutral700,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onTap(false),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingMD,
                vertical: DesignTokens.spacingSM,
              ),
              decoration: BoxDecoration(
                color: !isYes ? DesignTokens.primary500 : Colors.transparent,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
              ),
              child: Text(
                'No',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: !isYes ? DesignTokens.white : DesignTokens.neutral700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}