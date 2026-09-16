import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/core/widgets/kiosk_app_bar.dart';
import 'package:medikiosk/features/documents/providers/document_provider.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';
import 'package:medikiosk/services/api_service.dart';

class DocumentPreviewScreen extends ConsumerStatefulWidget {
  final String? filePath;
  final List<String>? filePaths;

  const DocumentPreviewScreen({super.key, this.filePath, this.filePaths});

  @override
  ConsumerState<DocumentPreviewScreen> createState() =>
      _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState
    extends ConsumerState<DocumentPreviewScreen> {
  int _rotationAngle = 0;
  bool _isCropped = false;
  int _selectedIndex = 0;

  void _rotateImage() {
    setState(() {
      _rotationAngle = (_rotationAngle + 90) % 360;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rotated to $_rotationAngle°'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _cropImage() {
    setState(() {
      _isCropped = !_isCropped;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isCropped ? 'Crop box focused' : 'Original view reset'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  
  
  
  
  Future<void> _confirmAndExtract(List<String> paths) async {
    if (paths.isEmpty) {
      context.go('/review-confirm');
      return;
    }

    final notifier = ref.read(documentProvider.notifier);
    final sessionId = ref.read(sessionProvider).sessionId ?? '';

    notifier.setUploading(true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            SizedBox(width: 12),
            Expanded(child: Text('Reading your documents — this can take a minute…')),
          ],
        ),
        duration: Duration(minutes: 4),
      ),
    );

    try {
      final result = await ApiService().uploadDocument(
        sessionId: sessionId,
        filePaths: paths,
      );
      if (!mounted) return;
      notifier.setResult(result);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (result.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No readable text found. Please retake the photo in better light.'),
            backgroundColor: DesignTokens.warning500,
          ),
        );
        return;
      }
      context.go('/extracted-data');
    } catch (e) {
      if (!mounted) return;
      final message = _ocrErrorMessage(e);
      notifier.setError(message);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: DesignTokens.critical500,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Skip',
            textColor: Colors.white,
            onPressed: () => context.go('/review-confirm'),
          ),
        ),
      );
    }
  }

  String _ocrErrorMessage(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      if (status == 503) {
        return 'Document reading is unavailable right now. Please skip this '
            'step and show your papers to the doctor.';
      }
      if (status == 413) {
        return 'That photo is too large. Please retake it, or upload fewer '
            'pages at once.';
      }
      if (status == 400) {
        return 'That file could not be read. Please upload a clear photo or PDF.';
      }
      if (status != null && status >= 500) {
        return 'The server could not process the documents. Please try again, '
            'or skip this step.';
      }
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'Reading the documents took too long. Please try fewer pages.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'No connection to the server. Please ask staff for help.';
      }
    }
    return 'Could not process the documents. Please try again or skip this step.';
  }

  @override
  Widget build(BuildContext context) {
    final docState = ref.watch(documentProvider);
    final providerPaths = docState.pendingImagePaths;
    final List<String> allPaths = {
      if (widget.filePaths != null) ...widget.filePaths!,
      if (widget.filePath != null && widget.filePath!.isNotEmpty) widget.filePath!,
      ...providerPaths,
    }.toList();

    if (_selectedIndex >= allPaths.length && allPaths.isNotEmpty) {
      _selectedIndex = allPaths.length - 1;
    }

    final String? file = allPaths.isNotEmpty ? allPaths[_selectedIndex] : null;
    final bool hasFile = file != null && file.isNotEmpty && File(file).existsSync();

    return Scaffold(
      appBar: KioskAppBar(
        title: 'Document Preview (${allPaths.length} ${allPaths.length == 1 ? 'file' : 'files'})',
        onBack: () => context.go('/upload-documents'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            Container(
              height: 340,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: DesignTokens.neutral100,
                borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
                border: Border.all(
                  color: _isCropped ? DesignTokens.primary500 : DesignTokens.neutral200,
                  width: _isCropped ? 2 : 1,
                ),
              ),
              child: hasFile
                  ? Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: _isCropped ? const EdgeInsets.all(28) : EdgeInsets.zero,
                        child: RotatedBox(
                          quarterTurns: _rotationAngle ~/ 90,
                          child: Image.file(
                            File(file),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: DesignTokens.neutral400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No document selected',
                            style: MediKioskTheme.bodyMedium.copyWith(
                              color: DesignTokens.neutral500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Please scan or upload a prescription/report',
                            style: MediKioskTheme.caption.copyWith(
                              color: DesignTokens.neutral400,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: DesignTokens.spacingMD),

            
            if (allPaths.isNotEmpty) ...[
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: allPaths.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? DesignTokens.primary600 : DesignTokens.neutral300,
                            width: isSelected ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                File(allPaths[index]),
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () {
                                  ref.read(documentProvider.notifier).removePendingImage(index);
                                  setState(() {
                                    if (_selectedIndex >= allPaths.length - 1 && _selectedIndex > 0) {
                                      _selectedIndex--;
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: DesignTokens.spacingMD),
            ],

            
            OutlinedButton.icon(
              onPressed: () => context.go('/scan-camera'),
              icon: const Icon(Icons.add_a_photo_rounded),
              label: const Text('Add Another Document'),
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignTokens.primary600,
                side: const BorderSide(color: DesignTokens.primary600),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: DesignTokens.spacingMD),

            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionBtn(
                  icon: Icons.refresh_rounded,
                  label: 'Retake',
                  onTap: () => context.go('/scan-camera'),
                ),
                _ActionBtn(
                  icon: Icons.rotate_right_rounded,
                  label: 'Rotate',
                  onTap: _rotateImage,
                ),
                _ActionBtn(
                  icon: Icons.crop_rounded,
                  label: _isCropped ? 'Uncrop' : 'Crop',
                  onTap: _cropImage,
                ),
                _ActionBtn(
                  icon: docState.isUploading ? Icons.hourglass_top_rounded : Icons.check_circle_rounded,
                  label: docState.isUploading ? 'Reading…' : 'Confirm',
                  isPrimary: true,
                  
                  onTap: docState.isUploading ? () {} : () => _confirmAndExtract(allPaths),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: isPrimary ? DesignTokens.primary500 : DesignTokens.neutral200,
              child: Icon(
                icon,
                color: isPrimary ? DesignTokens.white : DesignTokens.neutral800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: MediKioskTheme.caption.copyWith(
                color: isPrimary ? DesignTokens.primary700 : DesignTokens.neutral700,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}