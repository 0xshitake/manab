// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cards_dao.dart';

// ignore_for_file: type=lint
mixin _$CardsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CachedCardsTable get cachedCards => attachedDatabase.cachedCards;
  CardsDaoManager get managers => CardsDaoManager(this);
}

class CardsDaoManager {
  final _$CardsDaoMixin _db;
  CardsDaoManager(this._db);
  $$CachedCardsTableTableManager get cachedCards =>
      $$CachedCardsTableTableManager(_db.attachedDatabase, _db.cachedCards);
}
