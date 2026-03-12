import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/di.dart';
import 'card_browser_view_model.dart';
import 'widgets/card_list_tile.dart';
import 'widgets/card_search_bar.dart';

/// Main card search/browse screen.
class CardBrowserScreen extends ConsumerWidget {
  const CardBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cardBrowserViewModelProvider);
    final gameMode = ref.watch(gameModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(gameMode?.displayName ?? 'Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => context.push('/scanner'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          CardSearchBar(
            onChanged: (query) {
              ref
                  .read(cardBrowserViewModelProvider.notifier)
                  .search(query);
            },
          ),
          if (state.isLoading && state.results.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else if (state.query.isNotEmpty && state.results.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No cards found for "${state.query}"',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: state.results.length,
                itemBuilder: (context, index) {
                  final card = state.results[index];
                  return CardListTile(
                    card: card,
                    onTap: () => context.push(
                      '/card/${Uri.encodeComponent(card.cardId)}',
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
