import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../config/app_config.dart';
import '../../domain/card.dart';
import '../database/daos/cards_dao.dart';
import '../services/scryfall_api_service.dart';
import '../services/tcgdex_api_service.dart';

/// Abstract card data access.
abstract class CardRepository {
  Stream<List<CachedCard>> searchCards(String game, String query);
  Future<CachedCard?> getCard(String cardId);
  Future<void> refreshPrices(List<String> cardIds);
  Future<List<String>> getAvailableSets(String game);
  Stream<double> downloadSetImages(String game, String setCode);
}

/// Implementation backed by local Drift DB with API fallback.
class CardRepositoryImpl implements CardRepository {
  CardRepositoryImpl({
    required CardsDao cardsDao,
    required ScryfallApiService scryfallApi,
    required TcgdexApiService tcgdexApi,
  })  : _cardsDao = cardsDao,
        _scryfallApi = scryfallApi,
        _tcgdexApi = tcgdexApi;

  final CardsDao _cardsDao;
  final ScryfallApiService _scryfallApi;
  final TcgdexApiService _tcgdexApi;

  @override
  Stream<List<CachedCard>> searchCards(String game, String query) {
    return _cardsDao.searchByName(game, query);
  }

  @override
  Future<CachedCard?> getCard(String cardId) {
    return _cardsDao.getById(cardId);
  }

  @override
  Future<void> refreshPrices(List<String> cardIds) async {
    for (final id in cardIds) {
      final card = await _cardsDao.getById(id);
      if (card == null) continue;

      try {
        final updated = card.game == 'mtg'
            ? await _scryfallApi.fetchCardById(card.cardId)
            : await _tcgdexApi.fetchCard(
                card.cardId.replaceFirst('pokemon-', ''));
        await _cardsDao.bulkInsert([updated]);
      } on Exception {
        // Skip cards that fail to refresh.
      }
    }
  }

  @override
  Future<List<String>> getAvailableSets(String game) {
    return _cardsDao.getSetCodes(game);
  }

  @override
  Stream<double> downloadSetImages(String game, String setCode) async* {
    final cards = await _cardsDao.getCardsBySet(game, setCode);
    final cardsWithImages =
        cards.where((c) => c.imageUrl != null).toList();

    if (cardsWithImages.isEmpty) {
      yield 1.0;
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final setDir = Directory(p.join(dir.path, 'card_images', setCode));
    if (!setDir.existsSync()) {
      setDir.createSync(recursive: true);
    }

    final dio = Dio(BaseOptions(
      headers: {'User-Agent': AppConfig.userAgent},
    ));

    var downloaded = 0;
    for (final card in cardsWithImages) {
      final fileName = '${card.collectorNumber}.jpg';
      final filePath = p.join(setDir.path, fileName);

      if (!File(filePath).existsSync()) {
        try {
          await dio.download(card.imageUrl!, filePath);
        } on DioException {
          // Skip failed downloads.
        }
      }

      downloaded++;
      yield downloaded / cardsWithImages.length;
    }
  }
}
