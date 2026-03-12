import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/di.dart';
import '../../domain/binder.dart';
import 'collection_view_model.dart';
import 'widgets/binder_create_dialog.dart';
import 'widgets/binder_list_tile.dart';

/// Home screen showing the user's binder collection.
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(collectionViewModelProvider);
    final gameMode = ref.watch(gameModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(gameMode?.displayName ?? 'Collection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search cards',
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: 'Scan card',
            onPressed: () => context.push('/scanner'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.binders.isEmpty
              ? _EmptyState()
              : _BinderList(state: state),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createBinder(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createBinder(BuildContext context, WidgetRef ref) async {
    final name = await BinderCreateDialog.show(context);
    if (name != null) {
      ref.read(collectionViewModelProvider.notifier).createBinder(name);
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'No binders yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first binder',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _BinderList extends ConsumerWidget {
  const _BinderList({required this.state});

  final CollectionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Collection summary header
        if (state.totalCards > 0)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.totalCards} card${state.totalCards == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (state.totalValue > 0)
                  Text(
                    'Total: \$${state.totalValue.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: state.binders.length,
            itemBuilder: (context, index) {
              final summary = state.binders[index];
              return BinderListTile(
                summary: summary,
                onTap: () => context.push('/binder/${summary.binder.id}'),
                onRename: () => _rename(context, ref, summary),
                onDelete: () => _delete(context, ref, summary),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _rename(
      BuildContext context, WidgetRef ref, BinderSummary summary) async {
    final name = await BinderCreateDialog.show(
      context,
      initialName: summary.binder.name,
      title: 'Rename Binder',
      confirmLabel: 'Rename',
    );
    if (name != null) {
      ref
          .read(collectionViewModelProvider.notifier)
          .renameBinder(summary.binder.id, name);
    }
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, BinderSummary summary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Binder'),
        content: Text(
          'Delete "${summary.binder.name}" and all ${summary.cardCount} cards in it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref
          .read(collectionViewModelProvider.notifier)
          .deleteBinder(summary.binder.id);
    }
  }
}
