import 'dart:convert';
import 'dart:io';

import 'package:manab/data/services/scryfall_api_service.dart';
import 'package:manab/domain/card.dart';

const _userAgent =
    'Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0';

/// Downloads Scryfall card data.
class ScryfallClient {
  final HttpClient _http = HttpClient();

  /// Downloads cards for specific sets using the search API.
  ///
  /// Much faster than bulk download when only a few sets are needed.
  Stream<CachedCard> downloadSets(List<String> setCodes) async* {
    for (final setCode in setCodes) {
      stderr.writeln('  Fetching set: $setCode');
      var page =
          'https://api.scryfall.com/cards/search?q=set:$setCode&order=set';
      var pageNum = 1;

      while (true) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        final response = await _getJson(page);
        if (response['object'] == 'error') {
          stderr.writeln('    API error: ${response['details']}');
          break;
        }
        final cards = response['data'] as List? ?? [];
        stderr.writeln('    Page $pageNum: ${cards.length} cards');

        for (final cardJson in cards) {
          final map = cardJson as Map<String, dynamic>;
          if (map['lang'] != 'en') continue;
          yield ScryfallApiService.parseCard(map);
        }

        if (response['has_more'] == true) {
          page = response['next_page'] as String;
          pageNum++;
        } else {
          break;
        }
      }
    }
  }

  /// Downloads the bulk data JSON and returns parsed cards.
  ///
  /// This can be ~500MB of JSON with ~115k cards.
  /// Use [downloadSets] for a small number of sets instead.
  Stream<CachedCard> downloadBulkData({
    Set<String>? filterSets,
    void Function(int downloaded, int? total)? onProgress,
  }) async* {
    // Step 1: Get bulk data download URL.
    final bulkResponse =
        await _getJson('https://api.scryfall.com/bulk-data');
    final data = bulkResponse['data'] as List;
    final defaultCards =
        data.firstWhere((d) => d['type'] == 'default_cards') as Map;
    final downloadUri = defaultCards['download_uri'] as String;

    stderr.writeln('Downloading from: $downloadUri');

    // Step 2: Download the full JSON file.
    final request = await _http.getUrl(Uri.parse(downloadUri));
    request.headers.set('User-Agent', _userAgent);
    final response = await request.close();
    final totalBytes = response.contentLength;

    final buffer = StringBuffer();
    var downloaded = 0;

    await for (final chunk in response.transform(utf8.decoder)) {
      buffer.write(chunk);
      downloaded += chunk.length;
      onProgress?.call(downloaded, totalBytes > 0 ? totalBytes : null);
    }

    stderr.writeln('\nParsing JSON...');
    final cards = json.decode(buffer.toString()) as List;
    stderr.writeln('Found ${cards.length} cards');

    for (final cardJson in cards) {
      final map = cardJson as Map<String, dynamic>;

      final games = map['games'] as List?;
      if (games == null || !games.contains('paper')) continue;
      if (map['lang'] != 'en') continue;
      if (filterSets != null && !filterSets.contains(map['set'])) continue;

      yield ScryfallApiService.parseCard(map);
    }
  }

  Future<Map<String, dynamic>> _getJson(String url) async {
    final request = await _http.getUrl(Uri.parse(url));
    request.headers.set('User-Agent', _userAgent);
    request.headers.set('Accept', 'application/json');
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    return json.decode(body) as Map<String, dynamic>;
  }

  void close() {
    _http.close();
  }
}
