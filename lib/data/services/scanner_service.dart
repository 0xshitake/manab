import 'dart:math' as math;
import 'dart:typed_data';

import 'package:opencv_dart/opencv.dart' as cv;

import '../../config/app_config.dart';
import '../../domain/game_mode.dart';

/// Result of a successful card detection.
class DetectionResult {
  const DetectionResult({
    required this.corners,
    required this.contour,
    required this.scaleFactor,
  });

  /// Four ordered corners: [topLeft, topRight, bottomRight, bottomLeft].
  final List<cv.Point> corners;

  /// The full contour approximation (for overlay drawing).
  final cv.VecPoint contour;

  /// Scale factor from downsampled detection image back to original.
  final double scaleFactor;
}

/// OpenCV-based card detection and perspective warp service.
class ScannerService {
  bool _isProcessing = false;

  /// Whether a frame is currently being processed.
  bool get isProcessing => _isProcessing;

  /// Convert NV21 camera bytes to a BGR Mat.
  ///
  /// NV21 layout: [Y plane (w*h)] + [VU interleaved (w*h/2)].
  /// Mat rows must be h*3/2 to hold both planes.
  cv.Mat nv21ToBgr(Uint8List nv21Bytes, int width, int height) {
    final mat = cv.Mat.fromList(
      height + height ~/ 2,
      width,
      cv.MatType.CV_8UC1,
      nv21Bytes,
    );
    final bgr = cv.cvtColor(mat, cv.COLOR_YUV2BGR_NV21);
    mat.dispose();
    return bgr;
  }

  /// Detect a card in a camera frame.
  ///
  /// Returns [DetectionResult] with corner points if a card-shaped quadrilateral
  /// is found, or null if no card detected.
  Future<DetectionResult?> detectCard(
    Uint8List nv21Bytes,
    int width,
    int height,
  ) async {
    if (_isProcessing) return null;
    _isProcessing = true;

    try {
      // 1. NV21 → BGR
      final bgr = nv21ToBgr(nv21Bytes, width, height);

      // 2. Downsample for detection
      final scaleFactor = width / AppConfig.detectionDownsampleWidth;
      final smallHeight =
          (height / scaleFactor).round();
      final small = await cv.resizeAsync(
        bgr,
        (AppConfig.detectionDownsampleWidth, smallHeight),
      );
      bgr.dispose();

      // 3. Grayscale → blur → Canny
      final gray = await cv.cvtColorAsync(small, cv.COLOR_BGR2GRAY);
      small.dispose();

      final blur = await cv.gaussianBlurAsync(
        gray,
        (AppConfig.gaussianBlurSize, AppConfig.gaussianBlurSize),
        0,
      );
      gray.dispose();

      final edges = await cv.cannyAsync(
        blur,
        AppConfig.cannyThreshold1,
        AppConfig.cannyThreshold2,
      );
      blur.dispose();

      // 4. Find contours
      final (contours, hierarchy) = await cv.findContoursAsync(
        edges,
        cv.RETR_EXTERNAL,
        cv.CHAIN_APPROX_SIMPLE,
      );
      edges.dispose();
      hierarchy.dispose();

      // 5. Find best card-shaped quadrilateral
      final result = await _findBestQuadrilateral(contours, scaleFactor);
      contours.dispose();

      return result;
    } finally {
      _isProcessing = false;
    }
  }

  /// Warp detected card to a normalized rectangle.
  ///
  /// Takes the original full-resolution BGR image and the detected corners
  /// (already scaled back to full resolution).
  Future<cv.Mat> warpCard(
    Uint8List nv21Bytes,
    int width,
    int height,
    List<cv.Point> corners,
    GameMode gameMode,
  ) async {
    final bgr = nv21ToBgr(nv21Bytes, width, height);
    final (targetW, targetH) = gameMode.cardSize;

    final warped = await _perspectiveWarp(bgr, corners, targetW, targetH);
    bgr.dispose();
    return warped;
  }

