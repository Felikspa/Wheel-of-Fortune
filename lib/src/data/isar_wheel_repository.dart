import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/models.dart';
import 'isar_records.dart';
import 'wheel_repository.dart';

class IsarWheelRepository implements WheelRepository {
  Isar? _isar;

  Isar get _db => _isar!;

  @override
  Future<void> init() async {
    if (_isar != null) {
      return;
    }
    final directory = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [WheelRecordSchema, WheelItemRecordSchema, AppSettingsRecordSchema],
      directory: directory.path,
      name: 'wheel_of_fortune_db',
    );
    await _ensureSettingsExists();
  }

  @override
  Future<List<WheelModel>> loadWheels() async {
    final wheels = await _db.wheelRecords.where().sortByCreatedAt().findAll();
    final itemRecords = await _db.wheelItemRecords.where().findAll();
    final itemsByWheelId = <int, List<WheelItemRecord>>{};
    for (final item in itemRecords) {
      final bucket = itemsByWheelId.putIfAbsent(item.wheelId, () => []);
      bucket.add(item);
    }
    for (final bucket in itemsByWheelId.values) {
      bucket.sort((a, b) => a.order.compareTo(b.order));
    }
    return [
      for (final wheel in wheels)
        _toWheelModel(wheel, itemsByWheelId[wheel.id] ?? const []),
    ];
  }

  @override
  Future<WheelModel> createWheel(String name) async {
    final now = DateTime.now();
    final record = WheelRecord()
      ..name = name
      ..probabilityMode = ProbabilityMode.equal
      ..spinDurationMs = 4800
      ..palette = 'random'
      ..backgroundImagePath = null
      ..backgroundImageOpacity = 0.32
      ..backgroundImageBlurSigma = 0
      ..createdAt = now
      ..updatedAt = now;
    await _db.writeTxn(() async {
      await _db.wheelRecords.put(record);
    });
    return _toWheelModel(record, const []);
  }

  @override
  Future<void> saveWheel(WheelModel wheel) async {
    final record = WheelRecord()
      ..id = wheel.id
      ..name = wheel.name
      ..probabilityMode = wheel.probabilityMode
      ..spinDurationMs = wheel.spinDurationMs
      ..palette = wheel.palette
      ..backgroundImagePath = wheel.backgroundImagePath
      ..backgroundImageOpacity = wheel.backgroundImageOpacity
      ..backgroundImageBlurSigma = wheel.backgroundImageBlurSigma
      ..createdAt = wheel.createdAt
      ..updatedAt = wheel.updatedAt;
    await _db.writeTxn(() async {
      await _db.wheelRecords.put(record);
    });
  }

  @override
  Future<void> deleteWheel(int wheelId) async {
    await _db.writeTxn(() async {
      await _db.wheelRecords.delete(wheelId);
      final items = await _db.wheelItemRecords
          .filter()
          .wheelIdEqualTo(wheelId)
          .findAll();
      if (items.isNotEmpty) {
        await _db.wheelItemRecords.deleteAll(
          items.map((item) => item.id).toList(),
        );
      }
    });
  }

  @override
  Future<void> saveItems(int wheelId, List<WheelItemModel> items) async {
    await _db.writeTxn(() async {
      final existing = await _db.wheelItemRecords
          .filter()
          .wheelIdEqualTo(wheelId)
          .findAll();
      final existingById = {for (final item in existing) item.id: item};
      final keptIds = <int>{};

      for (var index = 0; index < items.length; index++) {
        final item = items[index];
        final record = existingById[item.id] ?? WheelItemRecord();
        if (item.id != 0) {
          record.id = item.id;
        }
        record
          ..wheelId = wheelId
          ..order = index
          ..title = item.title
          ..subtitle = item.subtitle
          ..tags = item.tags
          ..note = item.note
          ..colorHex = item.colorHex
          ..weight = item.weight
          ..customFieldsJson = item.customFields.isEmpty
              ? null
              : jsonEncode(item.customFields);
        final id = await _db.wheelItemRecords.put(record);
        keptIds.add(id);
      }

      final deleteIds = [
        for (final item in existing)
          if (!keptIds.contains(item.id)) item.id,
      ];
      if (deleteIds.isNotEmpty) {
        await _db.wheelItemRecords.deleteAll(deleteIds);
      }
    });
  }

  @override
  Future<void> deleteItem(int itemId) async {
    await _db.writeTxn(() async {
      final removed = await _db.wheelItemRecords.get(itemId);
      if (removed == null) {
        return;
      }
      await _db.wheelItemRecords.delete(itemId);
      final siblings = await _db.wheelItemRecords
          .filter()
          .wheelIdEqualTo(removed.wheelId)
          .sortByOrder()
          .findAll();
      for (var index = 0; index < siblings.length; index++) {
        siblings[index].order = index;
      }
      await _db.wheelItemRecords.putAll(siblings);
    });
  }

  @override
  Future<AppSettingsModel> loadSettings() async {
    final settings = await _db.appSettingsRecords.get(1);
    if (settings == null) {
      return const AppSettingsModel();
    }
    Map<String, dynamic>? drawSettingsJson;
    final rawDrawSettings = settings.drawSettingsJson;
    if (rawDrawSettings != null && rawDrawSettings.isNotEmpty) {
      final decoded = jsonDecode(rawDrawSettings);
      if (decoded is Map) {
        drawSettingsJson = _decodeStringKeyMap(decoded);
      }
    }
    return AppSettingsModel.fromPersisted(
      localeOverride: settings.localeOverride,
      themeMode: settings.themeMode,
      drawSettingsJson: drawSettingsJson,
    );
  }

  @override
  Future<void> saveSettings(AppSettingsModel settings) async {
    final record = AppSettingsRecord()
      ..id = 1
      ..localeOverride = settings.localeOverride
      ..drawSettingsJson = jsonEncode(settings.toDrawSettingsJson())
      ..themeMode = settings.themeMode;
    await _db.writeTxn(() async {
      await _db.appSettingsRecords.put(record);
    });
  }

  Map<String, dynamic> _decodeStringKeyMap(Map source) {
    final mapped = <String, dynamic>{};
    for (final entry in source.entries) {
      mapped[entry.key.toString()] = entry.value;
    }
    return mapped;
  }

  Future<void> _ensureSettingsExists() async {
    final hasSettings = await _db.appSettingsRecords.get(1);
    if (hasSettings != null) {
      return;
    }
    await _db.writeTxn(() async {
      await _db.appSettingsRecords.put(AppSettingsRecord());
    });
  }

  WheelModel _toWheelModel(WheelRecord wheel, List<WheelItemRecord> items) {
    return WheelModel(
      id: wheel.id,
      name: wheel.name,
      probabilityMode: wheel.probabilityMode,
      spinDurationMs: wheel.spinDurationMs,
      palette: wheel.palette,
      backgroundImagePath: wheel.backgroundImagePath,
      backgroundImageOpacity: wheel.backgroundImageOpacity,
      backgroundImageBlurSigma: wheel.backgroundImageBlurSigma,
      createdAt: wheel.createdAt,
      updatedAt: wheel.updatedAt,
      items: items
          .map(
            (item) => WheelItemModel(
              id: item.id,
              wheelId: item.wheelId,
              order: item.order,
              title: item.title,
              subtitle: item.subtitle,
              tags: item.tags,
              note: item.note,
              colorHex: item.colorHex,
              weight: item.weight,
              customFields: _decodeCustomFields(item.customFieldsJson),
            ),
          )
          .toList(),
    );
  }

  Map<String, String> _decodeCustomFields(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const {};
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return const {};
    }
    final map = <String, String>{};
    for (final entry in decoded.entries) {
      map[entry.key.toString()] = entry.value.toString();
    }
    return map;
  }
}
