import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../../domain/card.dart';

/// TCGdex API client for Pokemon TCG card data.
class TcgdexApiService {
  TcgdexApiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.tcgdex.net/v2',
              headers: {'User-Agent': AppConfig.userAgent},
            ));

  final Dio _dio;

  /// Fetches a single card by ID (e.g. "base1-4").
  Future<CachedCard> fetchCard(String id, {String lang = 'en'}) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/$lang/cards/$id');
    return _parseCard(response.data!, lang);
  }

  /// Fetches the list of all Pokemon TCG sets.
  Future<List<Map<String, dynamic>>> fetchSetList(
      {String lang = 'en'}) async {
    final response = await _dio.get<List<dynamic>>('/$lang/sets');
    return response.data!.cast<Map<String, dynamic>>();
  }

  /// Fetches all cards in a set.
  Future<List<CachedCard>> fetchCardsBySet(String setCode,
      {String lang = 'en'}) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/$lang/sets/$setCode');
    final data = response.data!;
    final cards = data['cards'] as List? ?? [];
    final setName = data['name'] as String? ?? setCode;

    final results = <CachedCard>[];
    for (final card in cards) {
      final cardMap = card as Map<String, dynamic>;
      // Fetch full card detail for each card in set.
      final cardId = cardMap['id'] as String?;
      if (cardId == null) continue;
      try {
        final detail = await fetchCard(cardId, lang: lang);
        results.add(detail);
      } on DioException {
        // Skip cards that fail to fetch.
        results.add(_parseCardSummary(cardMap, setCode, setName, lang));
      }
    }
    return results;
  }

  /// Parses a full TCGdex card JSON into a [CachedCard].
  static CachedCard parseCard(Map<String, dynamic> json, String lang) =>
      _parseCard(json, lang);

  static CachedCard _parseCard(Map<String, dynamic> json, String lang) {
    final image = json['image'] as String?;

    return CachedCard(
      cardId: 'pokemon-${json['id'] as String}',
      game: 'pokemon',
      name: json['name'] as String,
      setCode: _extractSetCode(json),
      setName: _extractSetName(json),
      collectorNumber: json['localId'] as String? ?? '',
      typeLine: _extractTypeLine(json),
      rarity: json['rarity'] as String? ?? 'unknown',
      imageUrl: image != null ? '$image/high.webp' : null,
      artCropUrl: image != null ? '$image/low.webp' : null,
      priceUsd: null,
      priceUsdFoil: null,
      priceEur: null,
      priceEurFoil: null,
      language: lang,
      cachedAt: DateTime.now(),
    );
  }

  /// Parse a card from the set listing (minimal info, no full detail).
  static CachedCard _parseCardSummary(Map<String, dynamic> json,
      String setCode, String setName, String lang) {
    final image = json['image'] as String?;
    return CachedCard(
      cardId: 'pokemon-${json['id'] as String? ?? ''}',
      game: 'pokemon',
      name: json['name'] as String? ?? 'Unknown',
      setCode: setCode,
      setName: setName,
      collectorNumber: json['localId'] as String? ?? '',
      typeLine: null,
      rarity: 'unknown',
      imageUrl: image != null ? '$image/high.webp' : null,
      artCropUrl: image != null ? '$image/low.webp' : null,
      priceUsd: null,
      priceUsdFoil: null,
      priceEur: null,
      priceEurFoil: null,
      language: lang,
      cachedAt: DateTime.now(),
    );
  }

  static String _extractSetCode(Map<String, dynamic> json) {
    final set = json['set'] as Map<String, dynamic>?;
    return set?['id'] as String? ?? '';
  }

  static String _extractSetName(Map<String, dynamic> json) {
    final set = json['set'] as Map<String, dynamic>?;
    return set?['name'] as String? ?? '';
  }

  static String? _extractTypeLine(Map<String, dynamic> json) {
    final types = json['types'] as List?;
    if (types == null || types.isEmpty) return null;
    return types.join(' / ');
  }
}
