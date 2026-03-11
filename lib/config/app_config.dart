/// Application-wide configuration constants.
class AppConfig {
  AppConfig._();

  static const String appName = 'Manab';
  static const String appVersion = '0.1.0';

  /// User-Agent for API requests (Firefox UA per convention).
  static const String userAgent =
      'Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0';

  /// Standard card image dimensions.
  static const int mtgCardWidth = 672;
  static const int mtgCardHeight = 936;
  static const int pokemonCardWidth = 734;
  static const int pokemonCardHeight = 1024;

  /// Detection pipeline settings.
  static const int detectionDownsampleWidth = 480;
  static const double cannyThreshold1 = 50;
  static const double cannyThreshold2 = 150;
  static const int gaussianBlurSize = 5;

  /// Card aspect ratio (width/height) ~63:88 = 0.7159.
  static const double cardAspectRatio = 63 / 88;
  static const double cardAspectRatioTolerance = 0.15;
}
