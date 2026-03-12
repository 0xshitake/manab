import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/di.dart';
import '../../domain/card.dart';
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
    );
  }
}

final _cardDetailProvider =
    FutureProvider.family<CachedCard?, String>((ref, cardId) {
  return ref.watch(cardsDaoProvider).getById(cardId);
});

class _CardDetailBody extends StatelessWidget {
  const _CardDetailBody({required this.card});

  final CachedCard card;

  @override
  Widget build(BuildContext context) {
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
