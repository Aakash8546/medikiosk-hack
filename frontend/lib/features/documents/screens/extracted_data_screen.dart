import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/core/widgets/large_button.dart';
import 'package:medikiosk/core/widgets/large_button_secondary.dart';
import 'package:medikiosk/features/documents/providers/document_provider.dart';
import 'package:medikiosk/models/ocr_document_page.dart';






class OcrReviewScreen extends ConsumerWidget {
  const OcrReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(documentProvider);
    final pages = state.extractedPages;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ocrReviewTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                Expanded(
                  child: pages.isEmpty
                      ? _EmptyState(errorMessage: state.errorMessage)
                      : ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.spacingXL,
                            vertical: DesignTokens.spacingLG,
                          ),
                          children: [
                            Text(
                              'We read ${pages.length} page${pages.length == 1 ? '' : 's'} '
                              'from your documents. Please check them.',
                              textAlign: TextAlign.center,
                              style: MediKioskTheme.body.copyWith(
                                color: DesignTokens.neutral700,
                                height: 1.5,
                              ),
                            ),
                            if (!state.persistedToSession) ...[
                              const SizedBox(height: DesignTokens.spacingMD),
                              _Notice(
                                icon: Icons.info_outline_rounded,
                                color: DesignTokens.warning500,
                                text: 'Read successfully, but not yet linked to '
                                    'your hospital record. Staff can attach it at the desk.',
                              ),
                            ],
                            const SizedBox(height: DesignTokens.spacingLG),
                            for (final page in pages) _PageCard(page: page),
                          ],
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacingXL),
                  child: Column(
                    children: [
                      PrimaryButton(
                        label: pages.isEmpty ? 'Continue' : 'Looks correct',
                        onPressed: () => context.go('/review-confirm'),
                      ),
                      const SizedBox(height: DesignTokens.spacingMD),
                      SecondaryButton(
                        label: 'Scan another document',
                        onPressed: () => context.go('/upload-documents'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String? errorMessage;
  const _EmptyState({this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final failed = errorMessage != null && errorMessage!.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              failed ? Icons.error_outline_rounded : Icons.description_outlined,
              size: 64,
              color: failed ? DesignTokens.critical500 : DesignTokens.neutral400,
            ),
            const SizedBox(height: DesignTokens.spacingMD),
            Text(
              failed ? errorMessage! : 'No documents have been read yet.',
              textAlign: TextAlign.center,
              style: MediKioskTheme.bodyMedium.copyWith(
                color: DesignTokens.neutral700,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingSM),
            Text(
              'You can continue without documents — the doctor will still see '
              'the answers you gave.',
              textAlign: TextAlign.center,
              style: MediKioskTheme.caption.copyWith(
                color: DesignTokens.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageCard extends StatelessWidget {
  final OcrDocumentPage page;
  const _PageCard({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingMD),
      padding: const EdgeInsets.all(DesignTokens.spacingMD),
      decoration: BoxDecoration(
        color: DesignTokens.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
        border: Border.all(color: DesignTokens.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconFor(page.documentType),
                  size: 20, color: DesignTokens.primary600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  page.documentTypeLabel,
                  style: MediKioskTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.primary700,
                  ),
                ),
              ),
              Text(
                page.displayDate,
                style: MediKioskTheme.caption
                    .copyWith(color: DesignTokens.neutral500),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingSM),
          if (page.isEmpty)
            Text(
              'Nothing could be read from this page. Please show it to the '
              'doctor directly.',
              style: MediKioskTheme.caption
                  .copyWith(color: DesignTokens.warning500),
            ),
          if (page.diagnoses.isNotEmpty)
            _Section(
              title: 'Conditions',
              children: page.diagnoses
                  .map((d) => _Row(label: d))
                  .toList(),
            ),
          if (page.medications.isNotEmpty)
            _Section(
              title: 'Medicines',
              children: page.medications
                  .map((m) => _Row(label: m.display))
                  .toList(),
            ),
          if (page.labValues.isNotEmpty)
            _Section(
              title: 'Test results',
              children: page.labValues
                  .map((l) => _Row(
                        label: l.testName,
                        value: l.display,
                        
                        
                        isAbnormal: l.isAbnormal == true,
                        hint: l.referenceRange,
                      ))
                  .toList(),
            ),
          if (page.procedures.isNotEmpty)
            _Section(
              title: 'Procedures',
              children:
                  page.procedures.map((p) => _Row(label: p)).toList(),
            ),
        ],
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type.toLowerCase()) {
      case 'prescription':
        return Icons.medication_outlined;
      case 'lab_report':
        return Icons.science_outlined;
      case 'discharge_summary':
        return Icons.local_hospital_outlined;
      case 'imaging':
        return Icons.image_outlined;
      default:
        return Icons.description_outlined;
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.spacingSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: MediKioskTheme.caption.copyWith(
              color: DesignTokens.neutral500,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String? value;
  final String? hint;
  final bool isAbnormal;

  const _Row({
    required this.label,
    this.value,
    this.hint,
    this.isAbnormal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value == null ? label : '$label: $value',
                  style: MediKioskTheme.body.copyWith(
                    color: isAbnormal
                        ? DesignTokens.critical500
                        : DesignTokens.neutral800,
                    fontWeight:
                        isAbnormal ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
                if (hint != null && hint!.isNotEmpty)
                  Text(
                    'Normal range $hint',
                    style: MediKioskTheme.caption
                        .copyWith(color: DesignTokens.neutral500),
                  ),
              ],
            ),
          ),
          if (isAbnormal)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.warning_amber_rounded,
                  size: 18, color: DesignTokens.critical500),
            ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _Notice({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingSM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusInput),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: MediKioskTheme.caption
                  .copyWith(color: DesignTokens.neutral700),
            ),
          ),
        ],
      ),
    );
  }
}