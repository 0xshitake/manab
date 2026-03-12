// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_entries_dao.dart';

// ignore_for_file: type=lint
mixin _$CardEntriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CardEntriesTable get cardEntries => attachedDatabase.cardEntries;
  CardEntriesDaoManager get managers => CardEntriesDaoManager(this);
}

class CardEntriesDaoManager {
  final _$CardEntriesDaoMixin _db;
  CardEntriesDaoManager(this._db);
  $$CardEntriesTableTableManager get cardEntries =>
      $$CardEntriesTableTableManager(_db.attachedDatabase, _db.cardEntries);
}
