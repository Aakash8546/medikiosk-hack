import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/app/providers/locale_provider.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/core/widgets/large_button.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';






class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  String _selectedLang = 'English';

  static const _languages = [
    ('English', 'en'),
    ('हिन्दी', 'hi'),
    ('தமிழ்', 'ta'),
    ('বাংলা', 'bn'),
    ('తెలుగు', 'te'),
    ('मराठी', 'mr'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: DesignTokens.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingXL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: DesignTokens.spacing2XL),

              
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: DesignTokens.primary50,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingMD),

              
              Text(
                l10n.welcomeTitle,
                textAlign: TextAlign.center,
                style: MediKioskTheme.headline2.copyWith(
                  color: DesignTokens.neutral950,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingXS),
              Text(
                l10n.welcomeSubtitle,
                style: MediKioskTheme.body.copyWith(
                  color: DesignTokens.primary500,
                ),
              ),
              const SizedBox(height: DesignTokens.spacing2XL),

              
              Text(
                l10n.languageSelect,
                style: MediKioskTheme.bodyMedium.copyWith(
                  color: DesignTokens.neutral800,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingLG),

              
              ...List.generate(_languages.length, (index) {
                final (label, langCode) = _languages[index];
                final isSelected = _selectedLang == label;
                return                GestureDetector(
                  onTap: () {
                    setState(() => _selectedLang = label);
                    
                    ref.read(localeProvider.notifier).setLanguageCode(langCode);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacingMD,
                      vertical: DesignTokens.spacingMD,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: DesignTokens.neutral200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: MediKioskTheme.body.copyWith(
                              color: DesignTokens.neutral950,
                            ),
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 22,
                          color: isSelected
                              ? DesignTokens.primary500
                              : DesignTokens.neutral400,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: DesignTokens.spacing2XL),

              
              PrimaryButton(
                onPressed: () {
                  
                  final entry = _languages.firstWhere(
                    (l) => l.$1 == _selectedLang,
                    orElse: () => ('English', 'en'),
                  );
                  
                  ref.read(localeProvider.notifier).setLanguageCode(entry.$2);
                  
                  ref.read(sessionProvider.notifier).updateLanguage(entry.$2);
                  context.go('/role-selection');
                },
                label: l10n.continueLabel,
              ),
              const SizedBox(height: DesignTokens.spacingXL),
            ],
          ),
        ),
      ),
    );
  }
}