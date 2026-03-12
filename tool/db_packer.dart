import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import 'package:manab/domain/card.dart';

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
