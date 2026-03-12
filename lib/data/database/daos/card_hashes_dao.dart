import 'package:drift/drift.dart';

import '../../../domain/card_hash.dart';
import '../app_database.dart';
import '../tables/card_hashes_table.dart';

part 'card_hashes_dao.g.dart';

/// A hash match with its Hamming distance from the query hash.
class HashMatch {
  final CardHash hash;
  final int distance;

  const HashMatch({required this.hash, required this.distance});
}

@DriftAccessor(tables: [CardHashes])
class CardHashesDao extends DatabaseAccessor<AppDatabase>
    with _$CardHashesDaoMixin {
  CardHashesDao(super.db);

  /// Find the top-N closest hashes by Hamming distance.
  ///
  /// Loads all hashes for the given [game] (optionally filtered by
  /// [setLock] set codes), computes Hamming distance in Dart, and
  /// returns the closest matches sorted by distance.
  Future<List<HashMatch>> findByHammingDistance(
    int queryHash,
    String game, {
    int threshold = 10,
    Set<String>? setLock,
    int limit = 5,
  }) async {
    // Build query with optional set lock filter.
    final query = select(cardHashes)
      ..where((h) {
        var condition = h.game.equals(game);
        if (setLock != null && setLock.isNotEmpty) {
          condition = condition & h.setCode.isIn(setLock);
        }
        return condition;
      });

    final allHashes = await query.get();

    // Compute Hamming distance in Dart (bit count of XOR).
    final matches = <HashMatch>[];
    for (final hash in allHashes) {
      final distance = _hammingDistance(queryHash, hash.phashValue);
      if (distance <= threshold) {
        matches.add(HashMatch(hash: hash, distance: distance));
      }
    }

    // Sort by distance ascending, take top N.
    matches.sort((a, b) => a.distance.compareTo(b.distance));
    if (matches.length > limit) {
      return matches.sublist(0, limit);
    }
    return matches;
  }

  /// Bulk insert hashes using a transaction.
  Future<void> bulkInsert(List<CardHash> hashes) async {
    await batch((b) {
      b.insertAll(
        cardHashes,
        hashes.map(_toCompanion).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  /// Count hashes for a given game.
  Future<int> countByGame(String game) async {
    final count = cardHashes.cardId.count();
    final query = selectOnly(cardHashes)
      ..addColumns([count])
      ..where(cardHashes.game.equals(game));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Hamming distance: count of differing bits between two 64-bit values.
  static int _hammingDistance(int a, int b) {
    var xor = a ^ b;
    var count = 0;
    while (xor != 0) {
      count += xor & 1;
      xor = xor >>> 1;
    }
    return count;
  }

  CardHashesCompanion _toCompanion(CardHash hash) {
    return CardHashesCompanion.insert(
      cardId: hash.cardId,
      game: hash.game,
      phashValue: hash.phashValue,
      setCode: hash.setCode,
    );
  }
}
