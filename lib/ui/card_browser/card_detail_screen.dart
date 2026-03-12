import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/di.dart';
import '../../domain/card.dart';
import '../../domain/card_entry.dart';
import '../collection/widgets/add_to_binder_sheet.dart';
import 'widgets/price_display.dart';

/// Shows full card details including image, set, rarity, type, and prices.
class CardDetailScreen extends ConsumerWidget {
  const CardDetailScreen({super.key, required this.cardId});

  final String cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardFuture = ref.watch(_cardDetailProvider(cardId));

    return Scaffold(
      appBar: AppBar(title: const Text('Card Details')),
      body: cardFuture.when(
        data: (card) {
          if (card == null) {
            return const Center(child: Text('Card not found'));
          }
          return _CardDetailBody(card: card);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: cardFuture.value != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                final card = cardFuture.value!;
                final added = await AddToBinderSheet.show(context, card);
                if (added == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Card added to binder')),
                  );
                  ref.invalidate(_cardBindersProvider(cardId));
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add to binder'),
            )
          : null,
    );
  }
}

final _cardDetailProvider =
    FutureProvider.family<CachedCard?, String>((ref, cardId) {
  return ref.watch(cardsDaoProvider).getById(cardId);
});

/// Watches which binders contain this card.
final _cardBindersProvider =
    FutureProvider.family<List<_CardInBinder>, String>((ref, cardId) async {
  final entries =
      await ref.watch(binderRepositoryProvider).getEntriesForCard(cardId);
  final db = ref.watch(appDatabaseProvider);

  final results = <_CardInBinder>[];
  for (final entry in entries) {
    final binder = await db.bindersDao.getById(entry.binderId);
    if (binder != null) {
      results.add(_CardInBinder(binderName: binder.name, entry: entry));
    }
  }
  return results;
});

class _CardInBinder {
  final String binderName;
  final CardEntry entry;

  const _CardInBinder({required this.binderName, required this.entry});
}

class _CardDetailBody extends ConsumerWidget {
  const _CardDetailBody({required this.card});

  final CachedCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bindersAsync = ref.watch(_cardBindersProvider(card.cardId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card image
          if (card.imageUrl != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: card.imageUrl!,
                  width: 300,
                  placeholder: (_, __) => const SizedBox(
                    width: 300,
                    height: 418,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => const SizedBox(
                    width: 300,
                    height: 418,
                    child: Center(child: Icon(Icons.broken_image, size: 48)),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Card name
          Text(card.name,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),

          // Set and rarity
          _InfoRow(label: 'Set', value: '${card.setName} (${card.setCode})'),
          _InfoRow(label: 'Number', value: card.collectorNumber),
          _InfoRow(label: 'Rarity', value: card.rarity),
          if (card.typeLine != null)
            _InfoRow(label: 'Type', value: card.typeLine!),
          const SizedBox(height: 16),

          // Prices
          PriceDisplay(card: card),

          // Binders containing this card
          bindersAsync.when(
            data: (binders) {
              if (binders.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text('In your collection',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final item in binders)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.folder_outlined, size: 20),
                      title: Text(item.binderName),
                      subtitle: Text(
                        'x${item.entry.quantity}'
                        '${item.entry.foil ? ', Foil' : ''}'
                        '${item.entry.condition != null ? ', ${item.entry.condition!.toUpperCase()}' : ''}',
                      ),
                    ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Padding for FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
