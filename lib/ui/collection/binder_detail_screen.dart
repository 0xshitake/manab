import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/di.dart';
import '../../domain/binder.dart';
import '../../domain/card_entry.dart';
import 'widgets/card_entry_tile.dart';

/// Displays cards within a binder with sorting and filtering.
class BinderDetailScreen extends ConsumerStatefulWidget {
  const BinderDetailScreen({super.key, required this.binderId});

  final String binderId;

  @override
  ConsumerState<BinderDetailScreen> createState() =>
      _BinderDetailScreenState();
}

class _BinderDetailScreenState extends ConsumerState<BinderDetailScreen> {
  _SortMode _sortMode = _SortMode.dateDesc;
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final binderAsync = ref.watch(_binderProvider(widget.binderId));
    final entriesAsync = ref.watch(_entriesProvider(widget.binderId));

    final binder = binderAsync.value;
    final entries = entriesAsync.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(binder?.name ?? 'Binder'),
        actions: [
          if (entries.isNotEmpty)
            PopupMenuButton<_SortMode>(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort',
              onSelected: (mode) => setState(() => _sortMode = mode),
              itemBuilder: (_) => const [
                PopupMenuItem(
                    value: _SortMode.dateDesc,
                    child: Text('Date added (newest)')),
                PopupMenuItem(
                    value: _SortMode.dateAsc,
                    child: Text('Date added (oldest)')),
                PopupMenuItem(
                    value: _SortMode.nameAsc, child: Text('Name (A-Z)')),
                PopupMenuItem(
                    value: _SortMode.nameDesc, child: Text('Name (Z-A)')),
                PopupMenuItem(
                    value: _SortMode.setAsc, child: Text('Set')),
              ],
            ),
        ],
      ),
      body: entriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('No cards in this binder'));
          }
          return _BinderContents(
            entries: entries,
            sortMode: _sortMode,
            filter: _filter,
            onFilterChanged: (q) => setState(() => _filter = q),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

enum _SortMode { dateDesc, dateAsc, nameAsc, nameDesc, setAsc }

// --- Providers ---

final _binderProvider =
    FutureProvider.family<Binder?, String>((ref, binderId) {
  return ref.watch(appDatabaseProvider).bindersDao.getById(binderId);
});

final _entriesProvider =
    StreamProvider.family<List<CardEntry>, String>((ref, binderId) {
  return ref.watch(binderRepositoryProvider).watchBinderEntries(binderId);
});

// --- Contents Widget ---

class _BinderContents extends ConsumerWidget {
  const _BinderContents({
    required this.entries,
    required this.sortMode,
    required this.filter,
    required this.onFilterChanged,
  });

  final List<CardEntry> entries;
  final _SortMode sortMode;
  final String filter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sorted = _sortAndFilter(entries);
    final totalValue = ref.watch(_binderValueProvider(entries)).value ?? 0.0;

    return Column(
      children: [
        // Header with value
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${entries.length} card${entries.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodyLarge,
              ),
              if (totalValue > 0)
                Text(
                  '\$${totalValue.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
        // Search filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchBar(
            hintText: 'Filter by name...',
            leading: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.search, size: 20),
            ),
            onChanged: onFilterChanged,
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Card list
        Expanded(
          child: ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final entry = sorted[index];
              return CardEntryTile(
                entry: entry,
                onTap: () => context.push(
                  '/card/${Uri.encodeComponent(entry.cardId)}',
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<CardEntry> _sortAndFilter(List<CardEntry> entries) {
    var list = entries.toList();

    if (filter.isNotEmpty) {
      final lower = filter.toLowerCase();
      list = list.where((e) => e.name.toLowerCase().contains(lower)).toList();
    }

    switch (sortMode) {
      case _SortMode.dateDesc:
        list.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      case _SortMode.dateAsc:
        list.sort((a, b) => a.addedAt.compareTo(b.addedAt));
      case _SortMode.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
      case _SortMode.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
      case _SortMode.setAsc:
        list.sort((a, b) {
          final cmp = a.setCode.compareTo(b.setCode);
          if (cmp != 0) return cmp;
          return a.collectorNumber.compareTo(b.collectorNumber);
        });
    }

    return list;
  }
}

/// Computes total value for a list of entries by looking up prices.
final _binderValueProvider =
    FutureProvider.family<double, List<CardEntry>>((ref, entries) async {
  final cardsDao = ref.watch(cardsDaoProvider);
  double total = 0;
  for (final entry in entries) {
    final card = await cardsDao.getById(entry.cardId);
    if (card != null) {
      final price =
          entry.foil ? (card.priceUsdFoil ?? card.priceUsd) : card.priceUsd;
      if (price != null) total += price * entry.quantity;
    }
  }
  return total;
});
