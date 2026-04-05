import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/wheel_repository.dart';
import '../domain/models.dart';
import '../services/spin_engine.dart';
import '../services/wheel_codec.dart';

class ImportSummary {
  const ImportSummary({
    required this.created,
    required this.validItems,
    required this.errors,
  });

  final bool created;
  final int validItems;
  final List<WheelImportError> errors;
}

class QuickItemsImportSummary {
  const QuickItemsImportSummary({
    required this.importedItems,
    required this.skippedByLimit,
    required this.errors,
  });

  final int importedItems;
  final int skippedByLimit;
  final List<WheelImportError> errors;
}

class AppController extends ChangeNotifier {
  static const minItemsPerWheel = 2;
  static const maxItemsPerWheel = 100;
  static const softModeWindowSize = 8;

  AppController({
    required WheelRepository repository,
    SpinEngine? spinEngine,
    WheelCodec? wheelCodec,
  }) : _repository = repository,
       _spinEngine = spinEngine ?? SpinEngine(),
       _wheelCodec = wheelCodec ?? WheelCodec();

  final WheelRepository _repository;
  final SpinEngine _spinEngine;
  final WheelCodec _wheelCodec;

  bool _loading = true;
  bool _spinning = false;
  List<WheelModel> _wheels = const [];
  int? _selectedWheelId;
  int? _winnerItemId;
  AppSettingsModel _settings = const AppSettingsModel();
  final Map<int, List<int>> _recentWinnerIdsByWheel = {};

  bool get loading => _loading;
  bool get spinning => _spinning;
  List<WheelModel> get wheels => _wheels;
  int? get selectedWheelId => _selectedWheelId;
  int? get winnerItemId => _winnerItemId;
  AppSettingsModel get settings => _settings;

  WheelModel? get selectedWheel {
    if (_selectedWheelId == null) {
      return null;
    }
    for (final wheel in _wheels) {
      if (wheel.id == _selectedWheelId) {
        return wheel;
      }
    }
    return null;
  }

  WheelItemModel? get winnerItem {
    final wheel = selectedWheel;
    if (wheel == null || _winnerItemId == null) {
      return null;
    }
    for (final item in wheel.items) {
      if (item.id == _winnerItemId) {
        return item;
      }
    }
    return null;
  }

  Future<void> initialize() async {
    await _repository.init();
    _settings = await _repository.loadSettings();
    await _reloadWheels(createDefaultIfEmpty: true, notify: false);
    _loading = false;
    notifyListeners();
  }

  Future<void> createWheel(String name) async {
    await _repository.createWheel(name);
    await _reloadWheels();
  }

  Future<void> renameWheel(int wheelId, String name) async {
    final wheel = _wheels.firstWhere((entry) => entry.id == wheelId);
    await _repository.saveWheel(
      wheel.copyWith(name: name, updatedAt: DateTime.now()),
    );
    await _reloadWheels();
  }

  Future<void> updateWheelConfig({
    required int wheelId,
    String? name,
    ProbabilityMode? mode,
    int? spinDurationMs,
    String? palette,
  }) async {
    final wheel = _wheels.firstWhere((entry) => entry.id == wheelId);
    await _repository.saveWheel(
      wheel.copyWith(
        name: name ?? wheel.name,
        probabilityMode: mode ?? wheel.probabilityMode,
        spinDurationMs: spinDurationMs ?? wheel.spinDurationMs,
        palette: palette ?? wheel.palette,
        updatedAt: DateTime.now(),
      ),
    );
    await _reloadWheels();
  }

  Future<void> deleteWheel(int wheelId) async {
    await _repository.deleteWheel(wheelId);
    _recentWinnerIdsByWheel.remove(wheelId);
    if (_selectedWheelId == wheelId) {
      _winnerItemId = null;
    }
    await _reloadWheels();
  }

  void selectWheel(int wheelId) {
    _selectedWheelId = wheelId;
    _winnerItemId = null;
    notifyListeners();
  }

  Future<void> saveCurrentWheelItems(List<WheelItemModel> items) async {
    final wheel = selectedWheel;
    if (wheel == null) {
      return;
    }
    final capped = items.take(maxItemsPerWheel).toList();
    final normalized = [
      for (var i = 0; i < capped.length; i++)
        capped[i].copyWith(wheelId: wheel.id, order: i),
    ];
    await _repository.saveItems(wheel.id, normalized);
    await _reloadWheels();
  }

  Future<void> addItem(WheelItemModel item) async {
    final wheel = selectedWheel;
    if (wheel == null || wheel.items.length >= maxItemsPerWheel) {
      return;
    }
    final updated = [
      ...wheel.items,
      item.copyWith(wheelId: wheel.id, order: wheel.items.length),
    ];
    await saveCurrentWheelItems(updated);
  }

  Future<void> updateItem(WheelItemModel item) async {
    final wheel = selectedWheel;
    if (wheel == null) {
      return;
    }
    final updated = wheel.items
        .map((entry) => entry.id == item.id ? item : entry)
        .toList();
    await saveCurrentWheelItems(updated);
  }

  Future<void> updateItemByOrder(int index, WheelItemModel item) async {
    final wheel = selectedWheel;
    if (wheel == null || index < 0 || index >= wheel.items.length) {
      return;
    }
    final updated = [...wheel.items];
    updated[index] = item.copyWith(
      id: wheel.items[index].id,
      wheelId: wheel.id,
      order: index,
    );
    await saveCurrentWheelItems(updated);
  }

