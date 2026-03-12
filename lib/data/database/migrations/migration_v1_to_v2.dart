import 'package:drift/drift.dart';

/// Migration from schema v1 to v2: adds binders and card_entries tables.
///
/// Preserves existing cached_cards data. Uses raw SQL to avoid
/// dependency on generated table references (which change across versions).
Future<void> migrateV1ToV2(GeneratedDatabase db) async {
  await db.customStatement('''
    CREATE TABLE IF NOT EXISTS binders (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      game TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');

  await db.customStatement('''
    CREATE TABLE IF NOT EXISTS card_entries (
      id TEXT NOT NULL PRIMARY KEY,
      binder_id TEXT NOT NULL,
      game TEXT NOT NULL,
      card_id TEXT NOT NULL,
      name TEXT NOT NULL,
      set_code TEXT NOT NULL,
      set_name TEXT NOT NULL,
      collector_number TEXT NOT NULL,
      quantity INTEGER NOT NULL DEFAULT 1,
      foil INTEGER NOT NULL DEFAULT 0,
      language TEXT NOT NULL DEFAULT 'en',
      "condition" TEXT,
      purchase_price REAL,
      purchase_currency TEXT,
      notes TEXT,
      image_url TEXT,
      added_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');

  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_binders_game ON binders (game)',
  );
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_entries_binder_id '
    'ON card_entries (binder_id)',
  );
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS idx_entries_card_id '
    'ON card_entries (card_id)',
  );
}
