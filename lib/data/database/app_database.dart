import 'package:drift/drift.dart';

import '../../domain/binder.dart';
import '../../domain/card.dart';
import '../../domain/card_entry.dart';
import 'daos/binders_dao.dart';
import 'daos/card_entries_dao.dart';
import 'daos/cards_dao.dart';
import 'migrations/migration_v1_to_v2.dart';
import 'tables/binders_table.dart';
import 'tables/card_entries_table.dart';
import 'tables/cards_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [CachedCards, Binders, CardEntries],
  daos: [CardsDao, BindersDao, CardEntriesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // CachedCards indexes
          await customStatement(
            'CREATE INDEX idx_cards_game_name '
            'ON cached_cards (game, name COLLATE NOCASE)',
          );
          await customStatement(
            'CREATE INDEX idx_cards_game_set_code '
            'ON cached_cards (game, set_code)',
          );
          // Binders indexes
          await customStatement(
            'CREATE INDEX idx_binders_game ON binders (game)',
          );
          // CardEntries indexes
          await customStatement(
            'CREATE INDEX idx_entries_binder_id '
            'ON card_entries (binder_id)',
          );
          await customStatement(
            'CREATE INDEX idx_entries_card_id '
            'ON card_entries (card_id)',
          );
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await migrateV1ToV2(this);
          }
        },
      );
}
