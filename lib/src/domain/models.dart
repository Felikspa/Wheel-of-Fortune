enum ProbabilityMode { equal, weighted, softAntiRepeat }

enum AppThemeMode { system, light, dark }

enum DrawDisplayMode { wheel, coin, dice, card }

class WheelItemModel {
  const WheelItemModel({
    required this.id,
    required this.wheelId,
    required this.order,
    required this.title,
    this.subtitle,
    this.tags,
    this.note,
    this.colorHex,
    this.weight,
    this.customFields = const {},
  });

  final int id;
  final int wheelId;
  final int order;
  final String title;
  final String? subtitle;
  final String? tags;
  final String? note;
  final String? colorHex;
  final double? weight;
  final Map<String, String> customFields;

  WheelItemModel copyWith({
    int? id,
    int? wheelId,
    int? order,
    String? title,
    String? subtitle,
    String? tags,
    String? note,
    String? colorHex,
    double? weight,
    Map<String, String>? customFields,
  }) {
    return WheelItemModel(
      id: id ?? this.id,
      wheelId: wheelId ?? this.wheelId,
      order: order ?? this.order,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      tags: tags ?? this.tags,
      note: note ?? this.note,
      colorHex: colorHex ?? this.colorHex,
      weight: weight ?? this.weight,
      customFields: customFields ?? this.customFields,
    );
  }
}

class WheelModel {
  const WheelModel({
    required this.id,
    required this.name,
    required this.probabilityMode,
    required this.spinDurationMs,
    required this.palette,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.backgroundImagePath,
    this.backgroundImageOpacity = 0.32,
    this.backgroundImageBlurSigma = 0,
  });

  final int id;
  final String name;
  final ProbabilityMode probabilityMode;
  final int spinDurationMs;
  final String palette;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<WheelItemModel> items;
  final String? backgroundImagePath;
  final double backgroundImageOpacity;
  final double backgroundImageBlurSigma;

  WheelModel copyWith({
    int? id,
    String? name,
    ProbabilityMode? probabilityMode,
    int? spinDurationMs,
    String? palette,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<WheelItemModel>? items,
    String? backgroundImagePath,
    bool clearBackgroundImagePath = false,
    double? backgroundImageOpacity,
    double? backgroundImageBlurSigma,
  }) {
    return WheelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      probabilityMode: probabilityMode ?? this.probabilityMode,
      spinDurationMs: spinDurationMs ?? this.spinDurationMs,
      palette: palette ?? this.palette,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      backgroundImagePath: clearBackgroundImagePath
          ? null
          : (backgroundImagePath ?? this.backgroundImagePath),
      backgroundImageOpacity:
          backgroundImageOpacity ?? this.backgroundImageOpacity,
      backgroundImageBlurSigma:
          backgroundImageBlurSigma ?? this.backgroundImageBlurSigma,
    );
  }
}

class CoinModeSettings {
  const CoinModeSettings({
    this.firstItemId,
    this.secondItemId,
    this.lastPartnerByItemId = const {},
  });

  final int? firstItemId;
  final int? secondItemId;
  final Map<int, int> lastPartnerByItemId;

  CoinModeSettings copyWith({
    int? firstItemId,
    int? secondItemId,
    Map<int, int>? lastPartnerByItemId,
    bool clearFirstItemId = false,
    bool clearSecondItemId = false,
  }) {
    return CoinModeSettings(
      firstItemId: clearFirstItemId ? null : (firstItemId ?? this.firstItemId),
      secondItemId: clearSecondItemId
          ? null
          : (secondItemId ?? this.secondItemId),
      lastPartnerByItemId: lastPartnerByItemId ?? this.lastPartnerByItemId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstItemId': firstItemId,
      'secondItemId': secondItemId,
      'lastPartnerByItemId': {
        for (final entry in lastPartnerByItemId.entries)
          entry.key.toString(): entry.value,
      },
    };
  }

  factory CoinModeSettings.fromJson(Map<String, dynamic> json) {
    final partnerRaw = json['lastPartnerByItemId'];
    final partners = <int, int>{};
    if (partnerRaw is Map) {
      for (final entry in partnerRaw.entries) {
        final key = int.tryParse(entry.key.toString());
        final value = _asInt(entry.value);
        if (key == null || value == null) {
          continue;
        }
        partners[key] = value;
      }
    }
    return CoinModeSettings(
      firstItemId: _asInt(json['firstItemId']),
      secondItemId: _asInt(json['secondItemId']),
      lastPartnerByItemId: partners,
    );
  }
}

