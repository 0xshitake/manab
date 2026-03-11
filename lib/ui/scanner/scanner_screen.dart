import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'scanner_view_model.dart';
import 'widgets/card_border_overlay.dart';
import 'widgets/cropped_card_display.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize camera after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scannerViewModelProvider.notifier).initCamera();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final vm = ref.read(scannerViewModelProvider.notifier);
    final controller =
        ref.read(scannerViewModelProvider).cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      vm.initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview.
          if (scannerState.isInitialized &&
              scannerState.cameraController != null)
            CameraPreview(scannerState.cameraController!)
          else if (scannerState.error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  scannerState.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Card border overlay.
          if (scannerState.detectionResult != null &&
              scannerState.cameraController != null)
            CardBorderOverlay(
              detectionResult: scannerState.detectionResult!,
              previewSize: scannerState.cameraController!.value.previewSize!,
            ),

          // Debug info bar.
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: _DebugInfoBar(
              gameMode: scannerState.gameMode,
              processingTimeMs: scannerState.processingTimeMs,
              hasDetection: scannerState.detectionResult != null,
              onToggleGameMode: () => ref
                  .read(scannerViewModelProvider.notifier)
                  .toggleGameMode(),
            ),
          ),

          // Cropped card display.
          if (scannerState.croppedCardBytes != null &&
              scannerState.croppedCardSize != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              right: 16,
              child: CroppedCardDisplay(
                rgbaBytes: scannerState.croppedCardBytes!,
                width: scannerState.croppedCardSize!.$1,
                height: scannerState.croppedCardSize!.$2,
              ),
            ),
        ],
      ),
    );
  }
}

class _DebugInfoBar extends StatelessWidget {
  const _DebugInfoBar({
    required this.gameMode,
    required this.processingTimeMs,
    required this.hasDetection,
    required this.onToggleGameMode,
  });

  final dynamic gameMode;
  final int? processingTimeMs;
  final bool hasDetection;
  final VoidCallback onToggleGameMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Game mode toggle.
          GestureDetector(
            onTap: onToggleGameMode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: hasDetection ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                gameMode.toString().split('.').last.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Processing time.
          if (processingTimeMs != null)
            Text(
              '${processingTimeMs}ms',
              style: TextStyle(
                color: processingTimeMs! < 100 ? Colors.green : Colors.orange,
                fontSize: 12,
              ),
            ),
          const Spacer(),
          // Detection status.
          Icon(
            hasDetection ? Icons.crop_free : Icons.search,
            color: hasDetection ? Colors.green : Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }
}
