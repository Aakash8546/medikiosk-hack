import 'package:flutter/material.dart';

class DocumentFrameOverlay extends StatelessWidget {
  const DocumentFrameOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FramePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F9FA8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final margin = size.width * 0.08;
    final cornerLen = size.width * 0.08;
    final rect = Rect.fromLTWH(margin, margin * 1.5, size.width - margin * 2, size.height - margin * 3);

    
    canvas.drawLine(Offset(rect.left, rect.top + cornerLen), Offset(rect.left, rect.top), paint);
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left + cornerLen, rect.top), paint);

    
    canvas.drawLine(Offset(rect.right, rect.top + cornerLen), Offset(rect.right, rect.top), paint);
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right - cornerLen, rect.top), paint);

    
    canvas.drawLine(Offset(rect.left, rect.bottom - cornerLen), Offset(rect.left, rect.bottom), paint);
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left + cornerLen, rect.bottom), paint);

    
    canvas.drawLine(Offset(rect.right, rect.bottom - cornerLen), Offset(rect.right, rect.bottom), paint);
    canvas.drawLine(Offset(rect.right, rect.bottom), Offset(rect.right - cornerLen, rect.bottom), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}