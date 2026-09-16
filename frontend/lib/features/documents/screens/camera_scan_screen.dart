import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medikiosk/core/utils/document_capture.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/features/documents/providers/document_provider.dart';


class ScanCameraScreen extends ConsumerStatefulWidget {
  const ScanCameraScreen({super.key});

  @override
  ConsumerState<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends ConsumerState<ScanCameraScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openCamera();
    });
  }

  Future<void> _openCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await DocumentCapture.fromCamera(picker);
      if (file != null && mounted) {
        ref.read(documentProvider.notifier).addPendingImage(file.path);
        context.go('/document-preview', extra: {'filePath': file.path, 'filePaths': ref.read(documentProvider.notifier).pendingImagePaths});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera access error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          
          Container(
            color: const Color(0xFF1A1A2E),
            width: double.infinity,
            height: double.infinity,
          ),

          
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingMD,
                  vertical: DesignTokens.spacingSM,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () => context.go('/upload-documents'),
                    ),
                    const Spacer(),
                    const Text(
                      'Scan Document',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.flash_off_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.55,
              child: Stack(
                children: [
                  
                  _buildCorner(Alignment.topLeft),
                  _buildCorner(Alignment.topRight),
                  _buildCorner(Alignment.bottomLeft),
                  _buildCorner(Alignment.bottomRight),
                ],
              ),
            ),
          ),

          
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingMD,
                  vertical: DesignTokens.spacingSM,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                ),
                child: const Text(
                  'Place the document within the frame',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
          ),

          
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.flash_off_rounded,
                    color: Colors.white70,
                    size: 28,
                  ),
                  onPressed: () {},
                ),
                GestureDetector(
                  onTap: _openCamera,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.flash_auto_rounded,
                    color: Colors.white70,
                    size: 28,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    const size = 30.0;
    const thickness = 3.0;
    const color = DesignTokens.primary500;

    return Positioned(
      top: alignment.y < 0 ? 0 : null,
      bottom: alignment.y > 0 ? 0 : null,
      left: alignment.x < 0 ? 0 : null,
      right: alignment.x > 0 ? 0 : null,
      child: CustomPaint(
        size: const Size(size, size),
        painter: _CornerPainter(
          alignment: alignment,
          size: size,
          thickness: thickness,
          color: color,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Alignment alignment;
  final double size;
  final double thickness;
  final Color color;

  _CornerPainter({
    required this.alignment,
    required this.size,
    required this.thickness,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (alignment.x < 0 && alignment.y < 0) {
      path.moveTo(0, size);
      path.lineTo(0, 0);
      path.lineTo(size, 0);
    } else if (alignment.x > 0 && alignment.y < 0) {
      path.moveTo(canvasSize.width - size, 0);
      path.lineTo(canvasSize.width, 0);
      path.lineTo(canvasSize.width, size);
    } else if (alignment.x < 0 && alignment.y > 0) {
      path.moveTo(0, canvasSize.height - size);
      path.lineTo(0, canvasSize.height);
      path.lineTo(size, canvasSize.height);
    } else {
      path.moveTo(canvasSize.width - size, canvasSize.height);
      path.lineTo(canvasSize.width, canvasSize.height);
      path.lineTo(canvasSize.width, canvasSize.height - size);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}