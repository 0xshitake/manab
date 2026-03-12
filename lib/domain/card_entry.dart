/// A card instance within a binder, with collection metadata.
///
/// Pure domain model — no Flutter or Drift imports.
/// Stores denormalized card name/set for offline display.
class CardEntry {
  final String id;
  final String binderId;
  final String game;
  final String cardId;
  final String name;
  final String setCode;
  final String setName;
  final String collectorNumber;
  final int quantity;
  final bool foil;
  final String language;
  final String? condition;
  final double? purchasePrice;
  final String? purchaseCurrency;
  final String? notes;
  final String? imageUrl;
  final DateTime addedAt;
  final DateTime updatedAt;

  const CardEntry({
    required this.id,
    required this.binderId,
    required this.game,
    required this.cardId,
    required this.name,
    required this.setCode,
    required this.setName,
    required this.collectorNumber,
    required this.quantity,
    required this.foil,
    required this.language,
    this.condition,
    this.purchasePrice,
    this.purchaseCurrency,
    this.notes,
    this.imageUrl,
    required this.addedAt,
    required this.updatedAt,
  });
}

/// Card condition grades for collection tracking.
enum CardCondition {
  nm('Near Mint'),
  lp('Lightly Played'),
  mp('Moderately Played'),
  hp('Heavily Played'),
  dmg('Damaged');

  const CardCondition(this.displayName);

  final String displayName;
}
