import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/core/widgets/bottom_nav_bar.dart';
import 'package:medikiosk/core/widgets/info_row.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';
import 'package:medikiosk/features/patient/providers/patient_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final patient = ref.watch(patientProvider);
    final l10n = AppLocalizations.of(context);

    final patientName = (patient?.name != null && patient!.name!.isNotEmpty) 
        ? patient.name! 
        : l10n.patientProfileHeading;
    final patientPhone = (patient?.phone != null && patient!.phone!.isNotEmpty) 
        ? patient.phone! 
        : (session.patientId != null ? 'ID: ${session.patientId}' : l10n.notLoggedIn);
    final abhaId = (patient?.abhaId != null && patient!.abhaId!.isNotEmpty)
        ? patient.abhaId!
        : l10n.abhaUnlinked;

    final String langDisplay;
    switch (session.language) {
      case 'hi':
        langDisplay = 'हिन्दी';
        break;
      case 'ta':
        langDisplay = 'தமிழ்';
        break;
      case 'bn':
        langDisplay = 'বাংলা';
        break;
      case 'te':
        langDisplay = 'తెలుగు';
        break;
      case 'mr':
        langDisplay = 'मराठी';
        break;
      default:
        langDisplay = 'English';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myProfileTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: DesignTokens.primary600,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: DesignTokens.spacingXL),

            
            CircleAvatar(
              radius: 40,
              backgroundColor: DesignTokens.primary100,
              child: Text(
                patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.primary700,
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spacingMD),
            Text(
              patientName,
              style: MediKioskTheme.headline3.copyWith(
                color: DesignTokens.neutral950,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXS),
            Text(
              patientPhone,
              style: MediKioskTheme.body.copyWith(
                color: DesignTokens.neutral500,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXS),
            Text(
              abhaId.contains(':') ? abhaId : 'ABHA ID: $abhaId',
              style: MediKioskTheme.caption.copyWith(
                color: DesignTokens.primary500,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXL),

            
            Card(
              margin: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingMD,
              ),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: l10n.personalInformation,
                  ),
                  InfoRow(
                    icon: Icons.emergency_rounded,
                    label: l10n.emergencyContact,
                  ),
                  InfoRow(
                    icon: Icons.favorite_border_rounded,
                    label: l10n.healthPreferences,
                  ),
                  InfoRow(
                    icon: Icons.language_rounded,
                    label: l10n.languagePreference,
                    trailing: langDisplay,
                  ),
                  InfoRow(
                    icon: Icons.security_rounded,
                    label: l10n.privacyAndConsent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXL),

            
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingMD,
              ),
              child: SizedBox(
                width: double.infinity,
                height: DesignTokens.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.logout_rounded, color: DesignTokens.critical500),
                  label: Text(
                    l10n.logout,
                    style: MediKioskTheme.bodyMedium.copyWith(
                      color: DesignTokens.critical500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: DesignTokens.critical500),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusButton),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXL),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        activeTab: NavTab.profile,
        onTabChanged: (tab) => _handleNav(context, tab),
      ),
    );
  }

  void _handleNav(BuildContext context, NavTab tab) {
    switch (tab) {
      case NavTab.home:
        context.go('/dashboard');
        break;
      case NavTab.token:
        context.go('/token');
        break;
      case NavTab.scan:
        context.go('/upload-documents');
        break;
      case NavTab.profile:
        break;
      case NavTab.more:
        context.go('/sidebar');
        break;
    }
  }
}