// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_hashes_dao.dart';

// ignore_for_file: type=lint
mixin _$CardHashesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CardHashesTable get cardHashes => attachedDatabase.cardHashes;
  CardHashesDaoManager get managers => CardHashesDaoManager(this);
}

class CardHashesDaoManager {
  final _$CardHashesDaoMixin _db;
  CardHashesDaoManager(this._db);
  $$CardHashesTableTableManager get cardHashes =>
      $$CardHashesTableTableManager(_db.attachedDatabase, _db.cardHashes);
}
