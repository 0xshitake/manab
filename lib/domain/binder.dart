/// A named collection of cards, scoped to a game mode.
///
/// Pure domain model — no Flutter or Drift imports.
class Binder {
  final String id;
  final String name;
  final String game;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Binder({
    required this.id,
    required this.name,
    required this.game,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// Binder with computed card count and total collection value.
class BinderSummary {
  final Binder binder;
  final int cardCount;
  final double totalValue;

  const BinderSummary({
    required this.binder,
    required this.cardCount,
    required this.totalValue,
  });
}
