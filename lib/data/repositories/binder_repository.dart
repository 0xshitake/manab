import 'package:uuid/uuid.dart';

import '../../domain/binder.dart';
import '../../domain/card.dart';
import '../../domain/card_entry.dart';
import '../database/daos/binders_dao.dart';
import '../database/daos/card_entries_dao.dart';

/// Abstract binder + card entry data access.
abstract class BinderRepository {
  Stream<List<BinderSummary>> watchBinders(String game);
  Stream<List<Binder>> watchBinderList(String game);
  Future<void> createBinder(String name, String game);
  Future<void> renameBinder(String id, String name);
  Future<void> deleteBinder(String id);
  Future<void> addCardToBinder({
    required String binderId,
    required CachedCard card,
    required String game,
    int quantity = 1,
    bool foil = false,
    String language = 'en',
    String? condition,
    double? purchasePrice,
    String? purchaseCurrency,
    String? notes,
  });
  Future<void> updateEntry(CardEntry entry);
  Future<void> removeEntry(String id);
  Stream<List<CardEntry>> watchBinderEntries(String binderId);
  Future<List<CardEntry>> getEntriesForCard(String cardId);
}

/// Implementation backed by Drift DAOs.
class BinderRepositoryImpl implements BinderRepository {
  BinderRepositoryImpl({
    required BindersDao bindersDao,
    required CardEntriesDao cardEntriesDao,
  })  : _bindersDao = bindersDao,
        _cardEntriesDao = cardEntriesDao;

  final BindersDao _bindersDao;
  final CardEntriesDao _cardEntriesDao;
  static const _uuid = Uuid();

  @override
  Stream<List<BinderSummary>> watchBinders(String game) {
    return _bindersDao.watchWithSummary(game);
  }

  @override
  Stream<List<Binder>> watchBinderList(String game) {
    return _bindersDao.watchAll(game);
  }

  @override
  Future<void> createBinder(String name, String game) {
    final now = DateTime.now();
    return _bindersDao.create(Binder(
      id: _uuid.v4(),
      name: name,
      game: game,
      createdAt: now,
      updatedAt: now,
    ));
  }

  @override
  Future<void> renameBinder(String id, String name) {
    return _bindersDao.rename(id, name);
  }

  @override
  Future<void> deleteBinder(String id) async {
    await _cardEntriesDao.deleteByBinder(id);
    await _bindersDao.deleteById(id);
  }

  @override
  Future<void> addCardToBinder({
    required String binderId,
    required CachedCard card,
    required String game,
    int quantity = 1,
    bool foil = false,
    String language = 'en',
    String? condition,
    double? purchasePrice,
    String? purchaseCurrency,
    String? notes,
  }) {
    final now = DateTime.now();
    return _cardEntriesDao.addCard(CardEntry(
      id: _uuid.v4(),
      binderId: binderId,
      game: game,
      cardId: card.cardId,
      name: card.name,
      setCode: card.setCode,
      setName: card.setName,
      collectorNumber: card.collectorNumber,
      quantity: quantity,
      foil: foil,
      language: language,
      condition: condition,
      purchasePrice: purchasePrice,
      purchaseCurrency: purchaseCurrency,
      notes: notes,
      imageUrl: card.imageUrl,
      addedAt: now,
      updatedAt: now,
    ));
  }

  @override
  Future<void> updateEntry(CardEntry entry) {
    return _cardEntriesDao.updateCard(entry);
  }

  @override
  Future<void> removeEntry(String id) {
    return _cardEntriesDao.removeCard(id);
  }

  @override
  Stream<List<CardEntry>> watchBinderEntries(String binderId) {
    return _cardEntriesDao.watchByBinder(binderId);
  }

  @override
  Future<List<CardEntry>> getEntriesForCard(String cardId) {
    return _cardEntriesDao.getByCardId(cardId);
  }
}
