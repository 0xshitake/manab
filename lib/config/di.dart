import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database/app_database.dart';
import '../data/database/daos/binders_dao.dart';
import '../data/database/daos/card_entries_dao.dart';
import '../data/database/daos/card_hashes_dao.dart';
import '../data/database/daos/cards_dao.dart';
import '../data/repositories/binder_repository.dart';
import '../data/repositories/card_repository.dart';
import '../data/repositories/scanner_repository.dart';
import '../data/services/export_service.dart';
import '../data/services/scryfall_api_service.dart';
import '../data/services/scanner_service.dart';
import '../data/services/tcgdex_api_service.dart';
import '../domain/game_mode.dart';

/// Global Riverpod providers for dependency injection.

// --- Shared Preferences ---

/// Must be overridden in main() with the actual instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override sharedPreferencesProvider in main');
});

// --- Database ---

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'cards.db'));
    return NativeDatabase.createInBackground(file);
  }));
  ref.onDispose(() => db.close());
  return db;
});

final cardsDaoProvider = Provider<CardsDao>((ref) {
  return ref.watch(appDatabaseProvider).cardsDao;
});

final bindersDaoProvider = Provider<BindersDao>((ref) {
  return ref.watch(appDatabaseProvider).bindersDao;
});

final cardEntriesDaoProvider = Provider<CardEntriesDao>((ref) {
  return ref.watch(appDatabaseProvider).cardEntriesDao;
});

final cardHashesDaoProvider = Provider<CardHashesDao>((ref) {
  return ref.watch(appDatabaseProvider).cardHashesDao;
});

// --- API Services ---

final scryfallApiServiceProvider = Provider<ScryfallApiService>((ref) {
  return ScryfallApiService();
});

final tcgdexApiServiceProvider = Provider<TcgdexApiService>((ref) {
  return TcgdexApiService();
});

// --- Repositories ---

final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepositoryImpl(
    cardsDao: ref.watch(cardsDaoProvider),
    scryfallApi: ref.watch(scryfallApiServiceProvider),
    tcgdexApi: ref.watch(tcgdexApiServiceProvider),
  );
});

final binderRepositoryProvider = Provider<BinderRepository>((ref) {
  return BinderRepositoryImpl(
    bindersDao: ref.watch(bindersDaoProvider),
    cardEntriesDao: ref.watch(cardEntriesDaoProvider),
  );
});

final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  return ScannerRepositoryImpl(
    cardHashesDao: ref.watch(cardHashesDaoProvider),
    cardsDao: ref.watch(cardsDaoProvider),
  );
});

// --- Services ---

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(
    bindersDao: ref.watch(bindersDaoProvider),
    cardEntriesDao: ref.watch(cardEntriesDaoProvider),
  );
});

// --- Game Mode ---

final gameModeProvider =
    NotifierProvider<GameModeNotifier, GameMode?>(GameModeNotifier.new);

class GameModeNotifier extends Notifier<GameMode?> {
  @override
  GameMode? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final value = prefs.getString('game_mode');
    if (value == null) return null;
    return GameMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => GameMode.mtg,
    );
  }

  Future<void> setMode(GameMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('game_mode', mode.name);
    state = mode;
  }
}

// --- Scanner ---

final scannerServiceProvider = Provider<ScannerService>((ref) {
  return ScannerService();
});
