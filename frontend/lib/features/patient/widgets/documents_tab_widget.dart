import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../models/medical_document.dart';
import '../../doctor/providers/doctor_dashboard_provider.dart';


class DocumentsTabWidget extends ConsumerStatefulWidget {
  final String? sessionId;

  const DocumentsTabWidget({super.key, this.sessionId});

  @override
  ConsumerState<DocumentsTabWidget> createState() => _DocumentsTabWidgetState();
}


final _sessionDocumentsProvider =
    FutureProvider.family<List<_DocumentData>, String>((ref, sessionId) async {
  final Object data =
      await ref.watch(apiServiceProvider).getDoctorDocuments(sessionId);
  final List<dynamic> rawList;
  if (data is Map) {
    final documentList = data['documentList'];
    final documents = data['documents'];
    rawList = documentList is List
        ? documentList
        : documents is List
            ? documents
            : const <dynamic>[];
  } else if (data is List) {
    rawList = data;
  } else {
    rawList = const <dynamic>[];
  }

  return rawList.whereType<Map>().map((raw) {
    final doc = MedicalDocument.fromJson(Map<String, dynamic>.from(raw));
    return _DocumentData(
      title: doc.displayTitle,
      uploadDate: doc.uploadDate ?? '',
      ocrStatus: doc.isOcrComplete ? OcrStatus.extracted : OcrStatus.pending,
      category: doc.displayCategory,
      isImage: doc.displayCategory.toUpperCase() == 'IMAGING',
      extractedText: doc.extractedText ?? '',
      imageUrl: doc.displayImageUrl,
    );
  }).toList();
});

String _categoryLabel(String raw) {
  switch (raw.toUpperCase()) {
    case 'PRESCRIPTION':
      return 'Prescription';
    case 'LAB':
      return 'Lab Report';
    case 'IMAGING':
      return 'Imaging';
    case 'DISCHARGE_SUMMARY':
      return 'History';
    default:
      return 'Document';
  }
}

class _DocumentsTabWidgetState extends ConsumerState<DocumentsTabWidget> {
  String _selectedFilter = 'All';
  List<_DocumentData> _loaded = const [];

  final List<String> _filters = [
    'All',
    'Prescriptions',
    'Lab Reports',
    'Imaging',
    'Uploaded',
  ];

  List<_DocumentData> get _documents => _loaded;

  List<_DocumentData> get _filteredDocuments {
    if (_selectedFilter == 'All') return _documents;
    return _documents
        .where((d) => d.category.toLowerCase().contains(_selectedFilter.toLowerCase().replaceAll('s', '')))
        .toList();
  }

  int get _ocrComplete => _documents.where((d) => d.ocrStatus == OcrStatus.extracted).length;
  int get _ocrPending => _documents.where((d) => d.ocrStatus == OcrStatus.pending).length;

