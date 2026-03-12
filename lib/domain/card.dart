/// A cached card from Scryfall (MTG) or TCGdex (Pokemon).
///
/// Pure domain model — no Flutter or Drift imports.
class CachedCard {
  final String cardId;
  final String game;
  final String name;
  final String setCode;
  final String setName;
  final String collectorNumber;
  final String? typeLine;
  final String rarity;
  final String? imageUrl;
  final String? artCropUrl;
  final double? priceUsd;
  final double? priceUsdFoil;
  final double? priceEur;
  final double? priceEurFoil;
  final String language;
  final DateTime cachedAt;

  const CachedCard({
    required this.cardId,
    required this.game,
    required this.name,
    required this.setCode,
    required this.setName,
    required this.collectorNumber,
    this.typeLine,
    required this.rarity,
    this.imageUrl,
    this.artCropUrl,
    this.priceUsd,
    this.priceUsdFoil,
    this.priceEur,
    this.priceEurFoil,
    required this.language,
    required this.cachedAt,
  });
}
