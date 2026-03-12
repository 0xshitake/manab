import 'package:flutter/material.dart';

import '../../../domain/binder.dart';

/// A list tile showing a binder with card count and total value.
class BinderListTile extends StatelessWidget {
  const BinderListTile({
    super.key,
    required this.summary,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  final BinderSummary summary;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: const Icon(Icons.folder_outlined, size: 40),
      title: Text(summary.binder.name),
      subtitle: Text(
        '${summary.cardCount} card${summary.cardCount == 1 ? '' : 's'}',
      ),
      trailing: summary.totalValue > 0
          ? Text(
              '\$${summary.totalValue.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            )
          : null,
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.of(context).pop();
                onRename();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              title: Text('Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.of(context).pop();
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
