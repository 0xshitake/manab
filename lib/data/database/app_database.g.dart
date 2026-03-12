// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedCardsTable extends CachedCards
    with TableInfo<$CachedCardsTable, CachedCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameMeta = const VerificationMeta('game');
  @override
  late final GeneratedColumn<String> game = GeneratedColumn<String>(
    'game',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setCodeMeta = const VerificationMeta(
    'setCode',
  );
  @override
  late final GeneratedColumn<String> setCode = GeneratedColumn<String>(
    'set_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setNameMeta = const VerificationMeta(
    'setName',
  );
  @override
  late final GeneratedColumn<String> setName = GeneratedColumn<String>(
    'set_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectorNumberMeta = const VerificationMeta(
    'collectorNumber',
  );
  @override
  late final GeneratedColumn<String> collectorNumber = GeneratedColumn<String>(
    'collector_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeLineMeta = const VerificationMeta(
    'typeLine',
  );
  @override
  late final GeneratedColumn<String> typeLine = GeneratedColumn<String>(
    'type_line',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<String> rarity = GeneratedColumn<String>(
    'rarity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artCropUrlMeta = const VerificationMeta(
    'artCropUrl',
  );
  @override
  late final GeneratedColumn<String> artCropUrl = GeneratedColumn<String>(
    'art_crop_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceUsdMeta = const VerificationMeta(
    'priceUsd',
  );
  @override
  late final GeneratedColumn<double> priceUsd = GeneratedColumn<double>(
    'price_usd',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceUsdFoilMeta = const VerificationMeta(
    'priceUsdFoil',
  );
  @override
  late final GeneratedColumn<double> priceUsdFoil = GeneratedColumn<double>(
    'price_usd_foil',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceEurMeta = const VerificationMeta(
    'priceEur',
  );
  @override
  late final GeneratedColumn<double> priceEur = GeneratedColumn<double>(
    'price_eur',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceEurFoilMeta = const VerificationMeta(
    'priceEurFoil',
  );
  @override
  late final GeneratedColumn<double> priceEurFoil = GeneratedColumn<double>(
    'price_eur_foil',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    cardId,
    game,
    name,
    setCode,
    setName,
    collectorNumber,
    typeLine,
    rarity,
    imageUrl,
    artCropUrl,
    priceUsd,
    priceUsdFoil,
    priceEur,
    priceEurFoil,
    language,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('game')) {
      context.handle(
        _gameMeta,
        game.isAcceptableOrUnknown(data['game']!, _gameMeta),
      );
    } else if (isInserting) {
      context.missing(_gameMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('set_code')) {
      context.handle(
        _setCodeMeta,
        setCode.isAcceptableOrUnknown(data['set_code']!, _setCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_setCodeMeta);
    }
    if (data.containsKey('set_name')) {
      context.handle(
        _setNameMeta,
        setName.isAcceptableOrUnknown(data['set_name']!, _setNameMeta),
      );
    } else if (isInserting) {
      context.missing(_setNameMeta);
    }
    if (data.containsKey('collector_number')) {
      context.handle(
        _collectorNumberMeta,
        collectorNumber.isAcceptableOrUnknown(
          data['collector_number']!,
          _collectorNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectorNumberMeta);
    }
    if (data.containsKey('type_line')) {
      context.handle(
        _typeLineMeta,
        typeLine.isAcceptableOrUnknown(data['type_line']!, _typeLineMeta),
      );
    }
    if (data.containsKey('rarity')) {
      context.handle(
        _rarityMeta,
        rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta),
      );
    } else if (isInserting) {
      context.missing(_rarityMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('art_crop_url')) {
      context.handle(
        _artCropUrlMeta,
        artCropUrl.isAcceptableOrUnknown(
          data['art_crop_url']!,
          _artCropUrlMeta,
        ),
      );
    }
    if (data.containsKey('price_usd')) {
      context.handle(
        _priceUsdMeta,
        priceUsd.isAcceptableOrUnknown(data['price_usd']!, _priceUsdMeta),
      );
    }
    if (data.containsKey('price_usd_foil')) {
      context.handle(
        _priceUsdFoilMeta,
        priceUsdFoil.isAcceptableOrUnknown(
          data['price_usd_foil']!,
          _priceUsdFoilMeta,
        ),
      );
    }
    if (data.containsKey('price_eur')) {
      context.handle(
        _priceEurMeta,
        priceEur.isAcceptableOrUnknown(data['price_eur']!, _priceEurMeta),
      );
    }
    if (data.containsKey('price_eur_foil')) {
      context.handle(
        _priceEurFoilMeta,
        priceEurFoil.isAcceptableOrUnknown(
          data['price_eur_foil']!,
          _priceEurFoilMeta,
        ),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId};
  @override
  CachedCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedCard(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      game: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      setCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_code'],
      )!,
      setName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_name'],
      )!,
      collectorNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_number'],
      )!,
      typeLine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_line'],
      ),
      rarity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rarity'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      artCropUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}art_crop_url'],
      ),
      priceUsd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_usd'],
      ),
      priceUsdFoil: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_usd_foil'],
      ),
      priceEur: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_eur'],
      ),
      priceEurFoil: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_eur_foil'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedCardsTable createAlias(String alias) {
    return $CachedCardsTable(attachedDatabase, alias);
  }
}

