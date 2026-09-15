import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/core/widgets/info_row.dart';
import 'package:medikiosk/core/widgets/kiosk_app_bar.dart';





class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: KioskAppBar(
        title: 'Help & Support',
        onBack: () => context.go('/home'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DesignTokens.spacingMD),
            Card(
              margin: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingMD,
              ),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.question_answer_rounded,
                    label: 'FAQs',
                    iconColor: DesignTokens.primary500,
                  ),
                  InfoRow(
                    icon: Icons.menu_book_rounded,
                    label: 'How to use this kiosk?',
                    iconColor: DesignTokens.info500,
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXL),

            
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingXL,
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingMD,
              ),
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spacingLG),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: DesignTokens.primary100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.headset_mic_rounded,
                        color: DesignTokens.primary700,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Support',
                            style: MediKioskTheme.bodyMedium.copyWith(
                              color: DesignTokens.neutral950,
                            ),
                          ),
                          Text(
                            '1800-XXX-XXXX',
                            style: MediKioskTheme.body.copyWith(
                              color: DesignTokens.primary500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spacingMD),

            Card(
              margin: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingMD,
              ),
              child: InfoRow(
                icon: Icons.report_problem_rounded,
                label: 'Report an Issue',
                iconColor: DesignTokens.warning500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}