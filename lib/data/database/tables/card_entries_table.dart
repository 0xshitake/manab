import 'package:drift/drift.dart';

import '../../../domain/card_entry.dart';

@UseRowClass(CardEntry)
class CardEntries extends Table {
  TextColumn get id => text()();
  TextColumn get binderId => text()();
  TextColumn get game => text()();
  TextColumn get cardId => text()();
  TextColumn get name => text()();
  TextColumn get setCode => text()();
  TextColumn get setName => text()();
  TextColumn get collectorNumber => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  BoolColumn get foil => boolean().withDefault(const Constant(false))();
  TextColumn get language => text().withDefault(const Constant('en'))();
  TextColumn get condition => text().nullable()();
  RealColumn get purchasePrice => real().nullable()();
  TextColumn get purchaseCurrency => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
