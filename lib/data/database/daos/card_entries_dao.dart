import 'package:drift/drift.dart';

import '../../../domain/card_entry.dart';
import '../app_database.dart';
import '../tables/card_entries_table.dart';

part 'card_entries_dao.g.dart';

@DriftAccessor(tables: [CardEntries])
class CardEntriesDao extends DatabaseAccessor<AppDatabase>
    with _$CardEntriesDaoMixin {
  CardEntriesDao(super.db);

  /// Watch all entries in a binder, ordered by most recently added.
  Stream<List<CardEntry>> watchByBinder(String binderId) {
    return (select(cardEntries)
          ..where((e) => e.binderId.equals(binderId))
          ..orderBy([(e) => OrderingTerm.desc(e.addedAt)]))
        .watch();
  }

  /// Get all entries for a card across all binders.
  Future<List<CardEntry>> getByCardId(String cardId) {
    return (select(cardEntries)
          ..where((e) => e.cardId.equals(cardId)))
        .get();
  }

  Future<void> addCard(CardEntry entry) {
    return into(cardEntries).insert(_toCompanion(entry));
  }

  Future<void> updateCard(CardEntry entry) {
    return (update(cardEntries)..where((e) => e.id.equals(entry.id)))
        .write(_toCompanion(entry));
  }

  Future<void> removeCard(String id) {
    return (delete(cardEntries)..where((e) => e.id.equals(id))).go();
  }

  /// Delete all entries in a binder (used when deleting a binder).
  Future<void> deleteByBinder(String binderId) {
    return (delete(cardEntries)..where((e) => e.binderId.equals(binderId)))
        .go();
  }

  CardEntriesCompanion _toCompanion(CardEntry e) {
    return CardEntriesCompanion.insert(
      id: e.id,
      binderId: e.binderId,
      game: e.game,
      cardId: e.cardId,
      name: e.name,
      setCode: e.setCode,
      setName: e.setName,
      collectorNumber: e.collectorNumber,
      quantity: Value(e.quantity),
      foil: Value(e.foil),
      language: Value(e.language),
      condition: Value(e.condition),
      purchasePrice: Value(e.purchasePrice),
      purchaseCurrency: Value(e.purchaseCurrency),
      notes: Value(e.notes),
      imageUrl: Value(e.imageUrl),
      addedAt: e.addedAt,
      updatedAt: e.updatedAt,
    );
  }
}
