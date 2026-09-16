import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medikiosk/core/utils/document_capture.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/features/documents/providers/document_provider.dart';

class DocumentScanScreen extends ConsumerStatefulWidget {
  const DocumentScanScreen({super.key});

  @override
  ConsumerState<DocumentScanScreen> createState() =>
      _DocumentScanScreenState();
}

class _DocumentScanScreenState extends ConsumerState<DocumentScanScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: DesignTokens.white,
      appBar: AppBar(
        title: const Text(
          'Medical Documents',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: DesignTokens.primary600,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.go('/voice-conversation'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingXL,
            vertical: DesignTokens.spacingLG,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              const SizedBox(height: DesignTokens.spacingMD),
              Text(
                'Upload your prescriptions, reports,\nor other medical documents',
                textAlign: TextAlign.center,
                style: MediKioskTheme.body.copyWith(
                  color: DesignTokens.neutral700,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: DesignTokens.spacing2XL),

              
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.camera_alt_rounded,
                      label: 'Scan\nDocument',
                      onTap: () {
                        context.go('/scan-camera');
                      },
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacingMD),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.upload_file_rounded,
                      label: 'Upload\nDocuments',
                      onTap: () async {
                        try {
                          final picker = ImagePicker();
                          final List<XFile> files = await DocumentCapture.fromGallery(picker);
                          if (files.isNotEmpty && mounted) {
                            final paths = files.map((f) => f.path).toList();
                            ref.read(documentProvider.notifier).addPendingImages(paths);
                            context.go('/document-preview', extra: {'filePaths': ref.read(documentProvider.notifier).pendingImagePaths});
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not open gallery: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spacing2XL),

              
              ElevatedButton(
                onPressed: () {
                  final paths = ref.read(documentProvider.notifier).pendingImagePaths;
                  context.go('/document-preview', extra: {'filePaths': paths});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primary600,
                  foregroundColor: DesignTokens.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.continueLabel,
                  style: MediKioskTheme.bodyMedium.copyWith(
                    color: DesignTokens.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.spacingMD),

              
              OutlinedButton(
                onPressed: () => context.go('/voice-conversation'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DesignTokens.primary600,
                  side: const BorderSide(color: DesignTokens.primary600, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
                  ),
                ),
                child: Text(
                  l10n.goBack,
                  style: MediKioskTheme.bodyMedium.copyWith(
                    color: DesignTokens.primary600,
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.spacingMD),

              
              TextButton(
                onPressed: () => context.go('/review-confirm'),
                child: Text(
                  'Skip document scanning  →',
                  style: MediKioskTheme.body.copyWith(
                    color: DesignTokens.neutral500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: DesignTokens.neutral100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: DesignTokens.spacing2XL,
            horizontal: DesignTokens.spacingMD,
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: DesignTokens.primary100,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusInput),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: DesignTokens.primary600,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingMD),
              Text(
                label,
                textAlign: TextAlign.center,
                style: MediKioskTheme.bodyMedium.copyWith(
                  color: DesignTokens.primary700,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}