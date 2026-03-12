import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../domain/card_entry.dart';

/// A list tile displaying a card entry in a binder.
class CardEntryTile extends StatelessWidget {
  const CardEntryTile({
    super.key,
    required this.entry,
    this.priceUsd,
    required this.onTap,
  });

  final CardEntry entry;
  final double? priceUsd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: SizedBox(
        width: 40,
        height: 56,
        child: entry.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: entry.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const _Placeholder(),
                  errorWidget: (_, __, ___) => const _Placeholder(),
                ),
              )
            : const _Placeholder(),
      ),
      title: Text(entry.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Row(
        children: [
          Text('${entry.setName} #${entry.collectorNumber}'),
          if (entry.foil) ...[
            const SizedBox(width: 6),
            Icon(Icons.auto_awesome, size: 14, color: theme.colorScheme.primary),
          ],
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (entry.quantity > 1)
            Text('x${entry.quantity}', style: theme.textTheme.bodyMedium),
          if (priceUsd != null)
            Text(
              '\$${priceUsd!.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(child: Icon(Icons.image, size: 20)),
    );
  }
}
