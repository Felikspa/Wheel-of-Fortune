import 'dart:async';
import 'dart:math';

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

enum CoinSelectionIssue { noSelection, needManualSecond, invalidPair }

class CoinSelectionResolution {
  const CoinSelectionResolution({
    required this.firstItemId,
    required this.secondItemId,
    required this.autoFilled,
    required this.issue,
  });

  final int? firstItemId;
  final int? secondItemId;
  final bool autoFilled;
  final CoinSelectionIssue? issue;

  bool get canToss => issue == null && firstItemId != null && secondItemId != null;
}

class DiceMappingValidation {
  const DiceMappingValidation({
    required this.sides,
    required this.mapping,
    required this.missingFaces,
    required this.duplicateFaces,
  });

  final int sides;
  final List<int?> mapping;
  final List<int> missingFaces;
  final List<int> duplicateFaces;

  bool get canRoll => missingFaces.isEmpty && duplicateFaces.isEmpty;
}

class DiceRollResult {
  const DiceRollResult({required this.winnerItemId, required this.winnerFaceIndex});

  final int winnerItemId;
  final int winnerFaceIndex;
}

class AppController extends ChangeNotifier {
  static const minItemsPerWheel = 2;
  static const maxItemsPerWheel = 100;
  static const softModeWindowSize = 8;
  static const List<int> supportedDiceSides = [6, 8, 12, 20];

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
  bool _auxiliaryAnimating = false;
  List<WheelModel> _wheels = const [];
  int? _selectedWheelId;
  AppSettingsModel _settings = const AppSettingsModel();
  final Map<int, List<int>> _recentWinnerIdsByWheel = {};
  final Map<String, List<int>> _recentWinnerIdsByWheelAndMode = {};
  final Map<int, Map<DrawDisplayMode, int>> _winnerItemIdsByWheelAndMode = {};

  bool get loading => _loading;
  bool get spinning => _spinning;
  bool get auxiliaryAnimating => _auxiliaryAnimating;
  bool get busy => _spinning || _auxiliaryAnimating;
  List<WheelModel> get wheels => _wheels;
  int? get selectedWheelId => _selectedWheelId;
  AppSettingsModel get settings => _settings;

  WheelModel? get selectedWheel {
    final wheelId = _selectedWheelId;
    if (wheelId == null) {
      return null;
    }
    for (final wheel in _wheels) {
      if (wheel.id == wheelId) {
        return wheel;
      }
    }
    return null;
  }

  DrawDisplayMode get selectedDisplayMode {
    final wheelId = _selectedWheelId;
    if (wheelId == null) {
      return DrawDisplayMode.wheel;
    }
    return _settings.displayModeForWheel(wheelId);
  }

  int? get winnerItemId => winnerItemIdForMode(DrawDisplayMode.wheel);

  WheelItemModel? get winnerItem => winnerItemForMode(DrawDisplayMode.wheel);

  int get selectedDiceSidesForSelectedWheel {
    final wheelId = _selectedWheelId;
    if (wheelId == null) {
      return supportedDiceSides.first;
    }
    final sides = _settings.diceSettingsForWheel(wheelId).selectedSides;
    if (supportedDiceSides.contains(sides)) {
      return sides;
    }
    return supportedDiceSides.first;
  }

  bool get cardRevealAllForSelectedWheel {
    final wheelId = _selectedWheelId;
    if (wheelId == null) {
      return false;
    }
    return _settings.cardSettingsForWheel(wheelId).revealAllOnPick;
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
    _removeModeHistoryForWheel(wheelId);
    _winnerItemIdsByWheelAndMode.remove(wheelId);
    _settings = _settings.withoutWheelScopedSettings(wheelId);
    await _repository.saveSettings(_settings);
    await _reloadWheels();
  }

  void selectWheel(int wheelId) {
    _selectedWheelId = wheelId;
    notifyListeners();
  }

