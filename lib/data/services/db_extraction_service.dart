import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/daos/cards_dao.dart';
import 'scryfall_api_service.dart';
import 'tcgdex_api_service.dart';

/// Extracts the bundled cards.db asset and handles delta updates.
class DbExtractionService {
  static const _lastUpdatedKey = 'db_last_updated';

  /// Returns the path to the extracted database file.
  static Future<String> get dbPath async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'cards.db');
  }

  /// Whether the database has already been extracted.
  static Future<bool> get isExtracted async {
    return File(await dbPath).existsSync();
  }

  /// Extracts the bundled asset to the app documents directory.
  ///
  /// Yields progress as a double from 0.0 to 1.0.
  Stream<double> extract() async* {
    final outputPath = await dbPath;
    final outputFile = File(outputPath);

    if (outputFile.existsSync()) {
      yield 1.0;
      return;
    }

    yield 0.0;

    // Load the bundled asset.
    final data = await rootBundle.load('assets/cards.db');
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    // Write in chunks to report progress.
    final total = bytes.length;
    const chunkSize = 256 * 1024; // 256KB chunks
    final sink = outputFile.openWrite();

    var written = 0;
    for (var offset = 0; offset < total; offset += chunkSize) {
      final end = (offset + chunkSize).clamp(0, total);
      sink.add(bytes.sublist(offset, end));
      written = end;
      yield written / total;
    }

    await sink.flush();
    await sink.close();
    yield 1.0;
  }

  /// Returns the last time the database was updated, or null if never.
  static Future<DateTime?> getLastUpdated(SharedPreferences prefs) async {
    final ms = prefs.getInt(_lastUpdatedKey);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Records the current time as the last update timestamp.
  static Future<void> setLastUpdated(SharedPreferences prefs) async {
    await prefs.setInt(
        _lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Checks for new cards from APIs and merges them into the local DB.
  ///
  /// Returns the number of new cards added.
  static Future<int> checkForUpdates({
    required CardsDao cardsDao,
    required ScryfallApiService scryfallApi,
    required TcgdexApiService tcgdexApi,
    required SharedPreferences prefs,
  }) async {
    var newCards = 0;

    // Check for new MTG sets.
    try {
      final sets = await scryfallApi.fetchSetList();
      final localSets = await cardsDao.getSetCodes('mtg');
      final localSetCodes = localSets.toSet();

      for (final set in sets) {
        final code = set['code'] as String;
        if (!localSetCodes.contains(code)) {
          // New set found — fetch its cards via search.
          try {
            final card = await scryfallApi.fetchCardByName(code);
            await cardsDao.bulkInsert([card]);
            newCards++;
          } on Exception {
            // Skip failed fetches.
          }
        }
      }
    } on Exception {
      // Skip if API unreachable.
    }

    // Check for new Pokemon sets.
    try {
      final sets = await tcgdexApi.fetchSetList();
      final localSets = await cardsDao.getSetCodes('pokemon');
      final localSetCodes = localSets.toSet();

      for (final set in sets) {
        final code = set['id'] as String;
        if (!localSetCodes.contains(code)) {
          try {
            final cards =
                await tcgdexApi.fetchCardsBySet(code);
            await cardsDao.bulkInsert(cards);
            newCards += cards.length;
          } on Exception {
            // Skip failed fetches.
          }
        }
      }
    } on Exception {
      // Skip if API unreachable.
    }

    if (newCards > 0) {
      await setLastUpdated(prefs);
    }

    return newCards;
  }
}
