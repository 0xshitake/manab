import '../../domain/card.dart';
import '../database/daos/card_hashes_dao.dart';
import '../database/daos/cards_dao.dart';

/// A candidate match from the scanner pipeline.
class ScanCandidate {
  final CachedCard card;
  final int distance;

  const ScanCandidate({required this.card, required this.distance});
}

/// Abstract scanner data access — hash lookup + card metadata join.
abstract class ScannerRepository {
  Future<List<ScanCandidate>> identifyCard(
    int hash,
    String game, {
    Set<String>? setLock,
  });

  /// Find all printings of a card by name.
  Future<List<CachedCard>> findPrintings(String name, String game);
}

/// Implementation backed by CardHashesDao + CardsDao.
class ScannerRepositoryImpl implements ScannerRepository {
  ScannerRepositoryImpl({
    required CardHashesDao cardHashesDao,
    required CardsDao cardsDao,
  })  : _hashesDao = cardHashesDao,
        _cardsDao = cardsDao;

  final CardHashesDao _hashesDao;
  final CardsDao _cardsDao;

  @override
  Future<List<ScanCandidate>> identifyCard(
    int hash,
    String game, {
    Set<String>? setLock,
  }) async {
    final matches = await _hashesDao.findByHammingDistance(
      hash,
      game,
      setLock: setLock,
    );

    final candidates = <ScanCandidate>[];
    for (final match in matches) {
      final card = await _cardsDao.getById(match.hash.cardId);
      if (card != null) {
        candidates.add(ScanCandidate(card: card, distance: match.distance));
      }
    }

    return candidates;
  }

  @override
  Future<List<CachedCard>> findPrintings(String name, String game) async {
    // Use exact name search for finding printings.
    final stream = _cardsDao.searchByName(game, name);
    final results = await stream.first;
    // Filter to exact name matches only.
    return results.where((c) => c.name == name).toList();
  }
}
