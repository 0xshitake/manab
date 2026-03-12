import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../domain/card.dart';

/// A list tile showing card thumbnail, name, set, and price.
class CardListTile extends StatelessWidget {
  const CardListTile({
    super.key,
    required this.card,
    this.onTap,
  });

  final CachedCard card;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 40,
        height: 56,
        child: card.artCropUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: card.artCropUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const ColoredBox(
                    color: Colors.grey,
                    child: Center(
                        child: Icon(Icons.image, size: 20)),
                  ),
                  errorWidget: (_, __, ___) => const ColoredBox(
                    color: Colors.grey,
                    child:
                        Center(child: Icon(Icons.broken_image, size: 20)),
                  ),
                ),
              )
            : const ColoredBox(
                color: Colors.grey,
                child: Center(child: Icon(Icons.style, size: 20)),
              ),
      ),
      title: Text(
        card.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${card.setName} - ${card.rarity}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: card.priceUsd != null
          ? Text(
              '\$${card.priceUsd!.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            )
          : null,
      onTap: onTap,
    );
  }
}
