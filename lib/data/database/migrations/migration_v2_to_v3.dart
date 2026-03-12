import 'package:drift/drift.dart';

/// Migration from schema v2 to v3: adds card_hashes table for scanner.
Future<void> migrateV2ToV3(GeneratedDatabase db) async {
  await db.customStatement('''
    CREATE TABLE IF NOT EXISTS card_hashes (
      card_id TEXT NOT NULL PRIMARY KEY,
      game TEXT NOT NULL,
      phash_value INTEGER NOT NULL,
      set_code TEXT NOT NULL
    )
  ''');

  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_hashes_game '
    'ON card_hashes (game)',
  );
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_hashes_game_set_code '
    'ON card_hashes (game, set_code)',
  );
}
