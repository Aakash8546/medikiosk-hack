import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/core/widgets/kiosk_app_bar.dart';
import 'package:medikiosk/core/widgets/large_button.dart';
import 'package:medikiosk/core/widgets/large_button_secondary.dart';
import 'package:medikiosk/features/documents/providers/document_provider.dart';
import 'package:medikiosk/features/interview/providers/interview_provider.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';

class ReviewConfirmScreen extends ConsumerWidget {
  const ReviewConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    
    
    final session = ref.watch(sessionProvider);
    final interview = ref.watch(interviewProvider);
    final documents = ref.watch(documentProvider);
    final history = interview.structuredHistory ?? const {};

    bool filled(String key) {
      final v = history[key];
      if (v == null) return false;
      if (v is String) return v.trim().isNotEmpty;
      if (v is Iterable) return v.isNotEmpty;
      if (v is Map) return v.isNotEmpty;
      return true;
    }

    final isAyush = session.sessionType?.toUpperCase() == 'AYUSH' ||
        session.mode == 'ayush';
    return Scaffold(
      appBar: KioskAppBar(
        title: 'Review & Confirm',
        onBack: () => context.go('/extracted-data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please review your information',
              style: MediKioskTheme.bodyMedium.copyWith(
                color: DesignTokens.neutral700,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXL),

            _CheckItem(
              icon: Icons.person_rounded,
              label: 'Personal Information',
              isComplete: session.patientId != null && session.patientId!.isNotEmpty,
            
            ),
            _CheckItem(
              icon: Icons.sick_rounded,
              label: 'Presenting Complaints',
              isComplete: session.patientId != null && session.patientId!.isNotEmpty,
             
            ),
            _CheckItem(
              icon: Icons.history_rounded,
              label: 'Past History',
              isComplete: session.patientId != null && session.patientId!.isNotEmpty,
             
            ),
            if (isAyush)
              _CheckItem(
                icon: Icons.spa_rounded,
                label: 'Ayurvedic Assessment',
                isComplete: session.patientId != null && session.patientId!.isNotEmpty,
               
              ),
            _CheckItem(
              icon: Icons.fitness_center_rounded,
              label: 'Lifestyle & Habits',
              isComplete: session.patientId != null && session.patientId!.isNotEmpty,
             
            ),
            _CheckItem(
              icon: Icons.upload_file_rounded,
              label: 'Uploaded Documents',
              isComplete: session.patientId != null && session.patientId!.isNotEmpty,
            
            ),

            const SizedBox(height: DesignTokens.spacingXL),
            Text(
              'Please confirm that the above information is correct.',
              style: MediKioskTheme.body.copyWith(
                color: DesignTokens.neutral500,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing2XL),

            
            
            
            
            
            PrimaryButton(
              onPressed: () => context.go('/ai-summary'),
              label: 'Review AI Summary',
              icon: Icons.auto_awesome_rounded,
            ),
            const SizedBox(height: DesignTokens.spacingMD),
            SecondaryButton(
              onPressed: () => context.go('/submit'),
              label: 'Confirm & Submit',
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  
  
  final bool isComplete;

  const _CheckItem({
    required this.icon,
    required this.label,
    this.isComplete = false,
  }) : onTap = null;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusInput),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingMD),
        child: Row(
          children: [
            Icon(icon, color: DesignTokens.primary600, size: 26),
            const SizedBox(width: DesignTokens.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: MediKioskTheme.bodyMedium.copyWith(
                      color: DesignTokens.neutral800,
                    ),
                  ),
                  if (!isComplete)
                    Text(
                      'Not captured — tap to add',
                      style: MediKioskTheme.caption.copyWith(
                        color: DesignTokens.warning500,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              isComplete ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isComplete
                  ? DesignTokens.success500
                  : DesignTokens.neutral400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}