class DiceModeSettings {
  const DiceModeSettings({
    this.selectedSides = 6,
    this.mappingsBySides = const {},
  });

  final int selectedSides;
  final Map<int, List<int?>> mappingsBySides;

  DiceModeSettings copyWith({
    int? selectedSides,
    Map<int, List<int?>>? mappingsBySides,
  }) {
    return DiceModeSettings(
      selectedSides: selectedSides ?? this.selectedSides,
      mappingsBySides: mappingsBySides ?? this.mappingsBySides,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedSides': selectedSides,
      'mappingsBySides': {
        for (final entry in mappingsBySides.entries)
          entry.key.toString(): entry.value,
      },
    };
  }

  factory DiceModeSettings.fromJson(Map<String, dynamic> json) {
    final rawMappings = json['mappingsBySides'];
    final mappings = <int, List<int?>>{};
    if (rawMappings is Map) {
      for (final entry in rawMappings.entries) {
        final sides = int.tryParse(entry.key.toString());
        if (sides == null) {
          continue;
        }
        final values = <int?>[];
        final rawValues = entry.value;
        if (rawValues is List) {
          for (final value in rawValues) {
            values.add(_asInt(value));
          }
        }
        mappings[sides] = values;
      }
    }
    return DiceModeSettings(
      selectedSides: _asInt(json['selectedSides']) ?? 6,
      mappingsBySides: mappings,
    );
  }
}

class CardModeSettings {
  const CardModeSettings({this.revealAllOnPick = false});

  final bool revealAllOnPick;

  CardModeSettings copyWith({bool? revealAllOnPick}) {
    return CardModeSettings(
      revealAllOnPick: revealAllOnPick ?? this.revealAllOnPick,
    );
  }

  Map<String, dynamic> toJson() => {'revealAllOnPick': revealAllOnPick};

  factory CardModeSettings.fromJson(Map<String, dynamic> json) {
    return CardModeSettings(revealAllOnPick: json['revealAllOnPick'] == true);
  }
}

class AppSettingsModel {
  const AppSettingsModel({
    this.localeOverride,
    this.themeMode = AppThemeMode.system,
    this.modeByWheelId = const {},
    this.coinByWheelId = const {},
    this.diceByWheelId = const {},
    this.cardByWheelId = const {},
  });

  final String? localeOverride;
  final AppThemeMode themeMode;
  final Map<int, DrawDisplayMode> modeByWheelId;
  final Map<int, CoinModeSettings> coinByWheelId;
  final Map<int, DiceModeSettings> diceByWheelId;
  final Map<int, CardModeSettings> cardByWheelId;

  DrawDisplayMode displayModeForWheel(int wheelId) {
    return modeByWheelId[wheelId] ?? DrawDisplayMode.wheel;
  }

  CoinModeSettings coinSettingsForWheel(int wheelId) {
    return coinByWheelId[wheelId] ?? const CoinModeSettings();
  }

  DiceModeSettings diceSettingsForWheel(int wheelId) {
    return diceByWheelId[wheelId] ?? const DiceModeSettings();
  }

  CardModeSettings cardSettingsForWheel(int wheelId) {
    return cardByWheelId[wheelId] ?? const CardModeSettings();
  }

  AppSettingsModel copyWith({
    String? localeOverride,
    AppThemeMode? themeMode,
    Map<int, DrawDisplayMode>? modeByWheelId,
    Map<int, CoinModeSettings>? coinByWheelId,
    Map<int, DiceModeSettings>? diceByWheelId,
    Map<int, CardModeSettings>? cardByWheelId,
    bool clearLocaleOverride = false,
  }) {
    return AppSettingsModel(
      localeOverride: clearLocaleOverride
          ? null
          : (localeOverride ?? this.localeOverride),
      themeMode: themeMode ?? this.themeMode,
      modeByWheelId: modeByWheelId ?? this.modeByWheelId,
      coinByWheelId: coinByWheelId ?? this.coinByWheelId,
      diceByWheelId: diceByWheelId ?? this.diceByWheelId,
      cardByWheelId: cardByWheelId ?? this.cardByWheelId,
    );
  }

  AppSettingsModel withDisplayModeForWheel(int wheelId, DrawDisplayMode mode) {
    final updated = {...modeByWheelId, wheelId: mode};
    return copyWith(modeByWheelId: updated);
  }

  AppSettingsModel withCoinSettingsForWheel(
    int wheelId,
    CoinModeSettings value,
  ) {
    final updated = {...coinByWheelId, wheelId: value};
    return copyWith(coinByWheelId: updated);
  }