  Future<void> deleteItem(int itemId) async {
    final wheel = selectedWheel;
    if (wheel == null) {
      return;
    }
    final updated = wheel.items.where((item) => item.id != itemId).toList();
    await saveCurrentWheelItems(updated);
  }

  Future<void> deleteItemByOrder(int index) async {
    final wheel = selectedWheel;
    if (wheel == null || index < 0 || index >= wheel.items.length) {
      return;
    }
    final updated = [...wheel.items]..removeAt(index);
    await saveCurrentWheelItems(updated);
  }

  SpinOutcome? beginSpin() {
    final wheel = selectedWheel;
    if (_spinning || wheel == null || wheel.items.length < minItemsPerWheel) {
      return null;
    }
    _spinning = true;
    _winnerItemId = null;
    final result = _spinEngine.spin(
      wheel.items,
      wheel.probabilityMode,
      recentWinnerItemIds: _recentWinnerIdsByWheel[wheel.id] ?? const [],
    );
    notifyListeners();
    return result;
  }

  void finishSpin(SpinOutcome outcome) {
    _spinning = false;
    _winnerItemId = outcome.winnerItemId;
    final wheelId = _selectedWheelId;
    if (wheelId != null) {
      final history = [
        ...?_recentWinnerIdsByWheel[wheelId],
        outcome.winnerItemId,
      ];
      if (history.length > softModeWindowSize) {
        history.removeRange(0, history.length - softModeWindowSize);
      }
      _recentWinnerIdsByWheel[wheelId] = history;
    }
    notifyListeners();
  }

  String exportCurrentWheel() {
    final wheel = selectedWheel;
    if (wheel == null) {
      return '';
    }
    return _wheelCodec.exportWheel(wheel, format: DslFormat.csv);
  }

  Future<ImportSummary> importFromCode(String text) async {
    final parsed = _wheelCodec.importWheel(text);
    if (parsed.items.isEmpty) {
      return ImportSummary(
        created: false,
        validItems: 0,
        errors: parsed.errors,
      );
    }
    final created = await _repository.createWheel(parsed.name);
    final configured = created.copyWith(
      probabilityMode: parsed.probabilityMode,
      spinDurationMs: parsed.spinDurationMs,
      palette: parsed.palette,
      updatedAt: DateTime.now(),
    );
    await _repository.saveWheel(configured);
    await _repository.saveItems(created.id, [
      for (var i = 0; i < parsed.items.take(maxItemsPerWheel).length; i++)
        parsed.items[i].copyWith(wheelId: created.id, order: i),
    ]);
    await _reloadWheels(notify: false);
    _selectedWheelId = created.id;
    notifyListeners();
    return ImportSummary(
      created: true,
      validItems: parsed.items.length,
      errors: parsed.errors,
    );
  }

  Future<QuickItemsImportSummary> quickImportItemsToCurrentWheel(
    String text,
  ) async {
    final wheel = selectedWheel;
    if (wheel == null) {
      return const QuickItemsImportSummary(
        importedItems: 0,
        skippedByLimit: 0,
        errors: [],
      );
    }

    final parsed = _wheelCodec.importQuickItems(text);
    if (parsed.items.isEmpty) {
      return QuickItemsImportSummary(
        importedItems: 0,
        skippedByLimit: 0,
        errors: parsed.errors,
      );
    }

    final allowed = maxItemsPerWheel - wheel.items.length;
    if (allowed <= 0) {
      return QuickItemsImportSummary(
        importedItems: 0,
        skippedByLimit: parsed.items.length,
        errors: parsed.errors,
      );
    }

    final importItems = parsed.items.take(allowed).toList();
    final nextItems = [
      ...wheel.items,
      for (var i = 0; i < importItems.length; i++)
        importItems[i].copyWith(
          wheelId: wheel.id,
          order: wheel.items.length + i,
        ),
    ];
    await saveCurrentWheelItems(nextItems);
    return QuickItemsImportSummary(
      importedItems: importItems.length,
      skippedByLimit: parsed.items.length - importItems.length,
      errors: parsed.errors,
    );
  }

  Future<void> setLocaleOverride(String? localeCode) async {
    _settings = AppSettingsModel(
      localeOverride: localeCode,
      themeMode: _settings.themeMode,
    );
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    _settings = AppSettingsModel(
      localeOverride: _settings.localeOverride,
      themeMode: themeMode,
    );
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> _reloadWheels({
    bool createDefaultIfEmpty = false,
    bool notify = true,
  }) async {
    _wheels = await _repository.loadWheels();
    if (_wheels.isEmpty && createDefaultIfEmpty) {
      final created = await _repository.createWheel('Wheel 1');
      await _repository.saveItems(created.id, const [
        WheelItemModel(id: 0, wheelId: 0, order: 0, title: 'Option A'),
        WheelItemModel(id: 0, wheelId: 0, order: 1, title: 'Option B'),
      ]);
      _wheels = await _repository.loadWheels();
    }

    if (_wheels.isEmpty) {
      _selectedWheelId = null;
      if (notify) {
        notifyListeners();
      }
      return;
    }

    final selectedExists = _wheels.any((wheel) => wheel.id == _selectedWheelId);
    if (!selectedExists) {
      _selectedWheelId = _wheels.first.id;
    }
    if (notify) {
      notifyListeners();
    }
  }
}
