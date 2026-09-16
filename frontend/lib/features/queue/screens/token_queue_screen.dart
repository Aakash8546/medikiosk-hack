import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/core/widgets/bottom_nav_bar.dart';
import 'package:medikiosk/core/widgets/kiosk_app_bar.dart';





class TokenQueueScreen extends ConsumerWidget {
  const TokenQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: KioskAppBar(
        title: 'Your Token',
        onBack: () => context.go('/ai-summary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            Text(
              'OPD – General Medicine',
              style: MediKioskTheme.body.copyWith(
                color: DesignTokens.neutral500,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXL),

            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignTokens.spacing2XL),
              decoration: BoxDecoration(
                color: DesignTokens.primary50,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLargeCard),
                border: Border.all(
                  color: DesignTokens.primary100,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'GM 256',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.primary900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingSM),
                  Text(
                    'Your Token Number',
                    style: MediKioskTheme.body.copyWith(
                      color: DesignTokens.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXL),

            
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacingLG),
              decoration: BoxDecoration(
                color: DesignTokens.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.neutral950.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Estimated Waiting Time',
                    style: MediKioskTheme.body.copyWith(
                      color: DesignTokens.neutral500,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingSM),
                  Text(
                    '25 – 30 mins',
                    style: MediKioskTheme.headline2.copyWith(
                      color: DesignTokens.neutral950,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXL),

            
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacingMD),
              decoration: BoxDecoration(
                color: DesignTokens.info100,
                borderRadius: BorderRadius.circular(DesignTokens.radiusInput),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: DesignTokens.info700,
                  ),
                  const SizedBox(width: DesignTokens.spacingSM),
                  Expanded(
                    child: Text(
                      'Please wait in the lounge area. You will be notified.',
                      style: MediKioskTheme.caption.copyWith(
                        color: DesignTokens.info700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacing2XL),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.queue_rounded),
                label: Text(
                  'View Token Status',
                  style: MediKioskTheme.bodyMedium.copyWith(
                    color: DesignTokens.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primary500,
                  minimumSize: const Size.fromHeight(DesignTokens.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusButton),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        activeTab: NavTab.token,
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
        break;
      case NavTab.scan:
        context.go('/upload-documents');
        break;
      case NavTab.profile:
        context.go('/profile');
        break;
      case NavTab.more:
        context.go('/sidebar');
        break;
    }
  }
}