import 'package:drift/drift.dart';

import '../../../domain/card.dart';
import '../app_database.dart';
import '../tables/cards_table.dart';

part 'cards_dao.g.dart';

@DriftAccessor(tables: [CachedCards])
class CardsDao extends DatabaseAccessor<AppDatabase> with _$CardsDaoMixin {
  CardsDao(super.db);

  Stream<List<CachedCard>> searchByName(String game, String query) {
    return (select(cachedCards)
          ..where((c) => c.game.equals(game) & c.name.like('%$query%'))
          ..orderBy([(c) => OrderingTerm.asc(c.name)])
          ..limit(50))
        .watch();
  }

  Future<CachedCard?> getById(String cardId) {
    return (select(cachedCards)
          ..where((c) => c.cardId.equals(cardId)))
        .getSingleOrNull();
  }

  Future<void> bulkInsert(List<CachedCard> cards) async {
    await batch((b) {
      b.insertAll(
        cachedCards,
        cards.map(_toCompanion).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<List<String>> getSetCodes(String game) async {
    final query = selectOnly(cachedCards, distinct: true)
      ..addColumns([cachedCards.setCode])
      ..where(cachedCards.game.equals(game))
      ..orderBy([OrderingTerm.asc(cachedCards.setCode)]);
    final rows = await query.get();
    return rows.map((row) => row.read(cachedCards.setCode)!).toList();
  }

  Future<List<CachedCard>> getCardsBySet(String game, String setCode) {
    return (select(cachedCards)
          ..where(
              (c) => c.game.equals(game) & c.setCode.equals(setCode))
          ..orderBy([(c) => OrderingTerm.asc(c.collectorNumber)]))
        .get();
  }

  CachedCardsCompanion _toCompanion(CachedCard card) {
    return CachedCardsCompanion.insert(
      cardId: card.cardId,
      game: card.game,
      name: card.name,
      setCode: card.setCode,
      setName: card.setName,
      collectorNumber: card.collectorNumber,
      typeLine: Value(card.typeLine),
      rarity: card.rarity,
      imageUrl: Value(card.imageUrl),
      artCropUrl: Value(card.artCropUrl),
      priceUsd: Value(card.priceUsd),
      priceUsdFoil: Value(card.priceUsdFoil),
      priceEur: Value(card.priceEur),
      priceEurFoil: Value(card.priceEurFoil),
      language: card.language,
      cachedAt: card.cachedAt,
    );
  }
}
