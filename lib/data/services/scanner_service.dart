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

/// Art crop pixel rectangles per game: (x, y, width, height).
const _artCropRects = {
  GameMode.mtg: (23, 98, 603, 332), // on 672×936
  GameMode.pokemon: (60, 100, 555, 282), // on 734×1024
};

/// OpenCV-based card detection, warp, and hash pipeline.
class ScannerService {
  bool _isProcessing = false;
  final cv.PHash _hasher = cv.PHash();

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

      // 3b. Dilate to close small gaps in edges.
      final kernel = cv.getStructuringElement(cv.MORPH_RECT, (3, 3));
      final dilated = await cv.dilateAsync(edges, kernel);
      edges.dispose();
      kernel.dispose();

      // 4. Find contours
      final (contours, hierarchy) = await cv.findContoursAsync(
        dilated,
        cv.RETR_EXTERNAL,
        cv.CHAIN_APPROX_SIMPLE,
      );
      dilated.dispose();
      hierarchy.dispose();

      // 5. Find best card-shaped quadrilateral
      final result = await _findBestQuadrilateral(
        contours,
        scaleFactor,
        AppConfig.detectionDownsampleWidth,
        smallHeight,
      );
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
    int imageWidth,
    int imageHeight,
  ) async {
    double bestArea = 0;
    DetectionResult? bestResult;

    // Minimum contour area: 2% of the downsampled image.
    final minArea = imageWidth * imageHeight * 0.02;

    for (int i = 0; i < contours.length; i++) {
      final contour = contours[i];
      final area = await cv.contourAreaAsync(contour);

      if (area < minArea) continue;

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

  /// Crop the art region from a warped card image.
  cv.Mat cropArtRegion(cv.Mat warped, GameMode gameMode) {
    final rect = _artCropRects[gameMode]!;
    final (x, y, w, h) = rect;
    return warped.region(cv.Rect(x, y, w, h));
  }

  /// Compute a perceptual hash of an art crop.
  ///
  /// Returns a 64-bit integer hash value.
  int computeHash(cv.Mat artCrop) {
    final hashMat = _hasher.compute(artCrop);
    final value = _matToInt64(hashMat);
    hashMat.dispose();
    return value;
  }

  /// Full pipeline: detect → warp → crop art → hash.
  ///
  /// Returns the computed hash value, or null if detection fails.
  Future<int?> detectAndHash(
    Uint8List nv21Bytes,
    int width,
    int height,
    List<cv.Point> corners,
    GameMode gameMode,
  ) async {
    final warped = await warpCard(nv21Bytes, width, height, corners, gameMode);
    final artCrop = cropArtRegion(warped, gameMode);
    warped.dispose();

    final hash = computeHash(artCrop);
    artCrop.dispose();
    return hash;
  }

  /// Convert a PHash result Mat (1×8 CV_8UC1) to a 64-bit integer.
  static int _matToInt64(cv.Mat hashMat) {
    var result = 0;
    final data = hashMat.data;
    for (var i = 0; i < 8 && i < data.length; i++) {
      result |= data[i] << (56 - i * 8);
    }
    return result;
  }

  /// Euclidean distance between two points.
  double _distance(cv.Point a, cv.Point b) {
    final dx = (a.x - b.x).toDouble();
    final dy = (a.y - b.y).toDouble();
    return math.sqrt(dx * dx + dy * dy);
  }
}
