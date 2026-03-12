import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencv_dart/opencv.dart' as cv;

import '../../config/di.dart';
import '../../data/services/scanner_service.dart';
import '../../domain/game_mode.dart';

/// State for the scanner screen.
class ScannerState {
  const ScannerState({
    this.cameraController,
    this.isInitialized = false,
    this.detectionResult,
    this.croppedCardBytes,
    this.croppedCardSize,
    this.gameMode = GameMode.mtg,
    this.error,
    this.debugInfo,
    this.processingTimeMs,
  });

  final CameraController? cameraController;
  final bool isInitialized;
  final DetectionResult? detectionResult;

  /// RGBA bytes of the cropped card image for display.
  final Uint8List? croppedCardBytes;

  /// Size of the cropped card image (width, height).
  final (int, int)? croppedCardSize;

  final GameMode gameMode;
  final String? error;

  /// Debug info about frame processing.
  final String? debugInfo;

  /// Last processing time in milliseconds.
  final int? processingTimeMs;

  ScannerState copyWith({
    CameraController? cameraController,
    bool? isInitialized,
    DetectionResult? detectionResult,
    Uint8List? croppedCardBytes,
    (int, int)? croppedCardSize,
    GameMode? gameMode,
    String? error,
    String? debugInfo,
    int? processingTimeMs,
    bool clearDetection = false,
    bool clearCroppedCard = false,
    bool clearError = false,
  }) {
    return ScannerState(
      cameraController: cameraController ?? this.cameraController,
      isInitialized: isInitialized ?? this.isInitialized,
      detectionResult:
          clearDetection ? null : (detectionResult ?? this.detectionResult),
      croppedCardBytes:
          clearCroppedCard ? null : (croppedCardBytes ?? this.croppedCardBytes),
      croppedCardSize:
          clearCroppedCard ? null : (croppedCardSize ?? this.croppedCardSize),
      gameMode: gameMode ?? this.gameMode,
      error: clearError ? null : (error ?? this.error),
      debugInfo: debugInfo ?? this.debugInfo,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
    );
  }
}

/// View model managing camera lifecycle and frame processing.
class ScannerViewModel extends Notifier<ScannerState> {
  late final ScannerService _scanner;

  @override
  ScannerState build() {
    _scanner = ref.read(scannerServiceProvider);
    ref.onDispose(_dispose);
    return const ScannerState();
  }

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        state = state.copyWith(error: 'No cameras available');
        return;
      }

      // Prefer back camera.
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await controller.initialize();

      state = state.copyWith(
        cameraController: controller,
        isInitialized: true,
        clearError: true,
      );

      // Start processing frames.
      await controller.startImageStream(_onCameraFrame);
    } catch (e) {
      state = state.copyWith(error: 'Camera init failed: $e');
    }
  }

  void _onCameraFrame(CameraImage image) {
    if (_scanner.isProcessing) return;

    // Combine NV21 planes into single buffer, respecting row stride.
    final nv21 = _combineNv21Planes(image);
    final width = image.width;
    final height = image.height;

    _processFrame(nv21, width, height);
  }

  Uint8List _combineNv21Planes(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0];
    final yRowStride = yPlane.bytesPerRow;

    // Total NV21 size: width * height * 1.5
    final nv21 = Uint8List(width * height + width * (height ~/ 2));

    // Copy Y plane, stripping row stride padding if present.
    if (yRowStride == width) {
      nv21.setRange(0, width * height, yPlane.bytes);
    } else {
      for (int row = 0; row < height; row++) {
        nv21.setRange(
          row * width,
          (row + 1) * width,
          yPlane.bytes.buffer.asUint8List(
            yPlane.bytes.offsetInBytes + row * yRowStride,
            width,
          ),
        );
      }
    }

    // Copy VU plane. On Android NV21, planes[1] contains interleaved VU data.
    final vuPlane = image.planes[1];
    final vuRowStride = vuPlane.bytesPerRow;
    final vuHeight = height ~/ 2;
    final ySize = width * height;

    if (vuRowStride == width) {
      nv21.setRange(ySize, ySize + width * vuHeight, vuPlane.bytes);
    } else {
      for (int row = 0; row < vuHeight; row++) {
        nv21.setRange(
          ySize + row * width,
          ySize + (row + 1) * width,
          vuPlane.bytes.buffer.asUint8List(
            vuPlane.bytes.offsetInBytes + row * vuRowStride,
            width,
          ),
        );
      }
    }

    return nv21;
  }

  Future<void> _processFrame(
    Uint8List nv21,
    int width,
    int height,
  ) async {
    final sw = Stopwatch()..start();

    try {
      // 1. Detect card borders.
      final detection = await _scanner.detectCard(nv21, width, height);
      if (detection == null) {
        state = state.copyWith(
          clearDetection: true,
          clearCroppedCard: true,
          processingTimeMs: sw.elapsedMilliseconds,
          debugInfo: '${width}x$height no card | ${sw.elapsedMilliseconds}ms',
        );
        return;
      }

      // 2. Warp to standard card size.
      final warped = await _scanner.warpCard(
        nv21,
        width,
        height,
        detection.corners,
        state.gameMode,
      );

      // 3. Convert BGR Mat to RGBA bytes for Flutter display.
      final rgba = cv.cvtColor(warped, cv.COLOR_BGR2RGBA);
      final rgbaBytes = Uint8List.fromList(rgba.data);
      final cardSize = (rgba.cols, rgba.rows);
      rgba.dispose();
      warped.dispose();

      sw.stop();

      state = state.copyWith(
        detectionResult: detection,
        croppedCardBytes: rgbaBytes,
        croppedCardSize: cardSize,
        processingTimeMs: sw.elapsedMilliseconds,
        debugInfo: '${width}x$height FOUND | ${sw.elapsedMilliseconds}ms',
      );
    } catch (e, st) {
      sw.stop();
      developer.log('Frame processing error: $e', stackTrace: st);
      state = state.copyWith(
        clearDetection: true,
        clearCroppedCard: true,
        processingTimeMs: sw.elapsedMilliseconds,
        debugInfo: 'ERR: $e',
      );
    }
  }

  void toggleGameMode() {
    final next =
        state.gameMode == GameMode.mtg ? GameMode.pokemon : GameMode.mtg;
    state = state.copyWith(
      gameMode: next,
      clearDetection: true,
      clearCroppedCard: true,
    );
  }

  void _dispose() {
    state.cameraController?.stopImageStream();
    state.cameraController?.dispose();
  }
}

final scannerViewModelProvider =
    NotifierProvider<ScannerViewModel, ScannerState>(ScannerViewModel.new);
