// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'binders_dao.dart';

// ignore_for_file: type=lint
mixin _$BindersDaoMixin on DatabaseAccessor<AppDatabase> {
  $BindersTable get binders => attachedDatabase.binders;
  $CardEntriesTable get cardEntries => attachedDatabase.cardEntries;
  $CachedCardsTable get cachedCards => attachedDatabase.cachedCards;
  BindersDaoManager get managers => BindersDaoManager(this);
}

class BindersDaoManager {
  final _$BindersDaoMixin _db;
  BindersDaoManager(this._db);
  $$BindersTableTableManager get binders =>
      $$BindersTableTableManager(_db.attachedDatabase, _db.binders);
  $$CardEntriesTableTableManager get cardEntries =>
      $$CardEntriesTableTableManager(_db.attachedDatabase, _db.cardEntries);
  $$CachedCardsTableTableManager get cachedCards =>
      $$CachedCardsTableTableManager(_db.attachedDatabase, _db.cachedCards);
}
