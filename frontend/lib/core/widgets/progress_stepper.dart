import 'package:flutter/material.dart';
import '../../app/design_tokens.dart';
import '../../app/theme.dart';

class MediKioskProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String label;

  const MediKioskProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingXL,
        vertical: DesignTokens.spacingMD,
      ),
      decoration: const BoxDecoration(
        color: DesignTokens.white,
        border: Border(
          bottom: BorderSide(
            color: DesignTokens.neutral200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: MediKioskTheme.bodyMedium.copyWith(
                  color: DesignTokens.neutral800,
                ),
              ),
              Text(
                'Step $currentStep of $totalSteps',
                style: MediKioskTheme.caption.copyWith(
                  color: DesignTokens.neutral500,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingSM),

          
          Row(
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep - 1;

              return Expanded(
                child: Row(
                  children: [
                    
                    Container(
                      width: isCurrent ? 14 : 10,
                      height: isCurrent ? 14 : 10,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? DesignTokens.primary500
                            : DesignTokens.neutral200,
                        shape: BoxShape.circle,
                        border: isCurrent
                            ? Border.all(
                                color: DesignTokens.primary700,
                                width: 2,
                              )
                            : null,
                      ),
                    ),
                    
                    if (index < totalSteps - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted
                              ? DesignTokens.primary500
                              : DesignTokens.neutral200,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}