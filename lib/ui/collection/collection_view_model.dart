import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/di.dart';
import '../../domain/binder.dart';

/// State for the collection home screen.
class CollectionState {
  final List<BinderSummary> binders;
  final bool isLoading;

  const CollectionState({
    this.binders = const [],
    this.isLoading = true,
  });

  CollectionState copyWith({
    List<BinderSummary>? binders,
    bool? isLoading,
  }) {
    return CollectionState(
      binders: binders ?? this.binders,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Total value across all binders.
  double get totalValue =>
      binders.fold(0.0, (sum, b) => sum + b.totalValue);

  /// Total card count across all binders.
  int get totalCards =>
      binders.fold(0, (sum, b) => sum + b.cardCount);
}

final collectionViewModelProvider =
    NotifierProvider<CollectionViewModel, CollectionState>(
  CollectionViewModel.new,
);

class CollectionViewModel extends Notifier<CollectionState> {
  StreamSubscription<List<BinderSummary>>? _sub;

  @override
  CollectionState build() {
    ref.onDispose(() => _sub?.cancel());

    final gameMode = ref.watch(gameModeProvider);
    if (gameMode == null) return const CollectionState(isLoading: false);

    final repo = ref.watch(binderRepositoryProvider);
    _sub?.cancel();
    _sub = repo.watchBinders(gameMode.name).listen((binders) {
      state = state.copyWith(binders: binders, isLoading: false);
    });

    return const CollectionState();
  }

  Future<void> createBinder(String name) async {
    final gameMode = ref.read(gameModeProvider);
    if (gameMode == null) return;
    final repo = ref.read(binderRepositoryProvider);
    await repo.createBinder(name, gameMode.name);
  }

  Future<void> renameBinder(String id, String newName) async {
    final repo = ref.read(binderRepositoryProvider);
    await repo.renameBinder(id, newName);
  }

  Future<void> deleteBinder(String id) async {
    final repo = ref.read(binderRepositoryProvider);
    await repo.deleteBinder(id);
  }
}
