import 'package:flutter/material.dart';

import '../../../data/repositories/scanner_repository.dart';

/// Bottom sheet showing the best match with confirm/reject/cycle controls.
class MatchConfirmationSheet extends StatelessWidget {
  const MatchConfirmationSheet({
    super.key,
    required this.candidates,
    required this.currentIndex,
    required this.onConfirm,
    required this.onReject,
    required this.onCycle,
    required this.onPickEdition,
  });

  final List<ScanCandidate> candidates;
  final int currentIndex;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onCycle;
  final VoidCallback onPickEdition;

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) return const SizedBox.shrink();

    final candidate = candidates[currentIndex];
    final card = candidate.card;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card info row.
            Row(
              children: [
                // Card image thumbnail.
                if (card.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      card.imageUrl!,
                      width: 60,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 84,
                        color: Colors.grey[800],
                        child: const Icon(Icons.image_not_supported, size: 24),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.style, size: 24),
                  ),
                const SizedBox(width: 12),
                // Card details.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${card.setName} (${card.setCode.toUpperCase()})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      if (card.priceUsd != null)
                        Text(
                          '\$${card.priceUsd!.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                // Distance indicator.
                Column(
                  children: [
                    _ConfidenceBadge(distance: candidate.distance),
                    if (candidates.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${currentIndex + 1}/${candidates.length}',
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons.
            Row(
              children: [
                // Reject.
                IconButton.outlined(
                  onPressed: onReject,
                  icon: const Icon(Icons.close),
                  tooltip: 'No match',
                ),
                const SizedBox(width: 8),
                // Cycle to next candidate.
                if (candidates.length > 1)
                  IconButton.outlined(
                    onPressed: onCycle,
                    icon: const Icon(Icons.swap_horiz),
                    tooltip: 'Next candidate',
                  ),
                if (candidates.length > 1) const SizedBox(width: 8),
                // Edition picker.
                IconButton.outlined(
                  onPressed: onPickEdition,
                  icon: const Icon(Icons.layers),
                  tooltip: 'Pick edition',
                ),
                const Spacer(),
                // Confirm.
                FilledButton.icon(
                  onPressed: onConfirm,
                  icon: const Icon(Icons.check),
                  label: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.distance});

  final int distance;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    if (distance <= 5) {
      color = Colors.green;
      label = 'High';
    } else if (distance <= 10) {
      color = Colors.orange;
      label = 'Med';
    } else {
      color = Colors.red;
      label = 'Low';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
