import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: DesignTokens.white,
      body: Column(
        children: [
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),

                  
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 0, top: 0),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: DesignTokens.primary100.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),

                  
                  _buildLogo(l10n),
                  const SizedBox(height: 32),

                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _buildWelcomeHeading(l10n),
                  ),
                  const SizedBox(height: 36),

                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _RoleCard(
                      icon: Icons.person_rounded,
                      iconColor: DesignTokens.primary700,
                      iconBgColor: DesignTokens.primary100,
                      title: l10n.iAmAPatient.toUpperCase(),
                      subtitle: l10n.startIntake,
                      onTap: () => context.go('/identify'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _RoleCard(
                      icon: Icons.medical_services_rounded,
                      iconColor: DesignTokens.primary700,
                      iconBgColor: DesignTokens.primary100,
                      title: l10n.doctorStaffLogin.toUpperCase(),
                      subtitle: l10n.accessPatientQueue,
                      onTap: () => context.go('/doctor-login'),
                    ),
                  ),
                  const SizedBox(height: 32),

                  
                  _buildHospitalIllustration(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          
          _buildSecurityBadge(l10n),
        ],
      ),
    );
  }

  Widget _buildLogo(AppLocalizations l10n) {
    return Column(
      children: [
        
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: DesignTokens.primary50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        Text(
          'MEDIKIOSK',
          style: MediKioskTheme.headline1.copyWith(
            color: DesignTokens.primary700,
            fontSize: 28,
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.smartIntake,
          style: MediKioskTheme.body.copyWith(
            color: DesignTokens.neutral500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeading(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: MediKioskTheme.headline1.copyWith(
              color: DesignTokens.neutral950,
              fontSize: 30,
              height: 1.2,
            ),
            children: [
              TextSpan(text: '${l10n.welcomeTitle} '),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.smartIntakeBetterCare,
          style: MediKioskTheme.body.copyWith(
            color: DesignTokens.neutral500,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityBadge(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 18,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0B6B6A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: DesignTokens.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_rounded,
                size: 18,
                color: DesignTokens.white,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                l10n.yourDataSecure,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: DesignTokens.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalIllustration() {
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    DesignTokens.primary100.withValues(alpha: 0.3),
                    DesignTokens.primary100.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                Container(
                  width: 35,
                  height: 50,
                  decoration: BoxDecoration(
                    color: DesignTokens.primary100.withValues(alpha: 0.8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      3,
                      (_) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          2,
                          (_) => Container(
                            width: 7,
                            height: 7,
                            color: DesignTokens.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                
                Container(
                  width: 70,
                  height: 75,
                  decoration: BoxDecoration(
                    color: DesignTokens.primary100.withValues(alpha: 0.9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: DesignTokens.primary500,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 9,
                          color: DesignTokens.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            3,
                            (_) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                3,
                                (_) => Container(
                                  width: 7,
                                  height: 7,
                                  color: DesignTokens.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                
                Container(
                  width: 40,
                  height: 45,
                  decoration: BoxDecoration(
                    color: DesignTokens.primary100.withValues(alpha: 0.7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      2,
                      (_) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          2,
                          (_) => Container(
                            width: 7,
                            height: 7,
                            color: DesignTokens.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Positioned(
            bottom: 8,
            left: 24,
            child: Icon(
              Icons.park_rounded,
              size: 24,
              color: DesignTokens.primary500.withValues(alpha: 0.4),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 24,
            child: Icon(
              Icons.park_rounded,
              size: 20,
              color: DesignTokens.primary500.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
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
          color: DesignTokens.neutral200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          child: Row(
            children: [
              
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusInput),
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 14),

              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: MediKioskTheme.headline3.copyWith(
                        color: DesignTokens.neutral950,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: MediKioskTheme.body.copyWith(
                        color: DesignTokens.neutral500,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: DesignTokens.primary50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: DesignTokens.primary700,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}