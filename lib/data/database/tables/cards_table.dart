import 'package:drift/drift.dart';

import '../../../domain/card.dart';

@UseRowClass(CachedCard)
class CachedCards extends Table {
  TextColumn get cardId => text()();
  TextColumn get game => text()();
  TextColumn get name => text()();
  TextColumn get setCode => text()();
  TextColumn get setName => text()();
  TextColumn get collectorNumber => text()();
  TextColumn get typeLine => text().nullable()();
  TextColumn get rarity => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get artCropUrl => text().nullable()();
  RealColumn get priceUsd => real().nullable()();
  RealColumn get priceUsdFoil => real().nullable()();
  RealColumn get priceEur => real().nullable()();
  RealColumn get priceEurFoil => real().nullable()();
  TextColumn get language => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {cardId};
}
