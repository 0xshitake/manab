import 'package:go_router/go_router.dart';

import '../ui/scanner/scanner_screen.dart';

final router = GoRouter(
  initialLocation: '/scanner',
  routes: [
    GoRoute(
      path: '/scanner',
      builder: (context, state) => const ScannerScreen(),
    ),
  ],
);
