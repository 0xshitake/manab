/// A perceptual hash of a card's art crop for scanner matching.
///
/// Pure domain model — no Flutter or Drift imports.
class CardHash {
  final String cardId;
  final String game;
  final int phashValue;
  final String setCode;

  const CardHash({
    required this.cardId,
    required this.game,
    required this.phashValue,
    required this.setCode,
  });
}
