import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/di.dart';
import '../../../domain/binder.dart';
import '../../../domain/card.dart';
import '../../../domain/card_entry.dart';
import 'binder_create_dialog.dart';

/// Bottom sheet for adding a card to a binder with metadata.
class AddToBinderSheet extends ConsumerStatefulWidget {
  const AddToBinderSheet({super.key, required this.card});

  final CachedCard card;

  /// Shows the bottom sheet. Returns true if a card was added.
  static Future<bool?> show(BuildContext context, CachedCard card) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddToBinderSheet(card: card),
    );
  }

  @override
  ConsumerState<AddToBinderSheet> createState() => _AddToBinderSheetState();
}

class _AddToBinderSheetState extends ConsumerState<AddToBinderSheet> {
  String? _selectedBinderId;
  int _quantity = 1;
  bool _foil = false;
  String _language = 'en';
  String? _condition;
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  static const _languages = [
    ('en', 'English'),
    ('ja', 'Japanese'),
    ('ko', 'Korean'),
    ('fr', 'French'),
    ('de', 'German'),
    ('it', 'Italian'),
    ('pt', 'Portuguese'),
    ('es', 'Spanish'),
    ('ru', 'Russian'),
    ('zhs', 'Chinese (S)'),
    ('zht', 'Chinese (T)'),
  ];

  @override
  void dispose() {
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameMode = ref.watch(gameModeProvider);
    final bindersStream = gameMode != null
        ? ref.watch(binderRepositoryProvider).watchBinderList(gameMode.name)
        : const Stream<List<Binder>>.empty();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: StreamBuilder<List<Binder>>(
        stream: bindersStream,
        builder: (context, snapshot) {
          final binders = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add to Binder',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),

                // Binder picker
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedBinderId,
                        decoration: const InputDecoration(
                          labelText: 'Binder',
                          border: OutlineInputBorder(),
                        ),
                        items: binders
                            .map((b) => DropdownMenuItem(
                                  value: b.id,
                                  child: Text(b.name),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedBinderId = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.add),
                      tooltip: 'New binder',
                      onPressed: () async {
                        final name =
                            await BinderCreateDialog.show(context);
                        if (name != null && context.mounted) {
                          await ref
                              .read(binderRepositoryProvider)
                              .createBinder(name, gameMode!.name);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quantity + Foil row
                Row(
                  children: [
                    // Quantity
                    Expanded(
                      child: Row(
                        children: [
                          const Text('Qty: '),
                          IconButton.outlined(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: _quantity > 1
                                ? () =>
                                    setState(() => _quantity--)
                                : null,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('$_quantity',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium),
                          ),
                          IconButton.outlined(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () =>
                                setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ),
                    // Foil toggle
                    Row(
                      children: [
                        const Text('Foil'),
                        Switch(
                          value: _foil,
                          onChanged: (v) => setState(() => _foil = v),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Language + Condition row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _language,
                        decoration: const InputDecoration(
                          labelText: 'Language',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _languages
                            .map((l) => DropdownMenuItem(
                                  value: l.$1,
                                  child: Text(l.$2),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _language = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: _condition,
                        decoration: const InputDecoration(
                          labelText: 'Condition',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                              value: null, child: Text('—')),
                          for (final c in CardCondition.values)
                            DropdownMenuItem<String?>(
                              value: c.name,
                              child: Text(c.name.toUpperCase()),
                            ),
                        ],
                        onChanged: (v) =>
                            setState(() => _condition = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Purchase price
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Purchase price (optional)',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                ),
                const SizedBox(height: 12),

                // Notes
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Add button
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add to Binder'),
                  onPressed:
                      _selectedBinderId != null ? _addCard : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _addCard() async {
    final price = double.tryParse(_priceController.text);
    final notes =
        _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
    final gameMode = ref.read(gameModeProvider);

    await ref.read(binderRepositoryProvider).addCardToBinder(
          binderId: _selectedBinderId!,
          card: widget.card,
          game: gameMode!.name,
          quantity: _quantity,
          foil: _foil,
          language: _language,
          condition: _condition,
          purchasePrice: price,
          purchaseCurrency: price != null ? 'USD' : null,
          notes: notes,
        );

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }
}
