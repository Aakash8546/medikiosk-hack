import 'package:flutter/material.dart';
import '../../app/design_tokens.dart';
import '../../app/theme.dart';

class ChipGroup extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onSelected;
  final bool multiSelect;

  const ChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.multiSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DesignTokens.spacingSM,
      runSpacing: DesignTokens.spacingSM,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return GestureDetector(
          onTap: () => onSelected(option),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingMD,
              vertical: DesignTokens.spacingSM,
            ),
            decoration: BoxDecoration(
              color: isSelected ? DesignTokens.primary500 : DesignTokens.neutral100,
              borderRadius: BorderRadius.circular(DesignTokens.radiusInput),
              border: Border.all(
                color: isSelected ? DesignTokens.primary500 : DesignTokens.neutral200,
              ),
            ),
            child: Text(
              option,
              style: MediKioskTheme.bodyMedium.copyWith(
                color: isSelected ? DesignTokens.white : DesignTokens.neutral700,
                fontSize: 15,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}