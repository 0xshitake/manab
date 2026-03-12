import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/di.dart';
import '../../data/services/db_extraction_service.dart';
import '../../domain/game_mode.dart';
import 'widgets/downloaded_sets_manager.dart';

/// App settings screen with game mode toggle and set management.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isUpdating = false;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final gameMode = ref.watch(gameModeProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final lastUpdated = _getLastUpdated(prefs);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Game mode
          ListTile(
            leading: const Icon(Icons.videogame_asset),
            title: const Text('Game Mode'),
            subtitle: Text(gameMode?.displayName ?? 'Not set'),
            trailing: SegmentedButton<GameMode>(
              segments: const [
                ButtonSegment(
                  value: GameMode.mtg,
                  label: Text('MTG'),
                ),
                ButtonSegment(
                  value: GameMode.pokemon,
                  label: Text('Pokemon'),
                ),
              ],
              selected: gameMode != null ? {gameMode} : {},
              onSelectionChanged: (values) {
                ref
                    .read(gameModeProvider.notifier)
                    .setMode(values.first);
              },
            ),
          ),
          const Divider(),

          // Database info
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Card Database'),
            subtitle: Text(lastUpdated != null
                ? 'Last updated: ${_formatDate(lastUpdated)}'
                : 'Last updated: bundled version'),
            trailing: _isUpdating
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : FilledButton.tonal(
                    onPressed: _checkForUpdates,
                    child: const Text('Check for Updates'),
                  ),
          ),
          const Divider(),

          // Export collection
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export Collection (JSON)'),
            subtitle: const Text('Share your collection as a JSON file'),
            trailing: _isExporting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : FilledButton.tonal(
                    onPressed: _exportCollection,
                    child: const Text('Export'),
                  ),
          ),
          const Divider(),

          // Downloaded sets
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Downloaded Sets',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const DownloadedSetsManager(),
        ],
      ),
    );
  }

  DateTime? _getLastUpdated(SharedPreferences prefs) {
    final ms = prefs.getInt('db_last_updated');
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _checkForUpdates() async {
    setState(() => _isUpdating = true);

    try {
      final newCards = await DbExtractionService.checkForUpdates(
        cardsDao: ref.read(cardsDaoProvider),
        scryfallApi: ref.read(scryfallApiServiceProvider),
        tcgdexApi: ref.read(tcgdexApiServiceProvider),
        prefs: ref.read(sharedPreferencesProvider),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newCards > 0
              ? 'Added $newCards new cards!'
              : 'Database is up to date.'),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _exportCollection() async {
    setState(() => _isExporting = true);

    try {
      final exportService = ref.read(exportServiceProvider);
      final filePath = await exportService.exportToJson();

      if (!mounted) return;

      await Share.shareXFiles([XFile(filePath)]);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}