  @override
  Widget build(BuildContext context) {
    final sessionId = widget.sessionId;
    if (sessionId != null && sessionId.isNotEmpty) {
      final async = ref.watch(_sessionDocumentsProvider(sessionId));
      _loaded = async.valueOrNull ?? const [];
      if (async.isLoading && _loaded.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(
              child: CircularProgressIndicator(color: Color(0xFF0B6B6A))),
        );
      }
      if (async.hasError && _loaded.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 40, color: Color(0xFF9CA3AF)),
                const SizedBox(height: 12),
                Text(
                  'Could not load documents.\n${async.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          const Row(
            children: [
              Text(
                'Medical Documents',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2332)),
              ),
              SizedBox(width: 6),
              Text('📋', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Uploaded during kiosk intake',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),

          
          _buildFilterPills(),
          const SizedBox(height: 14),

          
          _buildDocumentGrid(),
          const SizedBox(height: 16),

          
          _buildStatsBar(),
          const SizedBox(height: 14),

          
          _buildActionButtons(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  
  
  
  Widget _buildFilterPills() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0B6B6A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0B6B6A)
                      : const Color(0xFFD1D5DB),
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? Colors.white : const Color(0xFF374151)),
              ),
            ),
          );
        },
      ),
    );
  }

  
  
  
  Widget _buildDocumentGrid() {
    final docs = _filteredDocuments;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemCount: docs.length + 1, 
      itemBuilder: (context, index) {
        if (index < docs.length) {
          return _DocumentCard(document: docs[index]);
        }
        return _buildUploadCard();
      },
    );
  }

  Widget _buildUploadCard() {
    return GestureDetector(
      onTap: () {
        
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF0B6B6A),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: DashedBorder(
          borderColor: const Color(0xFF0B6B6A),
          radius: 12,
          strokeWidth: 1.5,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add,
                    size: 36, color: Color(0xFF0B6B6A)),
                const SizedBox(height: 8),
                const Text(
                  'Upload New\nDocument',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B6B6A)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  
  
  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(Icons.description_outlined,
                size: 18, color: Color(0xFF0B6B6A)),
            const SizedBox(width: 6),
            Text(
              '${_documents.length} Documents',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151)),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.check_circle,
                size: 16, color: Color(0xFF22C55E)),
            const SizedBox(width: 4),
            Text(
              '$_ocrComplete OCR Complete',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151)),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.hourglass_top_rounded,
                size: 16, color: Color(0xFFF59E0B)),
            const SizedBox(width: 4),
            Text(
              '$_ocrPending Pending',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151)),
            ),
          ],
        ),
      ),
    );
  }

  
  
  
  Widget _buildActionButtons() {
    return Row(
      children: [
        
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: widget.sessionId == null || widget.sessionId!.isEmpty
                  ? null
                  : () => ref.invalidate(
                      _sessionDocumentsProvider(widget.sessionId!)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0B6B6A),
                side: const BorderSide(
                    color: Color(0xFF0B6B6A), width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'REFRESH',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B6B6A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text(
                'VALIDATE & SUBMIT',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}




enum OcrStatus { extracted, pending }

class _DocumentData {
  final String title;
  final String uploadDate;
  final OcrStatus ocrStatus;
  final String category;
  final bool isImage;
  final String extractedText;

  
  final String? imageUrl;

  const _DocumentData({
    required this.title,
    required this.uploadDate,
    required this.ocrStatus,
    required this.category,
    required this.isImage,
    this.extractedText = '',
    this.imageUrl,
  });
}




class _DocumentCard extends StatelessWidget {
  final _DocumentData document;
  const _DocumentCard({required this.document});

  Widget _buildSmartImage(String? url, {BoxFit fit = BoxFit.cover, Widget? errorWidget}) {
    final fallback = errorWidget ?? _buildDocIcon();
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

  void _openFullImage(BuildContext context) {
    if (document.imageUrl == null) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              child: _buildSmartImage(
                document.imageUrl,
                fit: BoxFit.contain,
                errorWidget: const Center(
                  child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
                ),
              ),
            ),
            Positioned(
              top: 8, right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: document.imageUrl != null ? () => _openFullImage(context) : null,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: document.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildSmartImage(document.imageUrl, fit: BoxFit.cover),
                        )
                      : _buildDocIcon(),
                ),
                const SizedBox(width: 8),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A2332),
                            height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Uploaded: ${document.uploadDate}',
                        style: const TextStyle(
                            fontSize: 9, color: Color(0xFF6B7280)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      _buildOcrBadge(),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _getCategoryColor(),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                document.category,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getCategoryTextColor()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocIcon() {
    return const Center(
      child: Icon(Icons.description_outlined,
          size: 28, color: Color(0xFF9CA3AF)),
    );
  }

  Widget _buildOcrBadge() {
    final isExtracted = document.ocrStatus == OcrStatus.extracted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: isExtracted
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              isExtracted ? 'OCR: Extracted' : 'OCR: Pending',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isExtracted
                      ? const Color(0xFF166534)
                      : const Color(0xFF92400E)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            isExtracted ? Icons.check : Icons.hourglass_top_rounded,
            size: 10,
            color: isExtracted
                ? const Color(0xFF22C55E)
                : const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (document.category) {
      case 'Imaging':
        return const Color(0xFFE0F5F5);
      case 'Lab Report':
        return const Color(0xFFE0F5F5);
      case 'Prescription':
        return const Color(0xFFF0FDF4);
      case 'History':
        return const Color(0xFFF3F4F6);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getCategoryTextColor() {
    switch (document.category) {
      case 'Imaging':
        return const Color(0xFF0B6B6A);
      case 'Lab Report':
        return const Color(0xFF0B6B6A);
      case 'Prescription':
        return const Color(0xFF166534);
      case 'History':
        return const Color(0xFF374151);
      default:
        return const Color(0xFF374151);
    }
  }
}




class DashedBorder extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double radius;
  final double strokeWidth;

  const DashedBorder({
    super.key,
    required this.child,
    this.borderColor = const Color(0xFFD1D5DB),
    this.radius = 12,
    this.strokeWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: borderColor,
        radius: radius,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    
    final path = Path()..addRRect(rrect);
    const double dashLength = 8;
    const double gapLength = 5;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance)!.position;
        final end = distance + dashLength < metric.length
            ? metric.getTangentForOffset(distance + dashLength)!.position
            : metric.getTangentForOffset(metric.length)!.position;
        canvas.drawLine(start, end, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}