import 'package:flutter/material.dart';

import '../../../domain/card.dart';

/// An entry in the scan session.
class SessionEntry {
  final CachedCard card;
  int quantity;

  SessionEntry({required this.card, this.quantity = 1});

  String get key => card.cardId;
}

/// Scrollable summary of all cards scanned in the current session.
class ScanSessionSummary extends StatelessWidget {
  const ScanSessionSummary({
    super.key,
    required this.entries,
    required this.onRemove,
    required this.onUpdateQuantity,
    required this.onCommit,
  });

  final List<SessionEntry> entries;
  final void Function(int index) onRemove;
  final void Function(int index, int delta) onUpdateQuantity;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCards =
        entries.fold<int>(0, (sum, e) => sum + e.quantity);
    final totalValue = entries.fold<double>(
      0,
      (sum, e) => sum + (e.card.priceUsd ?? 0) * e.quantity,
    );

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
        // Header with totals.
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '$totalCards cards',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '\$${totalValue.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Card list.
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: Text(
                    'No cards scanned yet',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (ctx, index) {
                    final entry = entries[index];
                    final card = entry.card;
                    return ListTile(
                      leading: card.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Image.network(
                                card.imageUrl!,
                                width: 40,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox(width: 40, height: 56),
                              ),
                            )
                          : null,
                      title: Text(card.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${card.setName} (${card.setCode.toUpperCase()})'
                        '${card.priceUsd != null ? '  •  \$${card.priceUsd!.toStringAsFixed(2)}' : ''}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 20),
                            onPressed: entry.quantity > 1
                                ? () => onUpdateQuantity(index, -1)
                                : () => onRemove(index),
                          ),
                          Text(
                            '${entry.quantity}',
                            style: theme.textTheme.bodyLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 20),
                            onPressed: () => onUpdateQuantity(index, 1),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        // Commit button.
        if (entries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCommit,
                icon: const Icon(Icons.save),
                label: const Text('Save to binder'),
              ),
            ),
          ),
      ],
    );
  }
}
