import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ui/card_browser/card_browser_screen.dart';
import '../ui/card_browser/card_detail_screen.dart';
import '../ui/core/widgets/game_mode_picker.dart';
import '../ui/first_launch/first_launch_screen.dart';
import '../ui/scanner/scanner_screen.dart';
import '../ui/settings/settings_screen.dart';
import 'di.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Read once — don't watch, so GoRouter isn't recreated on game mode change.
  final initialGameMode = ref.read(gameModeProvider);

  return GoRouter(
    initialLocation: initialGameMode == null ? '/welcome' : '/search',
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const GameModePicker(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const FirstLaunchScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const CardBrowserScreen(),
      ),
      GoRoute(
        path: '/card/:id',
        builder: (context, state) {
          final cardId = Uri.decodeComponent(state.pathParameters['id']!);
          return CardDetailScreen(cardId: cardId);
        },
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
