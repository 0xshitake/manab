import 'package:flutter/material.dart';

/// Search input for card name queries.
class CardSearchBar extends StatelessWidget {
  const CardSearchBar({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SearchBar(
        hintText: 'Search cards by name...',
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Icon(Icons.search),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