class CachedCardsCompanion extends UpdateCompanion<CachedCard> {
  final Value<String> cardId;
  final Value<String> game;
  final Value<String> name;
  final Value<String> setCode;
  final Value<String> setName;
  final Value<String> collectorNumber;
  final Value<String?> typeLine;
  final Value<String> rarity;
  final Value<String?> imageUrl;
  final Value<String?> artCropUrl;
  final Value<double?> priceUsd;
  final Value<double?> priceUsdFoil;
  final Value<double?> priceEur;
  final Value<double?> priceEurFoil;
  final Value<String> language;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedCardsCompanion({
    this.cardId = const Value.absent(),
    this.game = const Value.absent(),
    this.name = const Value.absent(),
    this.setCode = const Value.absent(),
    this.setName = const Value.absent(),
    this.collectorNumber = const Value.absent(),
    this.typeLine = const Value.absent(),
    this.rarity = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.artCropUrl = const Value.absent(),
    this.priceUsd = const Value.absent(),
    this.priceUsdFoil = const Value.absent(),
    this.priceEur = const Value.absent(),
    this.priceEurFoil = const Value.absent(),
    this.language = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedCardsCompanion.insert({
    required String cardId,
    required String game,
    required String name,
    required String setCode,
    required String setName,
    required String collectorNumber,
    this.typeLine = const Value.absent(),
    required String rarity,
    this.imageUrl = const Value.absent(),
    this.artCropUrl = const Value.absent(),
    this.priceUsd = const Value.absent(),
    this.priceUsdFoil = const Value.absent(),
    this.priceEur = const Value.absent(),
    this.priceEurFoil = const Value.absent(),
    required String language,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       game = Value(game),
       name = Value(name),
       setCode = Value(setCode),
       setName = Value(setName),
       collectorNumber = Value(collectorNumber),
       rarity = Value(rarity),
       language = Value(language),
       cachedAt = Value(cachedAt);
  static Insertable<CachedCard> custom({
    Expression<String>? cardId,
    Expression<String>? game,
    Expression<String>? name,
    Expression<String>? setCode,
    Expression<String>? setName,
    Expression<String>? collectorNumber,
    Expression<String>? typeLine,
    Expression<String>? rarity,
    Expression<String>? imageUrl,
    Expression<String>? artCropUrl,
    Expression<double>? priceUsd,
    Expression<double>? priceUsdFoil,
    Expression<double>? priceEur,
    Expression<double>? priceEurFoil,
    Expression<String>? language,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (game != null) 'game': game,
      if (name != null) 'name': name,
      if (setCode != null) 'set_code': setCode,
      if (setName != null) 'set_name': setName,
      if (collectorNumber != null) 'collector_number': collectorNumber,
      if (typeLine != null) 'type_line': typeLine,
      if (rarity != null) 'rarity': rarity,
      if (imageUrl != null) 'image_url': imageUrl,
      if (artCropUrl != null) 'art_crop_url': artCropUrl,
      if (priceUsd != null) 'price_usd': priceUsd,
      if (priceUsdFoil != null) 'price_usd_foil': priceUsdFoil,
      if (priceEur != null) 'price_eur': priceEur,
      if (priceEurFoil != null) 'price_eur_foil': priceEurFoil,
      if (language != null) 'language': language,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedCardsCompanion copyWith({
    Value<String>? cardId,
    Value<String>? game,
    Value<String>? name,
    Value<String>? setCode,
    Value<String>? setName,
    Value<String>? collectorNumber,
    Value<String?>? typeLine,
    Value<String>? rarity,
    Value<String?>? imageUrl,
    Value<String?>? artCropUrl,
    Value<double?>? priceUsd,
    Value<double?>? priceUsdFoil,
    Value<double?>? priceEur,
    Value<double?>? priceEurFoil,
    Value<String>? language,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedCardsCompanion(
      cardId: cardId ?? this.cardId,
      game: game ?? this.game,
      name: name ?? this.name,
      setCode: setCode ?? this.setCode,
      setName: setName ?? this.setName,
      collectorNumber: collectorNumber ?? this.collectorNumber,
      typeLine: typeLine ?? this.typeLine,
      rarity: rarity ?? this.rarity,
      imageUrl: imageUrl ?? this.imageUrl,
      artCropUrl: artCropUrl ?? this.artCropUrl,
      priceUsd: priceUsd ?? this.priceUsd,
      priceUsdFoil: priceUsdFoil ?? this.priceUsdFoil,
      priceEur: priceEur ?? this.priceEur,
      priceEurFoil: priceEurFoil ?? this.priceEurFoil,
      language: language ?? this.language,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (game.present) {
      map['game'] = Variable<String>(game.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (setCode.present) {
      map['set_code'] = Variable<String>(setCode.value);
    }
    if (setName.present) {
      map['set_name'] = Variable<String>(setName.value);
    }
    if (collectorNumber.present) {
      map['collector_number'] = Variable<String>(collectorNumber.value);
    }
    if (typeLine.present) {
      map['type_line'] = Variable<String>(typeLine.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<String>(rarity.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (artCropUrl.present) {
      map['art_crop_url'] = Variable<String>(artCropUrl.value);
    }
    if (priceUsd.present) {
      map['price_usd'] = Variable<double>(priceUsd.value);
    }
    if (priceUsdFoil.present) {
      map['price_usd_foil'] = Variable<double>(priceUsdFoil.value);
    }
    if (priceEur.present) {
      map['price_eur'] = Variable<double>(priceEur.value);
    }
    if (priceEurFoil.present) {
      map['price_eur_foil'] = Variable<double>(priceEurFoil.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedCardsCompanion(')
          ..write('cardId: $cardId, ')
          ..write('game: $game, ')
          ..write('name: $name, ')
          ..write('setCode: $setCode, ')
          ..write('setName: $setName, ')
          ..write('collectorNumber: $collectorNumber, ')
          ..write('typeLine: $typeLine, ')
          ..write('rarity: $rarity, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('artCropUrl: $artCropUrl, ')
          ..write('priceUsd: $priceUsd, ')
          ..write('priceUsdFoil: $priceUsdFoil, ')
          ..write('priceEur: $priceEur, ')
          ..write('priceEurFoil: $priceEurFoil, ')
          ..write('language: $language, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BindersTable extends Binders with TableInfo<$BindersTable, Binder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameMeta = const VerificationMeta('game');
  @override
  late final GeneratedColumn<String> game = GeneratedColumn<String>(
    'game',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, game, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'binders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Binder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('game')) {
      context.handle(
        _gameMeta,
        game.isAcceptableOrUnknown(data['game']!, _gameMeta),
      );
    } else if (isInserting) {
      context.missing(_gameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Binder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Binder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      game: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BindersTable createAlias(String alias) {
    return $BindersTable(attachedDatabase, alias);
  }
}

class BindersCompanion extends UpdateCompanion<Binder> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> game;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BindersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.game = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BindersCompanion.insert({
    required String id,
    required String name,
    required String game,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       game = Value(game),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Binder> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? game,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (game != null) 'game': game,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BindersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? game,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BindersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      game: game ?? this.game,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (game.present) {
      map['game'] = Variable<String>(game.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BindersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('game: $game, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardEntriesTable extends CardEntries
    with TableInfo<$CardEntriesTable, CardEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _binderIdMeta = const VerificationMeta(
    'binderId',
  );
  @override
  late final GeneratedColumn<String> binderId = GeneratedColumn<String>(
    'binder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameMeta = const VerificationMeta('game');
  @override
  late final GeneratedColumn<String> game = GeneratedColumn<String>(
    'game',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setCodeMeta = const VerificationMeta(
    'setCode',
  );
  @override
  late final GeneratedColumn<String> setCode = GeneratedColumn<String>(
    'set_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setNameMeta = const VerificationMeta(
    'setName',
  );
  @override
  late final GeneratedColumn<String> setName = GeneratedColumn<String>(
    'set_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectorNumberMeta = const VerificationMeta(
    'collectorNumber',
  );
  @override
  late final GeneratedColumn<String> collectorNumber = GeneratedColumn<String>(
    'collector_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _foilMeta = const VerificationMeta('foil');
  @override
  late final GeneratedColumn<bool> foil = GeneratedColumn<bool>(
    'foil',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("foil" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _conditionMeta = const VerificationMeta(
    'condition',
  );
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
    'condition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchaseCurrencyMeta = const VerificationMeta(
    'purchaseCurrency',
  );
  @override
  late final GeneratedColumn<String> purchaseCurrency = GeneratedColumn<String>(
    'purchase_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    binderId,
    game,
    cardId,
    name,
    setCode,
    setName,
    collectorNumber,
    quantity,
    foil,
    language,
    condition,
    purchasePrice,
    purchaseCurrency,
    notes,
    imageUrl,
    addedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('binder_id')) {
      context.handle(
        _binderIdMeta,
        binderId.isAcceptableOrUnknown(data['binder_id']!, _binderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_binderIdMeta);
    }
    if (data.containsKey('game')) {
      context.handle(
        _gameMeta,
        game.isAcceptableOrUnknown(data['game']!, _gameMeta),
      );
    } else if (isInserting) {
      context.missing(_gameMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('set_code')) {
      context.handle(
        _setCodeMeta,
        setCode.isAcceptableOrUnknown(data['set_code']!, _setCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_setCodeMeta);
    }
    if (data.containsKey('set_name')) {
      context.handle(
        _setNameMeta,
        setName.isAcceptableOrUnknown(data['set_name']!, _setNameMeta),
      );
    } else if (isInserting) {
      context.missing(_setNameMeta);
    }
    if (data.containsKey('collector_number')) {
      context.handle(
        _collectorNumberMeta,
        collectorNumber.isAcceptableOrUnknown(
          data['collector_number']!,
          _collectorNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectorNumberMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('foil')) {
      context.handle(
        _foilMeta,
        foil.isAcceptableOrUnknown(data['foil']!, _foilMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('condition')) {
      context.handle(
        _conditionMeta,
        condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta),
      );
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    }
    if (data.containsKey('purchase_currency')) {
      context.handle(
        _purchaseCurrencyMeta,
        purchaseCurrency.isAcceptableOrUnknown(
          data['purchase_currency']!,
          _purchaseCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      binderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}binder_id'],
      )!,
      game: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      setCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_code'],
      )!,
      setName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_name'],
      )!,
      collectorNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_number'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      foil: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}foil'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      condition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition'],
      ),
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      ),
      purchaseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_currency'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CardEntriesTable createAlias(String alias) {
    return $CardEntriesTable(attachedDatabase, alias);
  }
}

class CardEntriesCompanion extends UpdateCompanion<CardEntry> {
  final Value<String> id;
  final Value<String> binderId;
  final Value<String> game;
  final Value<String> cardId;
  final Value<String> name;
  final Value<String> setCode;
  final Value<String> setName;
  final Value<String> collectorNumber;
  final Value<int> quantity;
  final Value<bool> foil;
  final Value<String> language;
  final Value<String?> condition;
  final Value<double?> purchasePrice;
  final Value<String?> purchaseCurrency;
  final Value<String?> notes;
  final Value<String?> imageUrl;
  final Value<DateTime> addedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CardEntriesCompanion({
    this.id = const Value.absent(),
    this.binderId = const Value.absent(),
    this.game = const Value.absent(),
    this.cardId = const Value.absent(),
    this.name = const Value.absent(),
    this.setCode = const Value.absent(),
    this.setName = const Value.absent(),
    this.collectorNumber = const Value.absent(),
    this.quantity = const Value.absent(),
    this.foil = const Value.absent(),
    this.language = const Value.absent(),
    this.condition = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.purchaseCurrency = const Value.absent(),
    this.notes = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardEntriesCompanion.insert({
    required String id,
    required String binderId,
    required String game,
    required String cardId,
    required String name,
    required String setCode,
    required String setName,
    required String collectorNumber,
    this.quantity = const Value.absent(),
    this.foil = const Value.absent(),
    this.language = const Value.absent(),
    this.condition = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.purchaseCurrency = const Value.absent(),
    this.notes = const Value.absent(),
    this.imageUrl = const Value.absent(),
    required DateTime addedAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       binderId = Value(binderId),
       game = Value(game),
       cardId = Value(cardId),
       name = Value(name),
       setCode = Value(setCode),
       setName = Value(setName),
       collectorNumber = Value(collectorNumber),
       addedAt = Value(addedAt),
       updatedAt = Value(updatedAt);
  static Insertable<CardEntry> custom({
    Expression<String>? id,
    Expression<String>? binderId,
    Expression<String>? game,
    Expression<String>? cardId,
    Expression<String>? name,
    Expression<String>? setCode,
    Expression<String>? setName,
    Expression<String>? collectorNumber,
    Expression<int>? quantity,
    Expression<bool>? foil,
    Expression<String>? language,
    Expression<String>? condition,
    Expression<double>? purchasePrice,
    Expression<String>? purchaseCurrency,
    Expression<String>? notes,
    Expression<String>? imageUrl,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (binderId != null) 'binder_id': binderId,
      if (game != null) 'game': game,
      if (cardId != null) 'card_id': cardId,
      if (name != null) 'name': name,
      if (setCode != null) 'set_code': setCode,
      if (setName != null) 'set_name': setName,
      if (collectorNumber != null) 'collector_number': collectorNumber,
      if (quantity != null) 'quantity': quantity,
      if (foil != null) 'foil': foil,
      if (language != null) 'language': language,
      if (condition != null) 'condition': condition,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (purchaseCurrency != null) 'purchase_currency': purchaseCurrency,
      if (notes != null) 'notes': notes,
      if (imageUrl != null) 'image_url': imageUrl,
      if (addedAt != null) 'added_at': addedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? binderId,
    Value<String>? game,
    Value<String>? cardId,
    Value<String>? name,
    Value<String>? setCode,
    Value<String>? setName,
    Value<String>? collectorNumber,
    Value<int>? quantity,
    Value<bool>? foil,
    Value<String>? language,
    Value<String?>? condition,
    Value<double?>? purchasePrice,
    Value<String?>? purchaseCurrency,
    Value<String?>? notes,
    Value<String?>? imageUrl,
    Value<DateTime>? addedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CardEntriesCompanion(
      id: id ?? this.id,
      binderId: binderId ?? this.binderId,
      game: game ?? this.game,
      cardId: cardId ?? this.cardId,
      name: name ?? this.name,
      setCode: setCode ?? this.setCode,
      setName: setName ?? this.setName,
      collectorNumber: collectorNumber ?? this.collectorNumber,
      quantity: quantity ?? this.quantity,
      foil: foil ?? this.foil,
      language: language ?? this.language,
      condition: condition ?? this.condition,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseCurrency: purchaseCurrency ?? this.purchaseCurrency,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (binderId.present) {
      map['binder_id'] = Variable<String>(binderId.value);
    }
    if (game.present) {
      map['game'] = Variable<String>(game.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (setCode.present) {
      map['set_code'] = Variable<String>(setCode.value);
    }
    if (setName.present) {
      map['set_name'] = Variable<String>(setName.value);
    }
    if (collectorNumber.present) {
      map['collector_number'] = Variable<String>(collectorNumber.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (foil.present) {
      map['foil'] = Variable<bool>(foil.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (purchaseCurrency.present) {
      map['purchase_currency'] = Variable<String>(purchaseCurrency.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardEntriesCompanion(')
          ..write('id: $id, ')
          ..write('binderId: $binderId, ')
          ..write('game: $game, ')
          ..write('cardId: $cardId, ')
          ..write('name: $name, ')
          ..write('setCode: $setCode, ')
          ..write('setName: $setName, ')
          ..write('collectorNumber: $collectorNumber, ')
          ..write('quantity: $quantity, ')
          ..write('foil: $foil, ')
          ..write('language: $language, ')
          ..write('condition: $condition, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('purchaseCurrency: $purchaseCurrency, ')
          ..write('notes: $notes, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('addedAt: $addedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardHashesTable extends CardHashes
    with TableInfo<$CardHashesTable, CardHash> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardHashesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameMeta = const VerificationMeta('game');
  @override
  late final GeneratedColumn<String> game = GeneratedColumn<String>(
    'game',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phashValueMeta = const VerificationMeta(
    'phashValue',
  );
  @override
  late final GeneratedColumn<int> phashValue = GeneratedColumn<int>(
    'phash_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setCodeMeta = const VerificationMeta(
    'setCode',
  );
  @override
  late final GeneratedColumn<String> setCode = GeneratedColumn<String>(
    'set_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cardId, game, phashValue, setCode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_hashes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardHash> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('game')) {
      context.handle(
        _gameMeta,
        game.isAcceptableOrUnknown(data['game']!, _gameMeta),
      );
    } else if (isInserting) {
      context.missing(_gameMeta);
    }
    if (data.containsKey('phash_value')) {
      context.handle(
        _phashValueMeta,
        phashValue.isAcceptableOrUnknown(data['phash_value']!, _phashValueMeta),
      );
    } else if (isInserting) {
      context.missing(_phashValueMeta);
    }
    if (data.containsKey('set_code')) {
      context.handle(
        _setCodeMeta,
        setCode.isAcceptableOrUnknown(data['set_code']!, _setCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_setCodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId};
  @override
  CardHash map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardHash(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      game: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game'],
      )!,
      phashValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}phash_value'],
      )!,
      setCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_code'],
      )!,
    );
  }

  @override
  $CardHashesTable createAlias(String alias) {
    return $CardHashesTable(attachedDatabase, alias);
  }
}

class CardHashesCompanion extends UpdateCompanion<CardHash> {
  final Value<String> cardId;
  final Value<String> game;
  final Value<int> phashValue;
  final Value<String> setCode;
  final Value<int> rowid;
  const CardHashesCompanion({
    this.cardId = const Value.absent(),
    this.game = const Value.absent(),
    this.phashValue = const Value.absent(),
    this.setCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardHashesCompanion.insert({
    required String cardId,
    required String game,
    required int phashValue,
    required String setCode,
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       game = Value(game),
       phashValue = Value(phashValue),
       setCode = Value(setCode);
  static Insertable<CardHash> custom({
    Expression<String>? cardId,
    Expression<String>? game,
    Expression<int>? phashValue,
    Expression<String>? setCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (game != null) 'game': game,
      if (phashValue != null) 'phash_value': phashValue,
      if (setCode != null) 'set_code': setCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardHashesCompanion copyWith({
    Value<String>? cardId,
    Value<String>? game,
    Value<int>? phashValue,
    Value<String>? setCode,
    Value<int>? rowid,
  }) {
    return CardHashesCompanion(
      cardId: cardId ?? this.cardId,
      game: game ?? this.game,
      phashValue: phashValue ?? this.phashValue,
      setCode: setCode ?? this.setCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (game.present) {
      map['game'] = Variable<String>(game.value);
    }
    if (phashValue.present) {
      map['phash_value'] = Variable<int>(phashValue.value);
    }
    if (setCode.present) {
      map['set_code'] = Variable<String>(setCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardHashesCompanion(')
          ..write('cardId: $cardId, ')
          ..write('game: $game, ')
          ..write('phashValue: $phashValue, ')
          ..write('setCode: $setCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedCardsTable cachedCards = $CachedCardsTable(this);
  late final $BindersTable binders = $BindersTable(this);
  late final $CardEntriesTable cardEntries = $CardEntriesTable(this);
  late final $CardHashesTable cardHashes = $CardHashesTable(this);
  late final CardsDao cardsDao = CardsDao(this as AppDatabase);
  late final BindersDao bindersDao = BindersDao(this as AppDatabase);
  late final CardEntriesDao cardEntriesDao = CardEntriesDao(
    this as AppDatabase,
  );
  late final CardHashesDao cardHashesDao = CardHashesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedCards,
    binders,
    cardEntries,
    cardHashes,
  ];
}

typedef $$CachedCardsTableCreateCompanionBuilder =
    CachedCardsCompanion Function({
      required String cardId,
      required String game,
      required String name,
      required String setCode,
      required String setName,
      required String collectorNumber,
      Value<String?> typeLine,
      required String rarity,
      Value<String?> imageUrl,
      Value<String?> artCropUrl,
      Value<double?> priceUsd,
      Value<double?> priceUsdFoil,
      Value<double?> priceEur,
      Value<double?> priceEurFoil,
      required String language,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CachedCardsTableUpdateCompanionBuilder =
    CachedCardsCompanion Function({
      Value<String> cardId,
      Value<String> game,
      Value<String> name,
      Value<String> setCode,
      Value<String> setName,
      Value<String> collectorNumber,
      Value<String?> typeLine,
      Value<String> rarity,
      Value<String?> imageUrl,
      Value<String?> artCropUrl,
      Value<double?> priceUsd,
      Value<double?> priceUsdFoil,
      Value<double?> priceEur,
      Value<double?> priceEurFoil,
      Value<String> language,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedCardsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedCardsTable> {
  $$CachedCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get game => $composableBuilder(
    column: $table.game,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setCode => $composableBuilder(
    column: $table.setCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorNumber => $composableBuilder(
    column: $table.collectorNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeLine => $composableBuilder(
    column: $table.typeLine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artCropUrl => $composableBuilder(
    column: $table.artCropUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get priceUsd => $composableBuilder(
    column: $table.priceUsd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get priceUsdFoil => $composableBuilder(
    column: $table.priceUsdFoil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get priceEur => $composableBuilder(
    column: $table.priceEur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get priceEurFoil => $composableBuilder(
    column: $table.priceEurFoil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedCardsTable> {
  $$CachedCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get game => $composableBuilder(
    column: $table.game,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setCode => $composableBuilder(
    column: $table.setCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorNumber => $composableBuilder(
    column: $table.collectorNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeLine => $composableBuilder(
    column: $table.typeLine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artCropUrl => $composableBuilder(
    column: $table.artCropUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get priceUsd => $composableBuilder(
    column: $table.priceUsd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get priceUsdFoil => $composableBuilder(
    column: $table.priceUsdFoil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get priceEur => $composableBuilder(
    column: $table.priceEur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get priceEurFoil => $composableBuilder(
    column: $table.priceEurFoil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedCardsTable> {
  $$CachedCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get game =>
      $composableBuilder(column: $table.game, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get setCode =>
      $composableBuilder(column: $table.setCode, builder: (column) => column);

  GeneratedColumn<String> get setName =>
      $composableBuilder(column: $table.setName, builder: (column) => column);

  GeneratedColumn<String> get collectorNumber => $composableBuilder(
    column: $table.collectorNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get typeLine =>
      $composableBuilder(column: $table.typeLine, builder: (column) => column);

  GeneratedColumn<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get artCropUrl => $composableBuilder(
    column: $table.artCropUrl,
    builder: (column) => column,
  );

  GeneratedColumn<double> get priceUsd =>
      $composableBuilder(column: $table.priceUsd, builder: (column) => column);

  GeneratedColumn<double> get priceUsdFoil => $composableBuilder(
    column: $table.priceUsdFoil,
    builder: (column) => column,
  );

  GeneratedColumn<double> get priceEur =>
      $composableBuilder(column: $table.priceEur, builder: (column) => column);

  GeneratedColumn<double> get priceEurFoil => $composableBuilder(
    column: $table.priceEurFoil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedCardsTable,
          CachedCard,
          $$CachedCardsTableFilterComposer,
          $$CachedCardsTableOrderingComposer,
          $$CachedCardsTableAnnotationComposer,
          $$CachedCardsTableCreateCompanionBuilder,
          $$CachedCardsTableUpdateCompanionBuilder,
          (
            CachedCard,
            BaseReferences<_$AppDatabase, $CachedCardsTable, CachedCard>,
          ),
          CachedCard,
          PrefetchHooks Function()
        > {
  $$CachedCardsTableTableManager(_$AppDatabase db, $CachedCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<String> game = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> setCode = const Value.absent(),
                Value<String> setName = const Value.absent(),
                Value<String> collectorNumber = const Value.absent(),
                Value<String?> typeLine = const Value.absent(),
                Value<String> rarity = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> artCropUrl = const Value.absent(),
                Value<double?> priceUsd = const Value.absent(),
                Value<double?> priceUsdFoil = const Value.absent(),
                Value<double?> priceEur = const Value.absent(),
                Value<double?> priceEurFoil = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedCardsCompanion(
                cardId: cardId,
                game: game,
                name: name,
                setCode: setCode,
                setName: setName,
                collectorNumber: collectorNumber,
                typeLine: typeLine,
                rarity: rarity,
                imageUrl: imageUrl,
                artCropUrl: artCropUrl,
                priceUsd: priceUsd,
                priceUsdFoil: priceUsdFoil,
                priceEur: priceEur,
                priceEurFoil: priceEurFoil,
                language: language,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required String game,
                required String name,
                required String setCode,
                required String setName,
                required String collectorNumber,
                Value<String?> typeLine = const Value.absent(),
                required String rarity,
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> artCropUrl = const Value.absent(),
                Value<double?> priceUsd = const Value.absent(),
                Value<double?> priceUsdFoil = const Value.absent(),
                Value<double?> priceEur = const Value.absent(),
                Value<double?> priceEurFoil = const Value.absent(),
                required String language,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedCardsCompanion.insert(
                cardId: cardId,
                game: game,
                name: name,
                setCode: setCode,
                setName: setName,
                collectorNumber: collectorNumber,
                typeLine: typeLine,
                rarity: rarity,
                imageUrl: imageUrl,
                artCropUrl: artCropUrl,
                priceUsd: priceUsd,
                priceUsdFoil: priceUsdFoil,
                priceEur: priceEur,
                priceEurFoil: priceEurFoil,
                language: language,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedCardsTable,
      CachedCard,
      $$CachedCardsTableFilterComposer,
      $$CachedCardsTableOrderingComposer,
      $$CachedCardsTableAnnotationComposer,
      $$CachedCardsTableCreateCompanionBuilder,
      $$CachedCardsTableUpdateCompanionBuilder,
      (
        CachedCard,
        BaseReferences<_$AppDatabase, $CachedCardsTable, CachedCard>,
      ),
      CachedCard,
      PrefetchHooks Function()
    >;
typedef $$BindersTableCreateCompanionBuilder =
    BindersCompanion Function({
      required String id,
      required String name,
      required String game,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$BindersTableUpdateCompanionBuilder =
    BindersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> game,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$BindersTableFilterComposer
    extends Composer<_$AppDatabase, $BindersTable> {
  $$BindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get game => $composableBuilder(
    column: $table.game,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BindersTableOrderingComposer
    extends Composer<_$AppDatabase, $BindersTable> {
  $$BindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get game => $composableBuilder(
    column: $table.game,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $BindersTable> {
  $$BindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get game =>
      $composableBuilder(column: $table.game, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BindersTable,
          Binder,
          $$BindersTableFilterComposer,
          $$BindersTableOrderingComposer,
          $$BindersTableAnnotationComposer,
          $$BindersTableCreateCompanionBuilder,
          $$BindersTableUpdateCompanionBuilder,
          (Binder, BaseReferences<_$AppDatabase, $BindersTable, Binder>),
          Binder,
          PrefetchHooks Function()
        > {
  $$BindersTableTableManager(_$AppDatabase db, $BindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> game = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BindersCompanion(
                id: id,
                name: name,
                game: game,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String game,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BindersCompanion.insert(
                id: id,
                name: name,
                game: game,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BindersTable,
      Binder,
      $$BindersTableFilterComposer,
      $$BindersTableOrderingComposer,
      $$BindersTableAnnotationComposer,
      $$BindersTableCreateCompanionBuilder,
      $$BindersTableUpdateCompanionBuilder,
      (Binder, BaseReferences<_$AppDatabase, $BindersTable, Binder>),
      Binder,
      PrefetchHooks Function()
    >;
typedef $$CardEntriesTableCreateCompanionBuilder =
    CardEntriesCompanion Function({
      required String id,
      required String binderId,
      required String game,
      required String cardId,
      required String name,
      required String setCode,
      required String setName,
      required String collectorNumber,
      Value<int> quantity,
      Value<bool> foil,
      Value<String> language,
      Value<String?> condition,
      Value<double?> purchasePrice,
      Value<String?> purchaseCurrency,
      Value<String?> notes,
      Value<String?> imageUrl,
      required DateTime addedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CardEntriesTableUpdateCompanionBuilder =
    CardEntriesCompanion Function({
      Value<String> id,
      Value<String> binderId,
      Value<String> game,
      Value<String> cardId,
      Value<String> name,
      Value<String> setCode,
      Value<String> setName,
      Value<String> collectorNumber,
      Value<int> quantity,
      Value<bool> foil,
      Value<String> language,
      Value<String?> condition,
      Value<double?> purchasePrice,
      Value<String?> purchaseCurrency,
      Value<String?> notes,
      Value<String?> imageUrl,
      Value<DateTime> addedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CardEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CardEntriesTable> {
  $$CardEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get binderId => $composableBuilder(
    column: $table.binderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get game => $composableBuilder(
    column: $table.game,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setCode => $composableBuilder(
    column: $table.setCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorNumber => $composableBuilder(
    column: $table.collectorNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get foil => $composableBuilder(
    column: $table.foil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purchaseCurrency => $composableBuilder(
    column: $table.purchaseCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CardEntriesTable> {
  $$CardEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get binderId => $composableBuilder(
    column: $table.binderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get game => $composableBuilder(
    column: $table.game,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setCode => $composableBuilder(
    column: $table.setCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorNumber => $composableBuilder(
    column: $table.collectorNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get foil => $composableBuilder(
    column: $table.foil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchaseCurrency => $composableBuilder(
    column: $table.purchaseCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardEntriesTable> {
  $$CardEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get binderId =>
      $composableBuilder(column: $table.binderId, builder: (column) => column);

  GeneratedColumn<String> get game =>
      $composableBuilder(column: $table.game, builder: (column) => column);

  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get setCode =>
      $composableBuilder(column: $table.setCode, builder: (column) => column);

  GeneratedColumn<String> get setName =>
      $composableBuilder(column: $table.setName, builder: (column) => column);

  GeneratedColumn<String> get collectorNumber => $composableBuilder(
    column: $table.collectorNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<bool> get foil =>
      $composableBuilder(column: $table.foil, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purchaseCurrency => $composableBuilder(
    column: $table.purchaseCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CardEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardEntriesTable,
          CardEntry,
          $$CardEntriesTableFilterComposer,
          $$CardEntriesTableOrderingComposer,
          $$CardEntriesTableAnnotationComposer,
          $$CardEntriesTableCreateCompanionBuilder,
          $$CardEntriesTableUpdateCompanionBuilder,
          (
            CardEntry,
            BaseReferences<_$AppDatabase, $CardEntriesTable, CardEntry>,
          ),
          CardEntry,
          PrefetchHooks Function()
        > {
  $$CardEntriesTableTableManager(_$AppDatabase db, $CardEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> binderId = const Value.absent(),
                Value<String> game = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> setCode = const Value.absent(),
                Value<String> setName = const Value.absent(),
                Value<String> collectorNumber = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<bool> foil = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String?> condition = const Value.absent(),
                Value<double?> purchasePrice = const Value.absent(),
                Value<String?> purchaseCurrency = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardEntriesCompanion(
                id: id,
                binderId: binderId,
                game: game,
                cardId: cardId,
                name: name,
                setCode: setCode,
                setName: setName,
                collectorNumber: collectorNumber,
                quantity: quantity,
                foil: foil,
                language: language,
                condition: condition,
                purchasePrice: purchasePrice,
                purchaseCurrency: purchaseCurrency,
                notes: notes,
                imageUrl: imageUrl,
                addedAt: addedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String binderId,
                required String game,
                required String cardId,
                required String name,
                required String setCode,
                required String setName,
                required String collectorNumber,
                Value<int> quantity = const Value.absent(),
                Value<bool> foil = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String?> condition = const Value.absent(),
                Value<double?> purchasePrice = const Value.absent(),
                Value<String?> purchaseCurrency = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                required DateTime addedAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CardEntriesCompanion.insert(
                id: id,
                binderId: binderId,
                game: game,
                cardId: cardId,
                name: name,
                setCode: setCode,
                setName: setName,
                collectorNumber: collectorNumber,
                quantity: quantity,
                foil: foil,
                language: language,
                condition: condition,
                purchasePrice: purchasePrice,
                purchaseCurrency: purchaseCurrency,
                notes: notes,
                imageUrl: imageUrl,
                addedAt: addedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardEntriesTable,
      CardEntry,
      $$CardEntriesTableFilterComposer,
      $$CardEntriesTableOrderingComposer,
      $$CardEntriesTableAnnotationComposer,
      $$CardEntriesTableCreateCompanionBuilder,
      $$CardEntriesTableUpdateCompanionBuilder,
      (CardEntry, BaseReferences<_$AppDatabase, $CardEntriesTable, CardEntry>),
      CardEntry,
      PrefetchHooks Function()
    >;
typedef $$CardHashesTableCreateCompanionBuilder =
    CardHashesCompanion Function({
      required String cardId,
      required String game,
      required int phashValue,
      required String setCode,
      Value<int> rowid,
    });
typedef $$CardHashesTableUpdateCompanionBuilder =
    CardHashesCompanion Function({
      Value<String> cardId,
      Value<String> game,
      Value<int> phashValue,
      Value<String> setCode,
      Value<int> rowid,
    });

class $$CardHashesTableFilterComposer
    extends Composer<_$AppDatabase, $CardHashesTable> {
  $$CardHashesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get game => $composableBuilder(
    column: $table.game,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get phashValue => $composableBuilder(
    column: $table.phashValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setCode => $composableBuilder(
    column: $table.setCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardHashesTableOrderingComposer
    extends Composer<_$AppDatabase, $CardHashesTable> {
  $$CardHashesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get game => $composableBuilder(
    column: $table.game,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get phashValue => $composableBuilder(
    column: $table.phashValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setCode => $composableBuilder(
    column: $table.setCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardHashesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardHashesTable> {
  $$CardHashesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get game =>
      $composableBuilder(column: $table.game, builder: (column) => column);

  GeneratedColumn<int> get phashValue => $composableBuilder(
    column: $table.phashValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get setCode =>
      $composableBuilder(column: $table.setCode, builder: (column) => column);
}

class $$CardHashesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardHashesTable,
          CardHash,
          $$CardHashesTableFilterComposer,
          $$CardHashesTableOrderingComposer,
          $$CardHashesTableAnnotationComposer,
          $$CardHashesTableCreateCompanionBuilder,
          $$CardHashesTableUpdateCompanionBuilder,
          (CardHash, BaseReferences<_$AppDatabase, $CardHashesTable, CardHash>),
          CardHash,
          PrefetchHooks Function()
        > {
  $$CardHashesTableTableManager(_$AppDatabase db, $CardHashesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardHashesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardHashesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardHashesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<String> game = const Value.absent(),
                Value<int> phashValue = const Value.absent(),
                Value<String> setCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardHashesCompanion(
                cardId: cardId,
                game: game,
                phashValue: phashValue,
                setCode: setCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required String game,
                required int phashValue,
                required String setCode,
                Value<int> rowid = const Value.absent(),
              }) => CardHashesCompanion.insert(
                cardId: cardId,
                game: game,
                phashValue: phashValue,
                setCode: setCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardHashesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardHashesTable,
      CardHash,
      $$CardHashesTableFilterComposer,
      $$CardHashesTableOrderingComposer,
      $$CardHashesTableAnnotationComposer,
      $$CardHashesTableCreateCompanionBuilder,
      $$CardHashesTableUpdateCompanionBuilder,
      (CardHash, BaseReferences<_$AppDatabase, $CardHashesTable, CardHash>),
      CardHash,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedCardsTableTableManager get cachedCards =>
      $$CachedCardsTableTableManager(_db, _db.cachedCards);
  $$BindersTableTableManager get binders =>
      $$BindersTableTableManager(_db, _db.binders);
  $$CardEntriesTableTableManager get cardEntries =>
      $$CardEntriesTableTableManager(_db, _db.cardEntries);
  $$CardHashesTableTableManager get cardHashes =>
      $$CardHashesTableTableManager(_db, _db.cardHashes);
}
