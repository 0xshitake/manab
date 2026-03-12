import 'dart:convert';
import 'dart:io';

import 'package:manab/domain/card.dart';
import 'package:manab/data/services/tcgdex_api_service.dart';

const _userAgent =
    'Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0';

/// Downloads all Pokemon TCG cards from TCGdex API.
class TcgdexClient {
  final HttpClient _http = HttpClient();

  /// Fetches Pokemon cards, optionally filtered to specific sets.
  Stream<CachedCard> downloadAllCards({
    List<String> languages = const ['en'],
    Set<String>? filterSets,
    void Function(String setCode, int setIndex, int totalSets)? onProgress,
  }) async* {
    for (final lang in languages) {
      stderr.writeln('Fetching $lang sets...');
      var sets = await _fetchSetList(lang);

      if (filterSets != null) {
        sets = sets
            .where((s) => filterSets.contains(s['id'] as String))
            .toList();
      }

      stderr.writeln('Processing ${sets.length} sets for $lang');

      for (var i = 0; i < sets.length; i++) {
        final set = sets[i];
        final setId = set['id'] as String;
        onProgress?.call(setId, i + 1, sets.length);

        try {
          final cards = await _fetchSetCards(setId, lang);
          for (final card in cards) {
            yield card;
          }
        } on Exception catch (e) {
          stderr.writeln('  Error fetching set $setId: $e');
        }

        // Brief pause between sets.
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSetList(String lang) async {
    final url = Uri.parse('https://api.tcgdex.net/v2/$lang/sets');
    final request = await _http.getUrl(url);
    request.headers.set('User-Agent', _userAgent);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    return (json.decode(body) as List).cast<Map<String, dynamic>>();
  }

  Future<List<CachedCard>> _fetchSetCards(String setId, String lang) async {
    final url = Uri.parse('https://api.tcgdex.net/v2/$lang/sets/$setId');
    final request = await _http.getUrl(url);
    request.headers.set('User-Agent', _userAgent);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final data = json.decode(body) as Map<String, dynamic>;

    final cards = data['cards'] as List? ?? [];
    final setName = data['name'] as String? ?? setId;
    final results = <CachedCard>[];

    for (final cardJson in cards) {
      final summary = cardJson as Map<String, dynamic>;
      final cardId = summary['id'] as String?;
      if (cardId == null) continue;

      // Fetch full card detail for rarity, types, etc.
      try {
        final detail = await _fetchCardDetail(cardId, lang);
        results.add(TcgdexApiService.parseCard(detail, lang));
        await Future<void>.delayed(const Duration(milliseconds: 30));
      } on Exception {
        // Fall back to summary data.
        summary['set'] = {'id': setId, 'name': setName};
        results.add(TcgdexApiService.parseCard(summary, lang));
      }
    }

    return results;
  }

  Future<Map<String, dynamic>> _fetchCardDetail(
      String cardId, String lang) async {
    final url = Uri.parse('https://api.tcgdex.net/v2/$lang/cards/$cardId');
    final request = await _http.getUrl(url);
    request.headers.set('User-Agent', _userAgent);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    return json.decode(body) as Map<String, dynamic>;
  }

  void close() {
    _http.close();
  }
}