  AppSettingsModel withDiceSettingsForWheel(
    int wheelId,
    DiceModeSettings value,
  ) {
    final updated = {...diceByWheelId, wheelId: value};
    return copyWith(diceByWheelId: updated);
  }

  AppSettingsModel withCardSettingsForWheel(
    int wheelId,
    CardModeSettings value,
  ) {
    final updated = {...cardByWheelId, wheelId: value};
    return copyWith(cardByWheelId: updated);
  }

  AppSettingsModel withoutWheelScopedSettings(int wheelId) {
    final nextModes = {...modeByWheelId}..remove(wheelId);
    final nextCoin = {...coinByWheelId}..remove(wheelId);
    final nextDice = {...diceByWheelId}..remove(wheelId);
    final nextCard = {...cardByWheelId}..remove(wheelId);
    return copyWith(
      modeByWheelId: nextModes,
      coinByWheelId: nextCoin,
      diceByWheelId: nextDice,
      cardByWheelId: nextCard,
    );
  }

  Map<String, dynamic> toDrawSettingsJson() {
    return {
      'modeByWheelId': {
        for (final entry in modeByWheelId.entries)
          entry.key.toString(): entry.value.name,
      },
      'coinByWheelId': {
        for (final entry in coinByWheelId.entries)
          entry.key.toString(): entry.value.toJson(),
      },
      'diceByWheelId': {
        for (final entry in diceByWheelId.entries)
          entry.key.toString(): entry.value.toJson(),
      },
      'cardByWheelId': {
        for (final entry in cardByWheelId.entries)
          entry.key.toString(): entry.value.toJson(),
      },
    };
  }

  factory AppSettingsModel.fromPersisted({
    required String? localeOverride,
    required AppThemeMode themeMode,
    required Map<String, dynamic>? drawSettingsJson,
  }) {
    if (drawSettingsJson == null) {
      return AppSettingsModel(
        localeOverride: localeOverride,
        themeMode: themeMode,
      );
    }
    final rawModes = drawSettingsJson['modeByWheelId'];
    final rawCoin = drawSettingsJson['coinByWheelId'];
    final rawDice = drawSettingsJson['diceByWheelId'];
    final rawCard = drawSettingsJson['cardByWheelId'];

    final modes = <int, DrawDisplayMode>{};
    if (rawModes is Map) {
      for (final entry in rawModes.entries) {
        final wheelId = int.tryParse(entry.key.toString());
        final modeName = entry.value?.toString();
        if (wheelId == null || modeName == null) {
          continue;
        }
        DrawDisplayMode? mode;
        for (final candidate in DrawDisplayMode.values) {
          if (candidate.name == modeName) {
            mode = candidate;
            break;
          }
        }
        if (mode != null) {
          modes[wheelId] = mode;
        }
      }
    }

    final coin = <int, CoinModeSettings>{};
    if (rawCoin is Map) {
      for (final entry in rawCoin.entries) {
        final wheelId = int.tryParse(entry.key.toString());
        if (wheelId == null || entry.value is! Map) {
          continue;
        }
        coin[wheelId] = CoinModeSettings.fromJson(
          _mapToDynamic(entry.value as Map),
        );
      }
    }

    final dice = <int, DiceModeSettings>{};
    if (rawDice is Map) {
      for (final entry in rawDice.entries) {
        final wheelId = int.tryParse(entry.key.toString());
        if (wheelId == null || entry.value is! Map) {
          continue;
        }
        dice[wheelId] = DiceModeSettings.fromJson(
          _mapToDynamic(entry.value as Map),
        );
      }
    }

    final card = <int, CardModeSettings>{};
    if (rawCard is Map) {
      for (final entry in rawCard.entries) {
        final wheelId = int.tryParse(entry.key.toString());
        if (wheelId == null || entry.value is! Map) {
          continue;
        }
        card[wheelId] = CardModeSettings.fromJson(
          _mapToDynamic(entry.value as Map),
        );
      }
    }

    return AppSettingsModel(
      localeOverride: localeOverride,
      themeMode: themeMode,
      modeByWheelId: modes,
      coinByWheelId: coin,
      diceByWheelId: dice,
      cardByWheelId: card,
    );
  }
}

Map<String, dynamic> _mapToDynamic(Map source) {
  final output = <String, dynamic>{};
  for (final entry in source.entries) {
    output[entry.key.toString()] = entry.value;
  }
  return output;
}

int? _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}