  /// Find the largest quadrilateral with card-like aspect ratio.
  Future<DetectionResult?> _findBestQuadrilateral(
    cv.VecVecPoint contours,
    double scaleFactor,
  ) async {
    double bestArea = 0;
    DetectionResult? bestResult;

    for (int i = 0; i < contours.length; i++) {
      final contour = contours[i];
      final area = await cv.contourAreaAsync(contour);

      // Skip tiny contours (less than 5% of the detection image area).
      if (area < 480 * 360 * 0.05) continue;

      final perimeter = await cv.arcLengthAsync(contour, true);
      final approx = await cv.approxPolyDPAsync(
        contour,
        0.02 * perimeter,
        true,
      );

      // Must be a quadrilateral.
      if (approx.length != 4) continue;

      // Check aspect ratio (~63:88).
      final ordered = _orderCorners(approx);
      if (ordered == null) continue;

      final cardWidth = _distance(ordered[0], ordered[1]);
      final cardHeight = _distance(ordered[1], ordered[2]);

      // Ensure we measure width/height correctly (width < height for a card).
      final w = cardWidth < cardHeight ? cardWidth : cardHeight;
      final h = cardWidth < cardHeight ? cardHeight : cardWidth;
      final aspectRatio = w / h;

      final diff = (aspectRatio - AppConfig.cardAspectRatio).abs();
      if (diff > AppConfig.cardAspectRatioTolerance) continue;

      if (area > bestArea) {
        bestArea = area;
        // Scale corners back to original image coordinates.
        final scaledCorners = ordered
            .map((p) => cv.Point(
                  (p.x * scaleFactor).round(),
                  (p.y * scaleFactor).round(),
                ))
            .toList();
        bestResult = DetectionResult(
          corners: scaledCorners,
          contour: approx,
          scaleFactor: scaleFactor,
        );
      }
    }

    return bestResult;
  }

  /// Order 4 corner points as: [topLeft, topRight, bottomRight, bottomLeft].
  ///
  /// Uses sum (x+y) and difference (y-x) to determine ordering.
  List<cv.Point>? _orderCorners(cv.VecPoint points) {
    if (points.length != 4) return null;

    final pts = List.generate(4, (i) => points[i]);

    // Top-left has smallest sum (x+y), bottom-right has largest.
    pts.sort((a, b) => (a.x + a.y).compareTo(b.x + b.y));
    final topLeft = pts[0];
    final bottomRight = pts[3];

    // Top-right has smallest difference (y-x), bottom-left has largest.
    final remaining = [pts[1], pts[2]];
    remaining.sort((a, b) => (a.y - a.x).compareTo(b.y - b.x));
    final topRight = remaining[0];
    final bottomLeft = remaining[1];

    return [topLeft, topRight, bottomRight, bottomLeft];
  }

  /// Apply perspective transform to produce a normalized card image.
  Future<cv.Mat> _perspectiveWarp(
    cv.Mat src,
    List<cv.Point> corners,
    int targetWidth,
    int targetHeight,
  ) async {
    final srcPoints = cv.VecPoint.fromList(corners);
    final dstPoints = cv.VecPoint.fromList([
      cv.Point(0, 0),
      cv.Point(targetWidth - 1, 0),
      cv.Point(targetWidth - 1, targetHeight - 1),
      cv.Point(0, targetHeight - 1),
    ]);

    final transform = await cv.getPerspectiveTransformAsync(
      srcPoints,
      dstPoints,
    );

    final warped = await cv.warpPerspectiveAsync(
      src,
      transform,
      (targetWidth, targetHeight),
    );

    transform.dispose();
    return warped;
  }

  /// Euclidean distance between two points.
  double _distance(cv.Point a, cv.Point b) {
    final dx = (a.x - b.x).toDouble();
    final dy = (a.y - b.y).toDouble();
    return math.sqrt(dx * dx + dy * dy);
  }
}
