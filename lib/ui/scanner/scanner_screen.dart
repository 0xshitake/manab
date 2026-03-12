import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/di.dart';
import '../../domain/binder.dart';
import 'scanner_view_model.dart';
import 'widgets/card_border_overlay.dart';
import 'widgets/cropped_card_display.dart';
import 'widgets/edition_picker.dart';
import 'widgets/match_confirmation_sheet.dart';
import 'widgets/scan_session_summary.dart';
import 'widgets/scanner_settings_sheet.dart';

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

  void _showSessionSummary() async {
    final scannerState = ref.read(scannerViewModelProvider);
    final vm = ref.read(scannerViewModelProvider.notifier);

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) =>
            _SessionSummaryWrapper(vm: vm, scannerState: scannerState),
      ),
    );

    if (result == 'commit') {
      await _commitSession();
    }
  }

  void _showSettings() async {
    final vm = ref.read(scannerViewModelProvider.notifier);
    final scannerState = ref.read(scannerViewModelProvider);
    final cardsDao = ref.read(cardsDaoProvider);

    // Fetch available sets for the current game.
    final sets = await cardsDao.getSetCodes(scannerState.gameMode.name);

    if (!mounted) return;

    ScannerSettingsSheet.show(
      context,
      availableSets: sets,
      lockedSets: scannerState.lockedSets,
      quickMode: scannerState.quickMode,
      onSetLockChanged: (sets) => vm.setLockedSets(sets),
      onQuickModeChanged: (enabled) => vm.setQuickMode(enabled),
    );
  }

  void _onPickEdition() async {
    final vm = ref.read(scannerViewModelProvider.notifier);
    final printings = await vm.findPrintings();

    if (!mounted || printings.isEmpty) return;

    final candidate = ref.read(scannerViewModelProvider).currentCandidate;
    if (candidate == null) return;

    final selected = await EditionPicker.show(
      context,
      cardName: candidate.card.name,
      printings: printings,
    );

    if (selected != null) {
      vm.confirmWithCard(selected);
    }
  }

  Future<void> _commitSession() async {
    final scannerState = ref.read(scannerViewModelProvider);
    if (scannerState.session.isEmpty) return;

    // Show binder picker.
    final binder = await _showBinderPicker();
    if (binder == null) return;

    final binderRepo = ref.read(binderRepositoryProvider);
    final vm = ref.read(scannerViewModelProvider.notifier);

    for (final entry in scannerState.session) {
      await binderRepo.addCardToBinder(
        binderId: binder.id,
        card: entry.card,
        game: scannerState.gameMode.name,
        quantity: entry.quantity,
      );
    }

    vm.clearSession();
    if (mounted) {
      Navigator.of(context).pop(); // Close session summary.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added ${scannerState.session.length} cards to ${binder.name}',
          ),
        ),
      );
    }
  }

  Future<Binder?> _showBinderPicker() async {
    final scannerState = ref.read(scannerViewModelProvider);
    final bindersDao = ref.read(bindersDaoProvider);
    final binders =
        await bindersDao.watchAll(scannerState.gameMode.name).first;

    if (!mounted) return null;

    return showModalBottomSheet<Binder>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Save to binder',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          if (binders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No binders. Create one first.'),
            )
          else
            ...binders.map(
              (b) => ListTile(
                title: Text(b.name),
                onTap: () => Navigator.of(ctx).pop(b),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerViewModelProvider);
    final vm = ref.read(scannerViewModelProvider.notifier);

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
              debugInfo: scannerState.debugInfo,
              sessionCount: scannerState.session.length,
              quickMode: scannerState.quickMode,
              hasSetLock: scannerState.lockedSets.isNotEmpty,
              onToggleGameMode: vm.toggleGameMode,
              onSettings: _showSettings,
              onSessionSummary: _showSessionSummary,
            ),
          ),

          // Cropped card display.
          if (scannerState.croppedCardBytes != null &&
              scannerState.croppedCardSize != null &&
              !scannerState.hasMatch)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              right: 16,
              child: CroppedCardDisplay(
                rgbaBytes: scannerState.croppedCardBytes!,
                width: scannerState.croppedCardSize!.$1,
                height: scannerState.croppedCardSize!.$2,
              ),
            ),

          // Match confirmation.
          if (scannerState.hasMatch)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MatchConfirmationSheet(
                candidates: scannerState.candidates,
                currentIndex: scannerState.candidateIndex,
                onConfirm: vm.confirmMatch,
                onReject: vm.rejectMatch,
                onCycle: vm.cycleCandidates,
                onPickEdition: _onPickEdition,
              ),
            ),

          // Identifying indicator.
          if (scannerState.isIdentifying)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 80,
              left: 0,
              right: 0,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
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
    required this.debugInfo,
    required this.sessionCount,
    required this.quickMode,
    required this.hasSetLock,
    required this.onToggleGameMode,
    required this.onSettings,
    required this.onSessionSummary,
  });

  final dynamic gameMode;
  final int? processingTimeMs;
  final bool hasDetection;
  final String? debugInfo;
  final int sessionCount;
  final bool quickMode;
  final bool hasSetLock;
  final VoidCallback onToggleGameMode;
  final VoidCallback onSettings;
  final VoidCallback onSessionSummary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Game mode toggle.
              GestureDetector(
                onTap: onToggleGameMode,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              const SizedBox(width: 8),
              // Processing time.
              if (processingTimeMs != null)
                Text(
                  '${processingTimeMs}ms',
                  style: TextStyle(
                    color:
                        processingTimeMs! < 100 ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              const SizedBox(width: 8),
              // Status indicators.
              if (quickMode)
                const _StatusChip(label: 'Q', color: Colors.blue),
              if (hasSetLock)
                const _StatusChip(label: 'L', color: Colors.amber),
              const Spacer(),
              // Session count badge.
              if (sessionCount > 0)
                GestureDetector(
                  onTap: onSessionSummary,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$sessionCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Settings gear.
              GestureDetector(
                onTap: onSettings,
                child: const Icon(
                  Icons.settings,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              // Detection status.
              Icon(
                hasDetection ? Icons.crop_free : Icons.search,
                color: hasDetection ? Colors.green : Colors.grey,
                size: 20,
              ),
            ],
          ),
          if (debugInfo != null) ...[
            const SizedBox(height: 4),
            Text(
              debugInfo!,
              style: TextStyle(
                color: debugInfo!.startsWith('ERR')
                    ? Colors.red
                    : Colors.white70,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SessionSummaryWrapper extends StatefulWidget {
  const _SessionSummaryWrapper({
    required this.vm,
    required this.scannerState,
  });

  final ScannerViewModel vm;
  final ScannerState scannerState;

  @override
  State<_SessionSummaryWrapper> createState() => _SessionSummaryWrapperState();
}

class _SessionSummaryWrapperState extends State<_SessionSummaryWrapper> {
  @override
  Widget build(BuildContext context) {
    // We need to build this inline since we can't use Consumer in the bottom sheet easily.
    return ScanSessionSummary(
      entries: widget.scannerState.session,
      onRemove: (index) {
        widget.vm.removeSessionEntry(index);
        setState(() {});
      },
      onUpdateQuantity: (index, delta) {
        widget.vm.updateSessionQuantity(index, delta);
        setState(() {});
      },
      onCommit: () {
        // Handled by parent through the commit flow.
        Navigator.of(context).pop('commit');
      },
    );
  }
}
