import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/core/network/api_endpoints.dart';
import 'package:medikiosk/core/widgets/app_drawer.dart';
import 'package:medikiosk/core/widgets/bottom_nav_bar.dart';
import 'package:medikiosk/core/widgets/kiosk_app_bar.dart';
import 'package:medikiosk/features/documents/providers/document_provider.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';
import 'package:medikiosk/models/ocr_document_page.dart';
import 'package:medikiosk/services/api_service.dart';



final _patientDocumentsProvider =
    FutureProvider.family<List<OcrDocumentPage>, String>((ref, sessionId) async {
  final result = await ApiService().getSessionDocuments(sessionId);
  return result.pages;
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final isAyush = session.mode == 'ayush';
    final l10n = AppLocalizations.of(context);

    final patientName = session.patientName?.isNotEmpty == true
        ? session.patientName!
        : 'Valued Patient';

    final abhaId = session.patientId?.isNotEmpty == true
        ? session.patientId!
        : 'ABHA ID: Pending Registration';

    final activeToken = (session.token?.isNotEmpty == true)
        ? session.token!
        : (session.sessionId != null && session.sessionId!.length >= 6
            ? 'MK-${session.sessionId!.substring(0, 6).toUpperCase()}'
            : 'MK-101');

    
    final sessionId = session.sessionId;
    final hasSession = sessionId != null && sessionId.isNotEmpty;

    final docsAsync = hasSession
        ? ref.watch(_patientDocumentsProvider(sessionId))
        : const AsyncValue<List<OcrDocumentPage>>.data([]);
    final uploadedPages = docsAsync.valueOrNull ?? [];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: KioskAppBar(
        title: isAyush ? l10n.ayushHealthDashboard : l10n.myOpdDashboard,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage:AssetImage('assets/images/patient-avatar.webp'),
                  child: Icon(
                    isAyush ? Icons.spa_rounded : Icons.person_rounded,
                    size: 32,
                    color: isAyush ? const Color(0xFF166534) : DesignTokens.primary700,
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.helloUser(patientName),
                        style: MediKioskTheme.headline3.copyWith(color: DesignTokens.neutral950),
                      ),
                      Text(
                        abhaId.startsWith('ABHA') ? abhaId : 'ID: $abhaId',
                        style: MediKioskTheme.caption.copyWith(color: DesignTokens.neutral500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingXL),

            
            if (isAyush) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DesignTokens.spacingMD),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.ayushPrakritiVikritiCompleted,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.ayushReportGeneratedDesc,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/personalized-recommendations'),
                      icon: const Icon(Icons.description_rounded, size: 16, color: Colors.white),
                      label: Text(l10n.viewAyushReportBtn),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF166534),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.spacingXL),
            ] else ...[
              Text(
                l10n.activeConsultation,
                style: MediKioskTheme.bodyMedium.copyWith(color: DesignTokens.neutral800),
              ),
              const SizedBox(height: DesignTokens.spacingMD),
              _VisitCard(
                token: 'Token: $activeToken',
                date: 'Today',
                department: l10n.generalOpdQueue,
                onView: () => context.go('/token'),
              ),
              const SizedBox(height: DesignTokens.spacingXL),
            ],

            
            Text(
              l10n.myHealthRecords,
              style: MediKioskTheme.bodyMedium.copyWith(color: DesignTokens.neutral800),
            ),
            const SizedBox(height: DesignTokens.spacingMD),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: DesignTokens.spacingMD,
              crossAxisSpacing: DesignTokens.spacingMD,
              childAspectRatio: 1.15,
              children: [
                _RecordCard(
                  icon: isAyush ? Icons.spa_rounded : Icons.description_rounded,
                  label: isAyush ? l10n.ayushReports : l10n.prescriptions,
                  count: docsAsync.isLoading
                      ? '...'
                      : uploadedPages
                          .where((p) => p.documentType.toLowerCase().contains('prescription'))
                          .length
                          .let((n) => n > 0 ? l10n.uploadedCount(n) : l10n.statusNone),
                  color: DesignTokens.primary500,
                ),
                _RecordCard(
                  icon: Icons.science_rounded,
                  label: l10n.labReports,
                  count: docsAsync.isLoading
                      ? '...'
                      : uploadedPages
                          .where((p) => p.documentType.toLowerCase().contains('lab'))
                          .length
                          .let((n) => n > 0 ? l10n.uploadedCount(n) : l10n.statusNone),
                  color: DesignTokens.info500,
                ),
                _RecordCard(
                  icon: Icons.folder_rounded,
                  label: l10n.scannedDocs,
                  count: docsAsync.isLoading
                      ? '...'
                      : uploadedPages.isEmpty ? l10n.statusNone : l10n.digitizedCount(uploadedPages.length),
                  color: DesignTokens.success500,
                ),
                _RecordCard(
                  icon: Icons.warning_amber_rounded,
                  label: l10n.redFlags,
                  count: l10n.statusEvaluated,
                  color: DesignTokens.critical500,
                ),
              ],
            ),

            
            if (hasSession) ...[
              const SizedBox(height: DesignTokens.spacingXL),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n.myUploadedDocuments,
                      style: MediKioskTheme.bodyMedium.copyWith(color: DesignTokens.neutral800),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      ref.invalidate(_patientDocumentsProvider(sessionId));
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(l10n.refreshBtn),
                    style: TextButton.styleFrom(foregroundColor: DesignTokens.primary500),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spacingMD),
              _PatientDocumentsSection(
                docsAsync: docsAsync,
                onUploadMore: () => context.go('/upload-documents'),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        activeTab: NavTab.home,
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
        context.go('/profile');
        break;
      case NavTab.more:
        context.go('/sidebar');
        break;
    }
  }
}



