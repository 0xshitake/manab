import 'package:drift/drift.dart';

import '../../domain/card.dart';
import 'daos/cards_dao.dart';
import 'tables/cards_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [CachedCards], daos: [CardsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
            'CREATE INDEX idx_cards_game_name '
            'ON cached_cards (game, name COLLATE NOCASE)',
          );
          await customStatement(
            'CREATE INDEX idx_cards_game_set_code '
            'ON cached_cards (game, set_code)',
          );
        },
      );
}
