import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/di.dart';
import '../../../domain/game_mode.dart';

/// Full-screen game mode picker shown on first launch.
class GameModePicker extends ConsumerWidget {
  const GameModePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Manab',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Choose your game to get started',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 48),
              _GameModeCard(
                mode: GameMode.mtg,
                icon: Icons.auto_awesome,
                onTap: () => _selectMode(ref, context, GameMode.mtg),
              ),
              const SizedBox(height: 24),
              _GameModeCard(
                mode: GameMode.pokemon,
                icon: Icons.catching_pokemon,
                onTap: () => _selectMode(ref, context, GameMode.pokemon),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectMode(WidgetRef ref, BuildContext context, GameMode mode) {
    ref.read(gameModeProvider.notifier).setMode(mode);
    context.go('/search');
  }
}

class _GameModeCard extends StatelessWidget {
  const _GameModeCard({
    required this.mode,
    required this.icon,
    required this.onTap,
  });

  final GameMode mode;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 120,
      child: FilledButton.tonal(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: colorScheme.primary),
            const SizedBox(width: 20),
            Text(
              mode.displayName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
