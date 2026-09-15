import 'package:flutter/material.dart';
import '../../app/design_tokens.dart';
import '../../app/theme.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool showChevron;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
    this.iconColor,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DesignTokens.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingMD,
            vertical: DesignTokens.spacingMD,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: DesignTokens.neutral200, width: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: iconColor ?? DesignTokens.primary500,
              ),
              const SizedBox(width: DesignTokens.spacingMD),
              Expanded(
                child: Text(
                  label,
                  style: MediKioskTheme.body.copyWith(
                    color: DesignTokens.neutral950,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: MediKioskTheme.body.copyWith(
                    color: DesignTokens.neutral500,
                  ),
                ),
              if (showChevron) ...[
                const SizedBox(width: DesignTokens.spacingSM),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: DesignTokens.neutral400,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}