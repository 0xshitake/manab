import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/di.dart';
import '../../domain/card.dart';

final cardBrowserViewModelProvider =
    NotifierProvider<CardBrowserViewModel, CardBrowserState>(
        CardBrowserViewModel.new);

class CardBrowserState {
  const CardBrowserState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
  });

  final String query;
  final List<CachedCard> results;
  final bool isLoading;
}

class CardBrowserViewModel extends Notifier<CardBrowserState> {
  Timer? _debounce;
  StreamSubscription<List<CachedCard>>? _searchSub;

  @override
  CardBrowserState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _searchSub?.cancel();
    });
    return const CardBrowserState();
  }

  void search(String query) {
    state = CardBrowserState(
      query: query,
      results: state.results,
      isLoading: true,
    );

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _executeSearch(query);
    });
  }

  void _executeSearch(String query) {
    _searchSub?.cancel();

    if (query.isEmpty) {
      state = const CardBrowserState();
      return;
    }

    final gameMode = ref.read(gameModeProvider);
    if (gameMode == null) return;

    final dao = ref.read(cardsDaoProvider);
    _searchSub = dao.searchByName(gameMode.name, query).listen(
      (results) {
        state = CardBrowserState(
          query: query,
          results: results,
          isLoading: false,
        );
      },
      onError: (_) {
        state = CardBrowserState(
          query: query,
          results: const [],
          isLoading: false,
        );
      },
    );
  }
}
