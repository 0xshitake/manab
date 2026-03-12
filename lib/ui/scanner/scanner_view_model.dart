import 'dart:async';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencv_dart/opencv.dart' as cv;

import '../../config/di.dart';
import '../../data/repositories/scanner_repository.dart';
import '../../data/services/scanner_service.dart';
import '../../domain/card.dart';
import '../../domain/game_mode.dart';
import 'widgets/scan_session_summary.dart';

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
    this.candidates = const [],
    this.candidateIndex = 0,
    this.session = const [],
    this.lockedSets = const {},
    this.quickMode = false,
    this.isIdentifying = false,
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

  /// Current match candidates from hash lookup.
  final List<ScanCandidate> candidates;

  /// Index into candidates for cycling.
  final int candidateIndex;

  /// Cards confirmed in this scan session.
  final List<SessionEntry> session;

  /// Set codes to restrict matching.
  final Set<String> lockedSets;

  /// Auto-confirm high confidence matches.
  final bool quickMode;

  /// Whether we're currently running identification.
  final bool isIdentifying;

  ScanCandidate? get currentCandidate =>
      candidates.isNotEmpty ? candidates[candidateIndex] : null;

  bool get hasMatch => candidates.isNotEmpty;

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
    List<ScanCandidate>? candidates,
    int? candidateIndex,
    List<SessionEntry>? session,
    Set<String>? lockedSets,
    bool? quickMode,
    bool? isIdentifying,
    bool clearDetection = false,
    bool clearCroppedCard = false,
    bool clearError = false,
    bool clearCandidates = false,
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
      candidates:
          clearCandidates ? const [] : (candidates ?? this.candidates),
      candidateIndex:
          clearCandidates ? 0 : (candidateIndex ?? this.candidateIndex),
      session: session ?? this.session,
      lockedSets: lockedSets ?? this.lockedSets,
      quickMode: quickMode ?? this.quickMode,
      isIdentifying: isIdentifying ?? this.isIdentifying,
    );
  }
}

/// View model managing camera lifecycle, frame processing, and scan sessions.
class ScannerViewModel extends Notifier<ScannerState> {
  late final ScannerService _scanner;
  late final ScannerRepository _scannerRepo;
  Timer? _quickModeTimer;

