import 'package:flutter/material.dart';

/// Scanner settings: set lock and quick mode.
class ScannerSettingsSheet extends StatefulWidget {
  const ScannerSettingsSheet({
    super.key,
    required this.availableSets,
    required this.lockedSets,
    required this.quickMode,
    required this.onSetLockChanged,
    required this.onQuickModeChanged,
  });

  final List<String> availableSets;
  final Set<String> lockedSets;
  final bool quickMode;
  final void Function(Set<String>) onSetLockChanged;
  final void Function(bool) onQuickModeChanged;

  static Future<void> show(
    BuildContext context, {
    required List<String> availableSets,
    required Set<String> lockedSets,
    required bool quickMode,
    required void Function(Set<String>) onSetLockChanged,
    required void Function(bool) onQuickModeChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (ctx, scrollController) => ScannerSettingsSheet(
          availableSets: availableSets,
          lockedSets: lockedSets,
          quickMode: quickMode,
          onSetLockChanged: onSetLockChanged,
          onQuickModeChanged: onQuickModeChanged,
        ),
      ),
    );
  }

  @override
  State<ScannerSettingsSheet> createState() => _ScannerSettingsSheetState();
}

class _ScannerSettingsSheetState extends State<ScannerSettingsSheet> {
  late Set<String> _lockedSets;
  late bool _quickMode;

  @override
  void initState() {
    super.initState();
    _lockedSets = Set.of(widget.lockedSets);
    _quickMode = widget.quickMode;
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
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Scanner Settings',
            style: theme.textTheme.titleMedium,
          ),
        ),
        const Divider(height: 1),
        // Quick mode toggle.
        SwitchListTile(
          title: const Text('Quick mode'),
          subtitle: const Text('Auto-confirm high confidence matches'),
          value: _quickMode,
          onChanged: (value) {
            setState(() => _quickMode = value);
            widget.onQuickModeChanged(value);
          },
        ),
        const Divider(height: 1),
        // Set lock section.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Set lock',
                style: theme.textTheme.titleSmall,
              ),
              const Spacer(),
              if (_lockedSets.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() => _lockedSets.clear());
                    widget.onSetLockChanged(_lockedSets);
                  },
                  child: const Text('Clear all'),
                ),
            ],
          ),
        ),
        // Set list.
        Expanded(
          child: widget.availableSets.isEmpty
              ? Center(
                  child: Text(
                    'No sets available',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: widget.availableSets.length,
                  itemBuilder: (ctx, index) {
                    final setCode = widget.availableSets[index];
                    final isLocked = _lockedSets.contains(setCode);
                    return CheckboxListTile(
                      title: Text(setCode.toUpperCase()),
                      value: isLocked,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _lockedSets.add(setCode);
                          } else {
                            _lockedSets.remove(setCode);
                          }
                        });
                        widget.onSetLockChanged(_lockedSets);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
