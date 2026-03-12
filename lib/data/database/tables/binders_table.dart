import 'package:drift/drift.dart';

import '../../../domain/binder.dart';

@UseRowClass(Binder)
class Binders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get game => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
