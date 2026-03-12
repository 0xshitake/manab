import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../../domain/card.dart';

/// Scryfall API client for Magic: The Gathering card data.
///
/// Rate limit: 75ms between requests per Scryfall API terms.
class ScryfallApiService {
  ScryfallApiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.scryfall.com',
              headers: {'User-Agent': AppConfig.userAgent},
            ));

  final Dio _dio;
  DateTime _lastRequest = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> _throttle() async {
    final elapsed = DateTime.now().difference(_lastRequest);
    if (elapsed.inMilliseconds < 75) {
      await Future<void>.delayed(
          Duration(milliseconds: 75 - elapsed.inMilliseconds));
    }
    _lastRequest = DateTime.now();
  }

  /// Returns the download URI for the "default_cards" bulk data file.
  Future<String> fetchBulkDataUrl() async {
    await _throttle();
    final response = await _dio.get<Map<String, dynamic>>('/bulk-data');
    final data = response.data!['data'] as List;
    final defaultCards =
        data.firstWhere((d) => d['type'] == 'default_cards') as Map;
    return defaultCards['download_uri'] as String;
  }

  /// Fetches a single card by Scryfall ID.
  Future<CachedCard> fetchCardById(String id) async {
    await _throttle();
    final response =
        await _dio.get<Map<String, dynamic>>('/cards/$id');
    return _parseCard(response.data!);
  }

  /// Fetches a card by exact name.
  Future<CachedCard> fetchCardByName(String name) async {
    await _throttle();
    final response = await _dio.get<Map<String, dynamic>>(
      '/cards/named',
      queryParameters: {'exact': name},
    );
    return _parseCard(response.data!);
  }

  /// Fetches the list of all MTG sets.
  Future<List<Map<String, dynamic>>> fetchSetList() async {
    await _throttle();
    final response = await _dio.get<Map<String, dynamic>>('/sets');
    return (response.data!['data'] as List).cast<Map<String, dynamic>>();
  }

  /// Parses a Scryfall card JSON object into a [CachedCard].
  static CachedCard parseCard(Map<String, dynamic> json) =>
      _parseCard(json);

  static CachedCard _parseCard(Map<String, dynamic> json) {
    final imageUris = json['image_uris'] as Map<String, dynamic>?;
    final prices = json['prices'] as Map<String, dynamic>?;

    return CachedCard(
      cardId: json['id'] as String,
      game: 'mtg',
      name: json['name'] as String,
      setCode: json['set'] as String,
      setName: json['set_name'] as String,
      collectorNumber: json['collector_number'] as String,
      typeLine: json['type_line'] as String?,
      rarity: json['rarity'] as String,
      imageUrl: imageUris?['normal'] as String?,
      artCropUrl: imageUris?['art_crop'] as String?,
      priceUsd: _parsePrice(prices?['usd']),
      priceUsdFoil: _parsePrice(prices?['usd_foil']),
      priceEur: _parsePrice(prices?['eur']),
      priceEurFoil: _parsePrice(prices?['eur_foil']),
      language: json['lang'] as String? ?? 'en',
      cachedAt: DateTime.now(),
    );
  }

  static double? _parsePrice(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }
}
