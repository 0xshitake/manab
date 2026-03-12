import 'package:drift/drift.dart';

import '../../../domain/binder.dart';
import '../app_database.dart';
import '../tables/binders_table.dart';
import '../tables/card_entries_table.dart';
import '../tables/cards_table.dart';

part 'binders_dao.g.dart';

@DriftAccessor(tables: [Binders, CardEntries, CachedCards])
class BindersDao extends DatabaseAccessor<AppDatabase> with _$BindersDaoMixin {
  BindersDao(super.db);

  /// Watch all binders for a game with card count and total value.
  Stream<List<BinderSummary>> watchWithSummary(String game) {
    return customSelect(
      'SELECT b.id, b.name, b.game, b.created_at, b.updated_at, '
      '  COALESCE(COUNT(ce.id), 0) AS card_count, '
      '  COALESCE(SUM('
      '    CASE WHEN ce.foil THEN COALESCE(cc.price_usd_foil, cc.price_usd, 0) '
      '    ELSE COALESCE(cc.price_usd, 0) END '
      '    * ce.quantity'
      '  ), 0.0) AS total_value '
      'FROM binders b '
      'LEFT JOIN card_entries ce ON ce.binder_id = b.id '
      'LEFT JOIN cached_cards cc ON ce.card_id = cc.card_id '
      'WHERE b.game = ? '
      'GROUP BY b.id '
      'ORDER BY b.created_at DESC',
      variables: [Variable.withString(game)],
      readsFrom: {binders, cardEntries, cachedCards},
    ).watch().map((rows) {
      return rows.map((row) {
        return BinderSummary(
          binder: Binder(
            id: row.read<String>('id'),
            name: row.read<String>('name'),
            game: row.read<String>('game'),
            createdAt: row.read<DateTime>('created_at'),
            updatedAt: row.read<DateTime>('updated_at'),
          ),
          cardCount: row.read<int>('card_count'),
          totalValue: row.read<double>('total_value'),
        );
      }).toList();
    });
  }

  /// Watch all binders for a game (without summary, for pickers).
  Stream<List<Binder>> watchAll(String game) {
    return (select(binders)
          ..where((b) => b.game.equals(game))
          ..orderBy([(b) => OrderingTerm.desc(b.createdAt)]))
        .watch();
  }

  Future<Binder?> getById(String id) {
    return (select(binders)..where((b) => b.id.equals(id))).getSingleOrNull();
  }

  Future<void> create(Binder binder) {
    return into(binders).insert(BindersCompanion.insert(
      id: binder.id,
      name: binder.name,
      game: binder.game,
      createdAt: binder.createdAt,
      updatedAt: binder.updatedAt,
    ));
  }

  Future<void> rename(String id, String newName) {
    return (update(binders)..where((b) => b.id.equals(id))).write(
      BindersCompanion(
        name: Value(newName),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteById(String id) {
    return (delete(binders)..where((b) => b.id.equals(id))).go();
  }
}