  Future<void> setSelectedDisplayMode(DrawDisplayMode mode) async {
    final wheelId = _selectedWheelId;
    if (wheelId == null) {
      return;
    }
    _settings = _settings.withDisplayModeForWheel(wheelId, mode);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  int? winnerItemIdForMode(DrawDisplayMode mode, {int? wheelId}) {
    final targetWheelId = wheelId ?? _selectedWheelId;
    if (targetWheelId == null) {
      return null;
    }
    return _winnerItemIdsByWheelAndMode[targetWheelId]?[mode];
  }

  WheelItemModel? winnerItemForMode(DrawDisplayMode mode, {int? wheelId}) {
    final wheel = _wheelById(wheelId ?? _selectedWheelId);
    if (wheel == null) {
      return null;
    }
    final winnerId = winnerItemIdForMode(mode, wheelId: wheel.id);
    if (winnerId == null) {
      return null;
    }
    for (final item in wheel.items) {
      if (item.id == winnerId) {
        return item;
      }
    }
    return null;
  }

  Future<void> saveCurrentWheelItems(List<WheelItemModel> items) async {
    final wheel = selectedWheel;
    if (wheel == null) {
      return;
    }
    final capped = items.take(maxItemsPerWheel).toList();
    final normalized = [
      for (var i = 0; i < capped.length; i++) capped[i].copyWith(wheelId: wheel.id, order: i),
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
    final updated = wheel.items.map((entry) => entry.id == item.id ? item : entry).toList();
    await saveCurrentWheelItems(updated);
  }

  Future<void> updateItemByOrder(int index, WheelItemModel item) async {
    final wheel = selectedWheel;
    if (wheel == null || index < 0 || index >= wheel.items.length) {
      return;
    }
    final updated = [...wheel.items];
    updated[index] = item.copyWith(id: wheel.items[index].id, wheelId: wheel.id, order: index);
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
    if (busy || wheel == null || wheel.items.length < minItemsPerWheel) {
      return null;
    }
    _spinning = true;
    _setModeWinnerItemId(wheel.id, DrawDisplayMode.wheel, null);
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
    final wheelId = _selectedWheelId;
    if (wheelId != null) {
      _setModeWinnerItemId(wheelId, DrawDisplayMode.wheel, outcome.winnerItemId);
      final history = [...?_recentWinnerIdsByWheel[wheelId], outcome.winnerItemId];
      if (history.length > softModeWindowSize) {
        history.removeRange(0, history.length - softModeWindowSize);
      }
      _recentWinnerIdsByWheel[wheelId] = history;
    }
    notifyListeners();
  }

  void beginAuxiliaryAnimation() {
    if (_auxiliaryAnimating) {
      return;
    }
    _auxiliaryAnimating = true;
    notifyListeners();
  }

  void endAuxiliaryAnimation() {
    if (!_auxiliaryAnimating) {
      return;
    }
    _auxiliaryAnimating = false;
    notifyListeners();
  }

  CoinSelectionResolution resolveCoinSelectionForSelectedWheel() {
    final wheel = selectedWheel;
    if (wheel == null || wheel.items.isEmpty) {
      return const CoinSelectionResolution(
        firstItemId: null,
        secondItemId: null,
        autoFilled: false,
        issue: CoinSelectionIssue.noSelection,
      );
    }
    final wheelId = wheel.id;
    final coinSettings = _settings.coinSettingsForWheel(wheelId);
    final validIds = wheel.items.map((item) => item.id).toSet();
    final first = validIds.contains(coinSettings.firstItemId) ? coinSettings.firstItemId : null;
    final second = validIds.contains(coinSettings.secondItemId) ? coinSettings.secondItemId : null;

    if (first != null && second != null) {
      if (first == second) {
        return CoinSelectionResolution(
          firstItemId: first,
          secondItemId: second,
          autoFilled: false,
          issue: CoinSelectionIssue.invalidPair,
        );
      }
      return CoinSelectionResolution(
        firstItemId: first,
        secondItemId: second,
        autoFilled: false,
        issue: null,
      );
    }

    final single = first ?? second;
    if (single == null) {
      return const CoinSelectionResolution(
        firstItemId: null,
        secondItemId: null,
        autoFilled: false,
        issue: CoinSelectionIssue.noSelection,
      );
    }

    final partner = coinSettings.lastPartnerByItemId[single];
    if (partner != null && partner != single && validIds.contains(partner)) {
      return CoinSelectionResolution(
        firstItemId: single,
        secondItemId: partner,
        autoFilled: true,
        issue: null,
      );
    }

    return CoinSelectionResolution(
      firstItemId: single,
      secondItemId: null,
      autoFilled: false,
      issue: CoinSelectionIssue.needManualSecond,
    );
  }

  Future<void> setCoinSelectionForSelectedWheel({
    required int? firstItemId,
    required int? secondItemId,
  }) async {
    final wheelId = _selectedWheelId;
    if (wheelId == null) {
      return;
    }
    final current = _settings.coinSettingsForWheel(wheelId);
    final partners = {...current.lastPartnerByItemId};
    if (firstItemId != null && secondItemId != null && firstItemId != secondItemId) {
      partners[firstItemId] = secondItemId;
      partners[secondItemId] = firstItemId;
    }
    final next = current.copyWith(
      firstItemId: firstItemId,
      secondItemId: secondItemId,
      clearFirstItemId: firstItemId == null,
      clearSecondItemId: secondItemId == null,
      lastPartnerByItemId: partners,
    );
    _settings = _settings.withCoinSettingsForWheel(wheelId, next);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  int? tossCoinForSelectedWheel({required int firstItemId, required int secondItemId}) {
    final wheel = selectedWheel;
    if (wheel == null || busy || firstItemId == secondItemId) {
      return null;
    }
    final validIds = wheel.items.map((item) => item.id).toSet();
    if (!validIds.contains(firstItemId) || !validIds.contains(secondItemId)) {
      return null;
    }
    final winner = Random().nextBool() ? firstItemId : secondItemId;
    _setModeWinnerItemId(wheel.id, DrawDisplayMode.coin, winner);
    notifyListeners();
    return winner;
  }

  Future<void> setSelectedDiceSidesForSelectedWheel(int sides) async {
    if (!supportedDiceSides.contains(sides)) {
      return;
    }
    final wheelId = _selectedWheelId;
    if (wheelId == null) {
      return;
    }
    final current = _settings.diceSettingsForWheel(wheelId);
    final mappings = _copyDiceMappings(current.mappingsBySides);
    if (!mappings.containsKey(sides)) {
      final recent = mappings[current.selectedSides];
      mappings[sides] = recent == null
          ? List<int?>.filled(sides, null)
          : _seedDiceMappingFromRecent(recent, sides);
    }
    final next = current.copyWith(selectedSides: sides, mappingsBySides: mappings);
    _settings = _settings.withDiceSettingsForWheel(wheelId, next);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  List<int?> diceMappingForSelectedWheel() {
    final wheelId = _selectedWheelId;
    if (wheelId == null) {
      return List<int?>.filled(selectedDiceSidesForSelectedWheel, null);
    }
    final settings = _settings.diceSettingsForWheel(wheelId);
    final sides = selectedDiceSidesForSelectedWheel;
    return _normalizeDiceMapping(settings.mappingsBySides[sides], sides);
  }

  Future<bool> setDiceFaceItemForSelectedWheel({
    required int faceIndex,
    required int? itemId,
  }) async {
    final wheelId = _selectedWheelId;
    if (wheelId == null) {
      return false;
    }
    final current = _settings.diceSettingsForWheel(wheelId);
    final sides = selectedDiceSidesForSelectedWheel;
    final mappings = _copyDiceMappings(current.mappingsBySides);
    final mapping = _normalizeDiceMapping(mappings[sides], sides);
    if (faceIndex < 0 || faceIndex >= mapping.length) {
      return false;
    }
    if (itemId != null) {
      for (var i = 0; i < mapping.length; i++) {
        if (i == faceIndex) {
          continue;
        }
        if (mapping[i] == itemId) {
          return false;
        }
      }
    }
    mapping[faceIndex] = itemId;
    mappings[sides] = mapping;
    final next = current.copyWith(selectedSides: sides, mappingsBySides: mappings);
    _settings = _settings.withDiceSettingsForWheel(wheelId, next);
    await _repository.saveSettings(_settings);
    notifyListeners();
    return true;
  }

  DiceMappingValidation validateSelectedDiceMapping() {
    final wheel = selectedWheel;
    final sides = selectedDiceSidesForSelectedWheel;
    if (wheel == null) {
      return DiceMappingValidation(
        sides: sides,
        mapping: List<int?>.filled(sides, null),
        missingFaces: List<int>.generate(sides, (index) => index),
        duplicateFaces: const [],
      );
    }
    final mapping = diceMappingForSelectedWheel();
    final validIds = wheel.items.map((item) => item.id).toSet();
    final missingFaces = <int>[];
    final duplicateFaces = <int>[];
    final seen = <int, int>{};

    for (var i = 0; i < mapping.length; i++) {
      final itemId = mapping[i];
      if (itemId == null || !validIds.contains(itemId)) {
        missingFaces.add(i);
        continue;
      }
      if (seen.containsKey(itemId)) {
        duplicateFaces.add(i);
        continue;
      }
      seen[itemId] = i;
    }

    return DiceMappingValidation(
      sides: sides,
      mapping: mapping,
      missingFaces: missingFaces,
      duplicateFaces: duplicateFaces,
    );
  }

  DiceRollResult? rollDiceForSelectedWheel() {
    final wheel = selectedWheel;
    if (wheel == null || busy) {
      return null;
    }
    final validation = validateSelectedDiceMapping();
    if (!validation.canRoll) {
      return null;
    }
    final mappedItems = <WheelItemModel>[];
    for (final itemId in validation.mapping) {
      if (itemId == null) {
        return null;
      }
      final item = wheel.items.firstWhere((entry) => entry.id == itemId);
      mappedItems.add(item);
    }

    final outcome = _spinEngine.spin(
      mappedItems,
      wheel.probabilityMode,
      recentWinnerItemIds: _recentWinnerIdsByWheelAndMode[_historyKey(wheel.id, DrawDisplayMode.dice)] ??
          const [],
    );

    final winnerFaceIndex = validation.mapping.indexOf(outcome.winnerItemId);
    if (winnerFaceIndex < 0) {
      return null;
    }

    _pushModeHistory(
      wheelId: wheel.id,
      mode: DrawDisplayMode.dice,
      winnerItemId: outcome.winnerItemId,
    );
    _setModeWinnerItemId(wheel.id, DrawDisplayMode.dice, outcome.winnerItemId);
    notifyListeners();

    return DiceRollResult(
      winnerItemId: outcome.winnerItemId,
      winnerFaceIndex: winnerFaceIndex,
    );
  }

  Future<void> setCardRevealAllForSelectedWheel(bool revealAll) async {
    final wheelId = _selectedWheelId;
    if (wheelId == null) {
      return;
    }
    final current = _settings.cardSettingsForWheel(wheelId);
    _settings = _settings.withCardSettingsForWheel(
      wheelId,
      current.copyWith(revealAllOnPick: revealAll),
    );
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  int? drawCardForSelectedWheel(List<int> candidateItemIds) {
    final wheel = selectedWheel;
    if (wheel == null || busy || candidateItemIds.isEmpty) {
      return null;
    }
    final itemById = {for (final item in wheel.items) item.id: item};
    final candidates = <WheelItemModel>[];
    for (final itemId in candidateItemIds) {
      final item = itemById[itemId];
      if (item != null) {
        candidates.add(item);
      }
    }
    if (candidates.isEmpty) {
      return null;
    }

    final outcome = _spinEngine.spin(
      candidates,
      wheel.probabilityMode,
      recentWinnerItemIds: _recentWinnerIdsByWheelAndMode[_historyKey(wheel.id, DrawDisplayMode.card)] ??
          const [],
    );

    _pushModeHistory(
      wheelId: wheel.id,
      mode: DrawDisplayMode.card,
      winnerItemId: outcome.winnerItemId,
    );
    _setModeWinnerItemId(wheel.id, DrawDisplayMode.card, outcome.winnerItemId);
    notifyListeners();
    return outcome.winnerItemId;
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
      return ImportSummary(created: false, validItems: 0, errors: parsed.errors);
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
    return ImportSummary(created: true, validItems: parsed.items.length, errors: parsed.errors);
  }

  Future<QuickItemsImportSummary> quickImportItemsToCurrentWheel(String text) async {
    final wheel = selectedWheel;
    if (wheel == null) {
      return const QuickItemsImportSummary(importedItems: 0, skippedByLimit: 0, errors: []);
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
        importItems[i].copyWith(wheelId: wheel.id, order: wheel.items.length + i),
    ];
    await saveCurrentWheelItems(nextItems);
    return QuickItemsImportSummary(
      importedItems: importItems.length,
      skippedByLimit: parsed.items.length - importItems.length,
      errors: parsed.errors,
    );
  }

  Future<void> setLocaleOverride(String? localeCode) async {
    _settings = _settings.copyWith(
      localeOverride: localeCode,
      clearLocaleOverride: localeCode == null,
    );
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    _settings = _settings.copyWith(themeMode: themeMode);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> _reloadWheels({bool createDefaultIfEmpty = false, bool notify = true}) async {
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

  WheelModel? _wheelById(int? wheelId) {
    if (wheelId == null) {
      return null;
    }
    for (final wheel in _wheels) {
      if (wheel.id == wheelId) {
        return wheel;
      }
    }
    return null;
  }

  void _setModeWinnerItemId(int wheelId, DrawDisplayMode mode, int? itemId) {
    final perMode = {...?_winnerItemIdsByWheelAndMode[wheelId]};
    if (itemId == null) {
      perMode.remove(mode);
    } else {
      perMode[mode] = itemId;
    }
    if (perMode.isEmpty) {
      _winnerItemIdsByWheelAndMode.remove(wheelId);
    } else {
      _winnerItemIdsByWheelAndMode[wheelId] = perMode;
    }
  }

  String _historyKey(int wheelId, DrawDisplayMode mode) => '$wheelId:${mode.name}';

  void _pushModeHistory({
    required int wheelId,
    required DrawDisplayMode mode,
    required int winnerItemId,
  }) {
    final key = _historyKey(wheelId, mode);
    final next = [...?_recentWinnerIdsByWheelAndMode[key], winnerItemId];
    if (next.length > softModeWindowSize) {
      next.removeRange(0, next.length - softModeWindowSize);
    }
    _recentWinnerIdsByWheelAndMode[key] = next;
  }

  void _removeModeHistoryForWheel(int wheelId) {
    final prefix = '$wheelId:';
    final removeKeys = <String>[];
    for (final key in _recentWinnerIdsByWheelAndMode.keys) {
      if (key.startsWith(prefix)) {
        removeKeys.add(key);
      }
    }
    for (final key in removeKeys) {
      _recentWinnerIdsByWheelAndMode.remove(key);
    }
  }

  Map<int, List<int?>> _copyDiceMappings(Map<int, List<int?>> source) {
    final copy = <int, List<int?>>{};
    for (final entry in source.entries) {
      copy[entry.key] = [...entry.value];
    }
    return copy;
  }

  List<int?> _seedDiceMappingFromRecent(List<int?> recent, int targetSides) {
    final seeded = List<int?>.filled(targetSides, null);
    final length = min(recent.length, targetSides);
    for (var i = 0; i < length; i++) {
      seeded[i] = recent[i];
    }
    return seeded;
  }

  List<int?> _normalizeDiceMapping(List<int?>? mapping, int sides) {
    if (mapping == null) {
      return List<int?>.filled(sides, null);
    }
    final normalized = List<int?>.filled(sides, null);
    final length = min(mapping.length, sides);
    for (var i = 0; i < length; i++) {
      normalized[i] = mapping[i];
    }
    return normalized;
  }
}
