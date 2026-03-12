import 'package:flutter/material.dart';
import 'package:opencv_dart/opencv.dart' as cv;

import '../../../data/services/scanner_service.dart';

/// Draws detected card contour corners and border highlight on the camera preview.
class CardBorderOverlay extends StatelessWidget {
  const CardBorderOverlay({
    super.key,
    required this.detectionResult,
    required this.previewSize,
  });

  final DetectionResult detectionResult;

  /// Camera preview resolution (width x height, before rotation).
  final Size previewSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CardBorderPainter(
        corners: detectionResult.corners,
        previewSize: previewSize,
      ),
      size: Size.infinite,
    );
  }
}

class _CardBorderPainter extends CustomPainter {
  _CardBorderPainter({
    required this.corners,
    required this.previewSize,
  });

  final List<cv.Point> corners;
  final Size previewSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.length != 4) return;

    // Camera preview is rotated 90 degrees on Android (portrait mode).
    // previewSize is landscape (e.g. 1920x1080), display is portrait.
    // Map camera coordinates to screen coordinates.
    final scaleX = size.width / previewSize.height;
    final scaleY = size.height / previewSize.width;

    final screenPoints = corners.map((p) {
      // Rotate 90 degrees clockwise: (x, y) → (y, maxX - x).
      // Then scale to screen size.
      return Offset(
        p.y * scaleX,
        (previewSize.width - p.x) * scaleY,
      );
    }).toList();

    // Draw border.
    final borderPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final path = Path()
      ..moveTo(screenPoints[0].dx, screenPoints[0].dy)
      ..lineTo(screenPoints[1].dx, screenPoints[1].dy)
      ..lineTo(screenPoints[2].dx, screenPoints[2].dy)
      ..lineTo(screenPoints[3].dx, screenPoints[3].dy)
      ..close();

    canvas.drawPath(path, borderPaint);

    // Draw corner circles.
    final cornerPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    for (final point in screenPoints) {
      canvas.drawCircle(point, 8, cornerPaint);
    }

    // Draw corner labels.
    final labels = ['TL', 'TR', 'BR', 'BL'];
    for (int i = 0; i < 4; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        screenPoints[i] + const Offset(10, -6),
      );
    }
  }

  @override
  bool shouldRepaint(_CardBorderPainter oldDelegate) {
    return oldDelegate.corners != corners;
  }
}
