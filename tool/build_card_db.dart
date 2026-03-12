import 'dart:io';

import 'package:manab/domain/card.dart';
import 'package:manab/domain/card_hash.dart';

import 'db_packer.dart';
import 'phash_computer.dart';
import 'scryfall_client.dart';
import 'tcgdex_client.dart';

/// Build tool to generate the bundled cards.db asset.
///
/// Usage:
///   dart run tool/build_card_db.dart --full
///   dart run tool/build_card_db.dart --game=mtg --sets=ltr
///   dart run tool/build_card_db.dart --game=pokemon --sets=base1,base2
///   dart run tool/build_card_db.dart --sets=ltr,base1,base2
///   dart run tool/build_card_db.dart --hash-only  (rebuild hashes from existing cards)
void main(List<String> args) async {
  final flags = _parseArgs(args);
  final outputPath = flags['output'] ?? 'assets/cards.db';
  final game = flags['game']; // null = both
  final setsFilter = flags['sets']?.split(',').toSet();
  final hashOnly = flags.containsKey('hash-only');

  if (!hashOnly) {
    // Clean previous output.
    final outputFile = File(outputPath);
    if (outputFile.existsSync()) {
      outputFile.deleteSync();
    }
  }

  // Ensure assets directory exists.
  final assetsDir = Directory('assets');
  if (!assetsDir.existsSync()) {
    assetsDir.createSync();
  }

  final packer = DbPacker(outputPath);
  var totalCards = 0;

  try {
    if (!hashOnly) {
      // MTG cards from Scryfall.
      if (game == null || game == 'mtg') {
        totalCards += await _importMtg(packer, setsFilter);
      }

      // Pokemon cards from TCGdex.
      if (game == null || game == 'pokemon') {
        totalCards += await _importPokemon(packer, setsFilter);
      }

      packer.createIndexes();
    }

    // Compute perceptual hashes for art crops.
    final hashCount = await _computeHashes(packer, game, setsFilter);

    packer.compact();

    final sizeMb = packer.fileSize / (1024 * 1024);
    stderr.writeln('\nDone! $totalCards cards, $hashCount hashes -> '
        '$outputPath (${sizeMb.toStringAsFixed(1)} MB)');
  } finally {
    packer.close();
  }
}

Future<int> _importMtg(DbPacker packer, Set<String>? setsFilter) async {
  stderr.writeln('=== Importing MTG cards from Scryfall ===');
  final client = ScryfallClient();
  final batch = <CachedCard>[];
  var count = 0;

  try {
    // Use search API for specific sets (fast), bulk for everything.
    final Stream<CachedCard> cardStream;
    if (setsFilter != null && setsFilter.isNotEmpty) {
      cardStream = client.downloadSets(setsFilter.toList());
    } else {
      cardStream = client.downloadBulkData(
        onProgress: (downloaded, total) {
          final pct =
              total != null ? (downloaded / total * 100).toInt() : '?';
          stderr.write('\r  Downloading: $pct%  ');
        },
      );
    }

    await for (final card in cardStream) {
      batch.add(card);
      count++;

      if (batch.length >= 5000) {
        packer.insertCards(batch);
        stderr.write('\r  Inserted $count cards  ');
        batch.clear();
      }
    }

    if (batch.isNotEmpty) {
      packer.insertCards(batch);
    }
    stderr.writeln('\n  MTG total: $count cards');
  } finally {
    client.close();
  }

  return count;
}

Future<int> _importPokemon(DbPacker packer, Set<String>? setsFilter) async {
  stderr.writeln('=== Importing Pokemon cards from TCGdex ===');
  final client = TcgdexClient();
  final batch = <CachedCard>[];
  var count = 0;

  try {
    await for (final card in client.downloadAllCards(
      languages: const ['en'],
      filterSets: setsFilter,
      onProgress: (setCode, setIndex, totalSets) {
        stderr.write('\r  Set $setIndex/$totalSets: $setCode  ');
      },
    )) {
      batch.add(card);
      count++;

      if (batch.length >= 1000) {
        packer.insertCards(batch);
        batch.clear();
      }
    }

    if (batch.isNotEmpty) {
      packer.insertCards(batch);
    }
    stderr.writeln('\n  Pokemon total: $count cards');
  } finally {
    client.close();
  }

  return count;
}

Future<int> _computeHashes(
    DbPacker packer, String? game, Set<String>? setsFilter) async {
  stderr.writeln('\n=== Computing perceptual hashes ===');

  // Get cards that have art crop URLs from the DB.
  final cards = packer.getCardsWithArtCrops(game: game, sets: setsFilter);
  if (cards.isEmpty) {
    stderr.writeln('  No cards with art crop URLs found');
    return 0;
  }

  // Get already-hashed IDs for resume support.
  final existingIds = packer.getHashedCardIds();
  stderr.writeln(
      '  ${cards.length} cards with art crops, ${existingIds.length} already hashed');

  final computer = PHashComputer();
  final batch = <CardHash>[];
  var count = 0;

  try {
    await for (final hash in computer.computeHashes(
      cards,
      skipIds: existingIds,
      onProgress: (done, total) {
        if (done % 50 == 0 || done == total) {
          stderr.write('\r  Hashing: $done/$total  ');
        }
      },
    )) {
      batch.add(hash);
      count++;

      if (batch.length >= 500) {
        packer.insertHashes(batch);
        batch.clear();
      }
    }

    if (batch.isNotEmpty) {
      packer.insertHashes(batch);
    }

    stderr.writeln('\n  Computed $count new hashes');
  } finally {
    computer.close();
  }

  return count + existingIds.length;
}

Map<String, String?> _parseArgs(List<String> args) {
  final flags = <String, String?>{};
  for (final arg in args) {
    if (arg == '--full') {
      flags['full'] = null;
    } else if (arg == '--hash-only') {
      flags['hash-only'] = null;
    } else if (arg.startsWith('--game=')) {
      flags['game'] = arg.substring('--game='.length);
    } else if (arg.startsWith('--sets=')) {
      flags['sets'] = arg.substring('--sets='.length);
    } else if (arg.startsWith('--output=')) {
      flags['output'] = arg.substring('--output='.length);
    }
  }
  return flags;
}
