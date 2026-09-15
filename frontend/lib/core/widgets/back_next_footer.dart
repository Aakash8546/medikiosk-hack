import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/core/widgets/large_button.dart';
import 'package:medikiosk/core/widgets/large_button_secondary.dart';
import '../../app/design_tokens.dart';

class BackNextFooter extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? nextLabel;
  final bool showBack;

  const BackNextFooter({
    super.key,
    this.onBack,
    this.onNext,
    this.nextLabel,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spacingMD),
      child: Row(
        children: [
          if (showBack)
            Expanded(
              child: SecondaryButton(
                onPressed: onBack ?? () => context.go('/'),
                label: l10n.goBack,
              ),
            ),
          if (showBack) const SizedBox(width: DesignTokens.spacingMD),
          Expanded(
            child: PrimaryButton(
              onPressed: onNext,
              label: nextLabel ?? l10n.next,
            ),
          ),
        ],
      ),
    );
  }
}