  @override
  ScannerState build() {
    _scanner = ref.read(scannerServiceProvider);
    _scannerRepo = ref.read(scannerRepositoryProvider);
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
    // Don't process new frames while identifying or if already processing.
    if (_scanner.isProcessing || state.isIdentifying) return;
    // Don't detect if we already have candidates awaiting confirmation.
    if (state.hasMatch) return;

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

      // 4. Crop art region and compute hash.
      final artCrop = _scanner.cropArtRegion(warped, state.gameMode);
      final hash = _scanner.computeHash(artCrop);
      artCrop.dispose();
      warped.dispose();

      sw.stop();

      state = state.copyWith(
        detectionResult: detection,
        croppedCardBytes: rgbaBytes,
        croppedCardSize: cardSize,
        processingTimeMs: sw.elapsedMilliseconds,
        debugInfo: '${width}x$height FOUND | ${sw.elapsedMilliseconds}ms',
        isIdentifying: true,
      );

      // 5. Look up hash in database.
      await _identifyCard(hash);
    } catch (e, st) {
      sw.stop();
      developer.log('Frame processing error: $e', stackTrace: st);
      state = state.copyWith(
        clearDetection: true,
        clearCroppedCard: true,
        processingTimeMs: sw.elapsedMilliseconds,
        debugInfo: 'ERR: $e',
        isIdentifying: false,
      );
    }
  }

  Future<void> _identifyCard(int hash) async {
    try {
      final candidates = await _scannerRepo.identifyCard(
        hash,
        state.gameMode.name,
        setLock: state.lockedSets.isNotEmpty ? state.lockedSets : null,
      );

      if (candidates.isEmpty) {
        state = state.copyWith(
          clearCandidates: true,
          isIdentifying: false,
          debugInfo: '${state.debugInfo} | no match',
        );
        return;
      }

      state = state.copyWith(
        candidates: candidates,
        candidateIndex: 0,
        isIdentifying: false,
        debugInfo:
            '${state.debugInfo} | d=${candidates.first.distance}',
      );

      // Quick mode: auto-confirm high confidence matches.
      if (state.quickMode && candidates.first.distance <= 5) {
        _quickModeTimer?.cancel();
        _quickModeTimer = Timer(const Duration(milliseconds: 1500), () {
          if (state.hasMatch && state.candidates.first.distance <= 5) {
            confirmMatch();
          }
        });
      }
    } catch (e) {
      developer.log('Identification error: $e');
      state = state.copyWith(
        isIdentifying: false,
        debugInfo: '${state.debugInfo} | id err: $e',
      );
    }
  }

  /// Confirm the current candidate match and add to session.
  void confirmMatch() {
    _quickModeTimer?.cancel();
    final candidate = state.currentCandidate;
    if (candidate == null) return;

    final session = List<SessionEntry>.from(state.session);

    // Check for duplicate — increment quantity if same card already in session.
    final existing = session.indexWhere((e) => e.key == candidate.card.cardId);
    if (existing >= 0) {
      session[existing].quantity++;
    } else {
      session.add(SessionEntry(card: candidate.card));
    }

    state = state.copyWith(
      session: session,
      clearCandidates: true,
      clearDetection: true,
      clearCroppedCard: true,
    );
  }

  /// Confirm with a specific card (from edition picker).
  void confirmWithCard(CachedCard card) {
    _quickModeTimer?.cancel();

    final session = List<SessionEntry>.from(state.session);
    final existing = session.indexWhere((e) => e.key == card.cardId);
    if (existing >= 0) {
      session[existing].quantity++;
    } else {
      session.add(SessionEntry(card: card));
    }

    state = state.copyWith(
      session: session,
      clearCandidates: true,
      clearDetection: true,
      clearCroppedCard: true,
    );
  }

  /// Reject the current match and resume scanning.
  void rejectMatch() {
    _quickModeTimer?.cancel();
    state = state.copyWith(
      clearCandidates: true,
      clearDetection: true,
      clearCroppedCard: true,
    );
  }

  /// Cycle to the next candidate.
  void cycleCandidates() {
    _quickModeTimer?.cancel();
    if (state.candidates.isEmpty) return;
    final next = (state.candidateIndex + 1) % state.candidates.length;
    state = state.copyWith(candidateIndex: next);
  }

  /// Find all printings for the current match (for edition picker).
  Future<List<CachedCard>> findPrintings() async {
    final candidate = state.currentCandidate;
    if (candidate == null) return [];
    return _scannerRepo.findPrintings(
        candidate.card.name, state.gameMode.name);
  }

  /// Remove an entry from the session.
  void removeSessionEntry(int index) {
    final session = List<SessionEntry>.from(state.session);
    session.removeAt(index);
    state = state.copyWith(session: session);
  }

  /// Update quantity of a session entry.
  void updateSessionQuantity(int index, int delta) {
    final session = List<SessionEntry>.from(state.session);
    session[index].quantity += delta;
    if (session[index].quantity <= 0) {
      session.removeAt(index);
    }
    state = state.copyWith(session: session);
  }

  /// Clear the session after committing.
  void clearSession() {
    state = state.copyWith(session: const []);
  }

  /// Update set lock.
  void setLockedSets(Set<String> sets) {
    state = state.copyWith(lockedSets: sets);
  }

  /// Toggle quick mode.
  void setQuickMode(bool enabled) {
    state = state.copyWith(quickMode: enabled);
  }

  void toggleGameMode() {
    final next =
        state.gameMode == GameMode.mtg ? GameMode.pokemon : GameMode.mtg;
    state = state.copyWith(
      gameMode: next,
      clearDetection: true,
      clearCroppedCard: true,
      clearCandidates: true,
    );
  }

  void _dispose() {
    _quickModeTimer?.cancel();
    state.cameraController?.stopImageStream();
    state.cameraController?.dispose();
  }
}

final scannerViewModelProvider =
    NotifierProvider<ScannerViewModel, ScannerState>(ScannerViewModel.new);
