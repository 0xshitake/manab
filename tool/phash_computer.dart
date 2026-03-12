import 'dart:io';
import 'dart:typed_data';

import 'package:opencv_dart/opencv.dart' as cv;

import 'package:manab/domain/card.dart';
import 'package:manab/domain/card_hash.dart';

/// Computes perceptual hashes for card art crops.
///
/// Downloads art crop images and computes PHash for each card.
/// Supports resume via an existing set of already-hashed card IDs.
class PHashComputer {
  final HttpClient _http = HttpClient();
  final cv.PHash _hasher = cv.PHash();

  static const _userAgent =
      'Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0';

  /// Compute hashes for a batch of cards.
  ///
  /// Downloads each card's art crop URL, crops the art region,
  /// and computes the PHash. Yields [CardHash] results.
  Stream<CardHash> computeHashes(
    List<CachedCard> cards, {
    Set<String> skipIds = const {},
    void Function(int done, int total)? onProgress,
  }) async* {
    var done = 0;
    final total = cards.length;

    for (final card in cards) {
      done++;
      if (skipIds.contains(card.cardId)) continue;

      final artUrl = card.artCropUrl;
      if (artUrl == null || artUrl.isEmpty) continue;

      try {
        final imageBytes = await _downloadImage(artUrl);
        if (imageBytes == null) continue;

        final hash = _computeHashFromBytes(imageBytes, card.game);
        if (hash == null) continue;

        yield CardHash(
          cardId: card.cardId,
          game: card.game,
          phashValue: hash,
          setCode: card.setCode,
        );
      } catch (e) {
        stderr.writeln('  Hash error for ${card.cardId}: $e');
      }

      onProgress?.call(done, total);

      // Brief pause to avoid hammering servers.
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  /// Download an image from URL, returns raw bytes or null on failure.
  Future<Uint8List?> _downloadImage(String url) async {
    try {
      final request = await _http.getUrl(Uri.parse(url));
      request.headers.set('User-Agent', _userAgent);
      final response = await request.close();

      if (response.statusCode != 200) {
        await response.drain<void>();
        return null;
      }

      final chunks = <List<int>>[];
      await for (final chunk in response) {
        chunks.add(chunk);
      }

      var totalLength = 0;
      for (final c in chunks) {
        totalLength += c.length;
      }

      final bytes = Uint8List(totalLength);
      var offset = 0;
      for (final c in chunks) {
        bytes.setRange(offset, offset + c.length, c);
        offset += c.length;
      }

      return bytes;
    } catch (e) {
      return null;
    }
  }

  /// Compute PHash from raw image bytes.
  ///
  /// The art crop URL from Scryfall already gives us the art region,
  /// so we use the full downloaded image directly for hashing.
  int? _computeHashFromBytes(Uint8List bytes, String game) {
    final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);
    if (mat.isEmpty) {
      mat.dispose();
      return null;
    }

    try {
      // PHash expects an input image (any size, it resizes internally to 32x32).
      final hashMat = _hasher.compute(mat);
      final hashValue = _matToInt64(hashMat);
      hashMat.dispose();
      return hashValue;
    } finally {
      mat.dispose();
    }
  }

  /// Convert a PHash result Mat (1×8 CV_8UC1) to a 64-bit integer.
  static int _matToInt64(cv.Mat hashMat) {
    var result = 0;
    final data = hashMat.data;
    for (var i = 0; i < 8 && i < data.length; i++) {
      result |= data[i] << (56 - i * 8);
    }
    return result;
  }

  void close() {
    _http.close();
  }
}
