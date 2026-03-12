import 'package:drift/drift.dart';

import '../../../domain/card_hash.dart';

@UseRowClass(CardHash)
class CardHashes extends Table {
  TextColumn get cardId => text()();
  TextColumn get game => text()();
  IntColumn get phashValue => integer()();
  TextColumn get setCode => text()();

  @override
  Set<Column> get primaryKey => {cardId};
}
