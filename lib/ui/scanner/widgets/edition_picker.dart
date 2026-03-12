import 'package:flutter/material.dart';

import '../../../domain/card.dart';

/// Dialog showing all printings of a card for edition selection.
class EditionPicker extends StatelessWidget {
  const EditionPicker({
    super.key,
    required this.cardName,
    required this.printings,
    required this.onSelect,
  });

  final String cardName;
  final List<CachedCard> printings;
  final void Function(CachedCard) onSelect;

  /// Show the edition picker as a modal bottom sheet.
  static Future<CachedCard?> show(
    BuildContext context, {
    required String cardName,
    required List<CachedCard> printings,
  }) {
    return showModalBottomSheet<CachedCard>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (ctx, scrollController) => EditionPicker(
          cardName: cardName,
          printings: printings,
          onSelect: (card) => Navigator.of(ctx).pop(card),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Handle bar.
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Title.
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Select edition: $cardName',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const Divider(height: 1),
        // Printing list.
        Expanded(
          child: ListView.builder(
            itemCount: printings.length,
            itemBuilder: (ctx, index) {
              final card = printings[index];
              return ListTile(
                leading: card.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.network(
                          card.imageUrl!,
                          width: 40,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(
                            width: 40,
                            height: 56,
                            child: Icon(Icons.image_not_supported, size: 20),
                          ),
                        ),
                      )
                    : null,
                title: Text(
                  '${card.setName} (${card.setCode.toUpperCase()})',
                ),
                subtitle: Text(
                  '#${card.collectorNumber}'
                  '${card.priceUsd != null ? '  •  \$${card.priceUsd!.toStringAsFixed(2)}' : ''}',
                ),
                onTap: () => onSelect(card),
              );
            },
          ),
        ),
      ],
    );
  }
}
