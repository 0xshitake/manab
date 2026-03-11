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

    // Combine NV21 planes into single buffer.
    final nv21 = _combineNv21Planes(image);
    final width = image.width;
    final height = image.height;

    _processFrame(nv21, width, height);
  }

  Uint8List _combineNv21Planes(CameraImage image) {
    final yPlane = image.planes[0].bytes;
    final vuPlane = image.planes[1].bytes;
    final nv21 = Uint8List(yPlane.length + vuPlane.length);
    nv21.setRange(0, yPlane.length, yPlane);
    nv21.setRange(yPlane.length, nv21.length, vuPlane);
    return nv21;
  }

  Future<void> _processFrame(
    Uint8List nv21,
    int width,
    int height,
  ) async {
    final sw = Stopwatch()..start();

    // 1. Detect card borders.
    final detection = await _scanner.detectCard(nv21, width, height);
    if (detection == null) {
      state = state.copyWith(
        clearDetection: true,
        clearCroppedCard: true,
        processingTimeMs: sw.elapsedMilliseconds,
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
    );
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