class _PatientDocumentsSection extends ConsumerWidget {
  final AsyncValue<List<OcrDocumentPage>> docsAsync;
  final VoidCallback onUploadMore;

  const _PatientDocumentsSection({required this.docsAsync, required this.onUploadMore});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (docsAsync.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final pages = [...(docsAsync.valueOrNull ?? [])];

    
    final pendingPaths = ref.watch(documentProvider).pendingImagePaths;
    for (final path in pendingPaths) {
      final exists = pages.any((p) => p.effectiveImageUrl == path || p.sourceFilename == path);
      if (!exists) {
        pages.add(OcrDocumentPage(
          imageUrl: path,
          sourceFilename: path.split('/').last,
          documentType: 'Prescription',
        ));
      }
    }

    if (pages.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DesignTokens.neutral50,
          borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
          border: Border.all(color: DesignTokens.neutral200),
        ),
        child: Column(
          children: [
            const Icon(Icons.upload_file_rounded, size: 36, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 8),
            const Text(
              'No documents uploaded yet',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Upload your prescriptions and reports so your doctor can review them.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onUploadMore,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Upload Documents'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: pages.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == pages.length) {
                return _AddMoreCard(onTap: onUploadMore);
              }
              return _PatientDocCard(page: pages[index]);
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${pages.length} document${pages.length == 1 ? '' : 's'} digitized — visible to your doctor',
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PatientDocCard extends StatelessWidget {
  final OcrDocumentPage page;

  const _PatientDocCard({required this.page});

  Widget _buildSmartImage(String? url, {BoxFit fit = BoxFit.cover, Widget? errorWidget}) {
    final fallback = errorWidget ?? _docIcon();
    if (url == null || url.trim().isEmpty || url.trim().toLowerCase() == 'null') return fallback;

    final clean = url.trim();

    
    if (clean.startsWith('file:
      try {
        final file = File(Uri.parse(clean).toFilePath());
        if (file.existsSync()) {
          return Image.file(file, fit: fit, errorBuilder: (_, __, ___) => fallback);
        }
      } catch (_) {}
    } else if (clean.startsWith('/') &&
        !clean.startsWith('/api') &&
        !clean.startsWith('/uploads') &&
        File(clean).existsSync()) {
      return Image.file(File(clean), fit: fit, errorBuilder: (_, __, ___) => fallback);
    }

    
    String networkUrl = clean;
    if (clean.startsWith('/')) {
      final baseUrl = ApiEndpoints.baseUrl.replaceAll(RegExp(r'/$'), '').replaceAll(RegExp(r'/api/v1$'), '');
      networkUrl = '$baseUrl$clean';
    }

    
    return Image.network(
      networkUrl,
      fit: fit,
      loadingBuilder: (_, child, p) => p == null
          ? child
          : const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
      errorBuilder: (_, __, ___) {
        try {
          final file = File(clean.replaceFirst('file:
          if (file.existsSync()) {
            return Image.file(file, fit: fit, errorBuilder: (_, __, ___) => fallback);
          }
        } catch (_) {}
        return fallback;
      },
    );
  }

  void _openFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              child: _buildSmartImage(
                imageUrl,
                fit: BoxFit.contain,
                errorWidget: const Center(
                  child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    page.documentTypeLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageSrc = page.effectiveImageUrl;
    final hasImage = imageSrc != null && imageSrc.isNotEmpty;
    return GestureDetector(
      onTap: hasImage ? () => _openFullImage(context, imageSrc) : null,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: SizedBox(
                width: 120,
                height: 90,
                child: _buildSmartImage(imageSrc, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    page.documentTypeLabel,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1A2332)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    page.displayDate,
                    style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
                  ),
                  if (hasImage)
                    const Text(
                      'Tap to view',
                      style: TextStyle(fontSize: 9, color: Color(0xFF0B6B6A), fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _docIcon() => Container(
    color: const Color(0xFFF3F4F6),
    child: const Center(child: Icon(Icons.description_outlined, size: 36, color: Color(0xFF9CA3AF))),
  );
}

class _AddMoreCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddMoreCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DesignTokens.primary500, width: 1.5),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 32, color: Color(0xFF0B6B6A)),
            SizedBox(height: 6),
            Text('Upload\nMore', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0B6B6A))),
          ],
        ),
      ),
    );
  }
}



class _VisitCard extends StatelessWidget {
  final String token;
  final String date;
  final String department;
  final VoidCallback? onView;

  const _VisitCard({
    required this.token,
    required this.date,
    required this.department,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingSM),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingMD),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DesignTokens.primary100,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
              ),
              child: const Icon(Icons.local_hospital_rounded, color: DesignTokens.primary700),
            ),
            const SizedBox(width: DesignTokens.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(token,
                      style: MediKioskTheme.bodyMedium.copyWith(color: DesignTokens.neutral950)),
                  Text('$date • $department',
                      style: MediKioskTheme.caption.copyWith(color: DesignTokens.neutral500)),
                ],
              ),
            ),
            TextButton(
              onPressed: onView,
              child: Text('View',
                  style: MediKioskTheme.bodyMedium.copyWith(color: DesignTokens.primary500)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;

  const _RecordCard({required this.icon, required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: MediKioskTheme.caption.copyWith(
                color: DesignTokens.neutral700, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              count,
              style: MediKioskTheme.headline3.copyWith(
                color: DesignTokens.neutral950, fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}