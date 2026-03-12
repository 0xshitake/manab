import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import 'package:manab/domain/card.dart';
import 'package:manab/domain/card_hash.dart';

/// Packs parsed card data into a SQLite database file.
class DbPacker {
  DbPacker(this._dbPath) {
    _db = sqlite3.open(_dbPath);
    _createSchema();
  }

  final String _dbPath;
  late final Database _db;
  int _insertCount = 0;

  void _createSchema() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS cached_cards (
        card_id TEXT PRIMARY KEY,
        game TEXT NOT NULL,
        name TEXT NOT NULL,
        set_code TEXT NOT NULL,
        set_name TEXT NOT NULL,
        collector_number TEXT NOT NULL,
        type_line TEXT,
        rarity TEXT NOT NULL,
        image_url TEXT,
        art_crop_url TEXT,
        price_usd REAL,
        price_usd_foil REAL,
        price_eur REAL,
        price_eur_foil REAL,
        language TEXT NOT NULL,
        cached_at INTEGER NOT NULL
      )
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS card_hashes (
        card_id TEXT NOT NULL PRIMARY KEY,
        game TEXT NOT NULL,
        phash_value INTEGER NOT NULL,
        set_code TEXT NOT NULL
      )
    ''');
  }

  /// Inserts a batch of cards using a transaction.
  void insertCards(List<CachedCard> cards) {
    _db.execute('BEGIN TRANSACTION');
    final stmt = _db.prepare('''
      INSERT OR REPLACE INTO cached_cards (
        card_id, game, name, set_code, set_name, collector_number,
        type_line, rarity, image_url, art_crop_url,
        price_usd, price_usd_foil, price_eur, price_eur_foil,
        language, cached_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''');

    for (final card in cards) {
      stmt.execute([
        card.cardId,
        card.game,
        card.name,
        card.setCode,
        card.setName,
        card.collectorNumber,
        card.typeLine,
        card.rarity,
        card.imageUrl,
        card.artCropUrl,
        card.priceUsd,
        card.priceUsdFoil,
        card.priceEur,
        card.priceEurFoil,
        card.language,
        card.cachedAt.millisecondsSinceEpoch ~/ 1000,
      ]);
    }

    stmt.dispose();
    _db.execute('COMMIT');
    _insertCount += cards.length;
  }

  /// Inserts a batch of hashes using a transaction.
  void insertHashes(List<CardHash> hashes) {
    _db.execute('BEGIN TRANSACTION');
    final stmt = _db.prepare('''
      INSERT OR REPLACE INTO card_hashes (
        card_id, game, phash_value, set_code
      ) VALUES (?, ?, ?, ?)
    ''');

    for (final hash in hashes) {
      stmt.execute([
        hash.cardId,
        hash.game,
        hash.phashValue,
        hash.setCode,
      ]);
    }

    stmt.dispose();
    _db.execute('COMMIT');
  }

  /// Get all cards that have art crop URLs for hash computation.
  List<CachedCard> getCardsWithArtCrops({String? game, Set<String>? sets}) {
    var sql = 'SELECT * FROM cached_cards WHERE art_crop_url IS NOT NULL';
    final params = <Object>[];

    if (game != null) {
      sql += ' AND game = ?';
      params.add(game);
    }
    if (sets != null && sets.isNotEmpty) {
      final placeholders = List.filled(sets.length, '?').join(',');
      sql += ' AND set_code IN ($placeholders)';
      params.addAll(sets);
    }

    final result = _db.select(sql, params);
    return result.map((row) {
      final cachedAtRaw = row['cached_at'];
      final cachedAt = cachedAtRaw is int
          ? DateTime.fromMillisecondsSinceEpoch(cachedAtRaw * 1000)
          : DateTime.now();
      return CachedCard(
        cardId: row['card_id'] as String,
        game: row['game'] as String,
        name: row['name'] as String,
        setCode: row['set_code'] as String,
        setName: row['set_name'] as String,
        collectorNumber: row['collector_number'] as String,
        typeLine: row['type_line'] as String?,
        rarity: row['rarity'] as String,
        imageUrl: row['image_url'] as String?,
        artCropUrl: row['art_crop_url'] as String?,
        priceUsd: (row['price_usd'] as num?)?.toDouble(),
        priceUsdFoil: (row['price_usd_foil'] as num?)?.toDouble(),
        priceEur: (row['price_eur'] as num?)?.toDouble(),
        priceEurFoil: (row['price_eur_foil'] as num?)?.toDouble(),
        language: row['language'] as String,
        cachedAt: cachedAt,
      );
    }).toList();
  }

  /// Get card IDs that already have hashes (for resume support).
  Set<String> getHashedCardIds() {
    final result = _db.select('SELECT card_id FROM card_hashes');
    return result.map((row) => row['card_id'] as String).toSet();
  }

  /// Creates indexes after all data is inserted (faster than indexing during insert).
  void createIndexes() {
    stderr.writeln('Creating indexes...');
    _db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cards_game_name '
      'ON cached_cards (game, name COLLATE NOCASE)',
    );
    _db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cards_game_set_code '
      'ON cached_cards (game, set_code)',
    );
    _db.execute(
      'CREATE INDEX IF NOT EXISTS idx_hashes_game '
      'ON card_hashes (game)',
    );
    _db.execute(
      'CREATE INDEX IF NOT EXISTS idx_hashes_game_set_code '
      'ON card_hashes (game, set_code)',
    );
  }

  /// Runs VACUUM to compact the database.
  void compact() {
    stderr.writeln('Compacting database...');
    _db.execute('VACUUM');
  }

  int get insertCount => _insertCount;

  /// Returns the size of the database file in bytes.
  int get fileSize => File(_dbPath).lengthSync();

  void close() {
    _db.dispose();
  }
}
