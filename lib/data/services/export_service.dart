import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/binder.dart';
import '../../domain/card_entry.dart';
import '../database/daos/binders_dao.dart';
import '../database/daos/card_entries_dao.dart';

/// Exports the full collection to JSON.
class ExportService {
  ExportService({
    required BindersDao bindersDao,
    required CardEntriesDao cardEntriesDao,
  })  : _bindersDao = bindersDao,
        _cardEntriesDao = cardEntriesDao;

  final BindersDao _bindersDao;
  final CardEntriesDao _cardEntriesDao;

  /// Export all binders and their cards to a JSON file.
  /// Returns the file path of the exported JSON.
  Future<String> exportToJson() async {
    final mtgBinders = await _bindersDao.watchAll('mtg').first;
    final pokemonBinders = await _bindersDao.watchAll('pokemon').first;
    final allBinders = [...mtgBinders, ...pokemonBinders];

    final bindersJson = <Map<String, dynamic>>[];

    for (final binder in allBinders) {
      final entries = await _cardEntriesDao.watchByBinder(binder.id).first;
      bindersJson.add(_binderToJson(binder, entries));
    }

    final export = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'binders': bindersJson,
    };

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = p.join(dir.path, 'manab_export_$timestamp.json');
    final file = File(filePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(export),
    );

    return filePath;
  }

  Map<String, dynamic> _binderToJson(Binder binder, List<CardEntry> entries) {
    return {
      'id': binder.id,
      'name': binder.name,
      'game': binder.game,
      'createdAt': binder.createdAt.toIso8601String(),
      'updatedAt': binder.updatedAt.toIso8601String(),
      'cards': entries.map(_entryToJson).toList(),
    };
  }

  Map<String, dynamic> _entryToJson(CardEntry e) {
    return {
      'id': e.id,
      'cardId': e.cardId,
      'name': e.name,
      'setCode': e.setCode,
      'setName': e.setName,
      'collectorNumber': e.collectorNumber,
      'quantity': e.quantity,
      'foil': e.foil,
      'language': e.language,
      if (e.condition != null) 'condition': e.condition,
      if (e.purchasePrice != null) 'purchasePrice': e.purchasePrice,
      if (e.purchaseCurrency != null) 'purchaseCurrency': e.purchaseCurrency,
      if (e.notes != null) 'notes': e.notes,
      'addedAt': e.addedAt.toIso8601String(),
      'updatedAt': e.updatedAt.toIso8601String(),
    };
  }
}
