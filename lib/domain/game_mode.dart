/// The active trading card game mode.
enum GameMode {
  mtg('Magic: The Gathering'),
  pokemon('Pokemon TCG');

  const GameMode(this.displayName);

  final String displayName;

  /// Standard card image dimensions for this game.
  (int width, int height) get cardSize => switch (this) {
        GameMode.mtg => (672, 936),
        GameMode.pokemon => (734, 1024),
      };
}
