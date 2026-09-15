import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';

class ModeSelectionScreen extends ConsumerWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: DesignTokens.white,
      appBar: AppBar(
        backgroundColor: DesignTokens.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: DesignTokens.neutral800,
          ),
          onPressed: () => context.go('/role-selection'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingXL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DesignTokens.spacingMD),

              
              Text(
                l10n.howWouldYouLike,
                style: MediKioskTheme.headline2.copyWith(
                  color: DesignTokens.neutral950,
                  height: 1.2,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingXL),

              
              _ModeCard(
                icons: const [Icons.mic_rounded, Icons.touch_app_rounded],
                iconBg: DesignTokens.primary500,
                title: 'Voice & Text Input',
                subtitle: 'Talk to our AI assistant in your language or answer questions on screen',
                onTap: () {
                  ref.read(sessionProvider.notifier).setMode('voice');
                  context.go('/voice-conversation');
                },
              ),
              const SizedBox(height: DesignTokens.spacingXL),

              
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: DesignTokens.neutral400,
                    ),
                    const SizedBox(width: DesignTokens.spacingSM),
                    Text(
                      l10n.youCanSwitch,
                      style: MediKioskTheme.body.copyWith(
                        color: DesignTokens.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.spacingXL),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final List<IconData> icons;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icons,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
        side: const BorderSide(
          color: DesignTokens.primary500,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingLG),
          child: Row(
            children: [
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: iconBg.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusInput),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icons[0],
                      size: 22,
                      color: DesignTokens.accent500,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '/',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.neutral400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      icons[1],
                      size: 22,
                      color: DesignTokens.primary500,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.spacingMD),

              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: MediKioskTheme.headline3.copyWith(
                        color: DesignTokens.neutral950,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: MediKioskTheme.body.copyWith(
                        color: DesignTokens.neutral500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              
              const Icon(
                Icons.chevron_right_rounded,
                color: DesignTokens.primary500,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}