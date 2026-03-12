import 'package:flutter/material.dart';

import '../../../domain/card.dart';

/// Displays card prices in a grid: USD + EUR, regular + foil.
class PriceDisplay extends StatelessWidget {
  const PriceDisplay({super.key, required this.card});

  final CachedCard card;

  @override
  Widget build(BuildContext context) {
    final hasAnyPrice = card.priceUsd != null ||
        card.priceUsdFoil != null ||
        card.priceEur != null ||
        card.priceEurFoil != null;

    if (!hasAnyPrice) {
      return Text(
        'No price data available',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prices',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PriceColumn(
                    header: 'USD',
                    regular: card.priceUsd,
                    foil: card.priceUsdFoil,
                    symbol: '\$',
                  ),
                ),
                Expanded(
                  child: _PriceColumn(
                    header: 'EUR',
                    regular: card.priceEur,
                    foil: card.priceEurFoil,
                    symbol: '\u20AC',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceColumn extends StatelessWidget {
  const _PriceColumn({
    required this.header,
    required this.regular,
    required this.foil,
    required this.symbol,
  });

  final String header;
  final double? regular;
  final double? foil;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                )),
        const SizedBox(height: 4),
        _PriceRow(label: 'Regular', value: regular, symbol: symbol),
        _PriceRow(label: 'Foil', value: foil, symbol: symbol),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    required this.symbol,
  });

  final String label;
  final double? value;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ',
              style: Theme.of(context).textTheme.bodySmall),
          Text(
            value != null
                ? '$symbol${value!.toStringAsFixed(2)}'
                : '\u2014',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
