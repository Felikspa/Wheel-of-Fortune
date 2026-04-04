import '../domain/models.dart';
import 'wheel_repository.dart';

class InMemoryWheelRepository implements WheelRepository {
  final List<WheelModel> _wheels = [];
  AppSettingsModel _settings = const AppSettingsModel();
  int _wheelId = 1;
  int _itemId = 1;

  @override
  Future<void> init() async {}

  @override
  Future<WheelModel> createWheel(String name) async {
    final now = DateTime.now();
    final wheel = WheelModel(
      id: _wheelId++,
      name: name,
      probabilityMode: ProbabilityMode.equal,
      spinDurationMs: 4800,
      palette: 'random',
      createdAt: now,
      updatedAt: now,
      items: const [],
    );
    _wheels.add(wheel);
    return wheel;
  }

  @override
  Future<void> deleteItem(int itemId) async {
    for (var i = 0; i < _wheels.length; i++) {
      final wheel = _wheels[i];
      final nextItems = wheel.items.where((item) => item.id != itemId).toList();
      if (nextItems.length != wheel.items.length) {
        _wheels[i] = wheel.copyWith(items: _normalizeOrders(nextItems));
      }
    }
  }

  @override
  Future<void> deleteWheel(int wheelId) async {
    _wheels.removeWhere((wheel) => wheel.id == wheelId);
  }

  @override
  Future<AppSettingsModel> loadSettings() async => _settings;

  @override
  Future<List<WheelModel>> loadWheels() async => List.unmodifiable(_wheels);

  @override
  Future<void> saveItems(int wheelId, List<WheelItemModel> items) async {
    final index = _wheels.indexWhere((wheel) => wheel.id == wheelId);
    if (index < 0) {
      return;
    }
    final withIds = items
        .map(
          (item) => item.copyWith(
            id: item.id == 0 ? _itemId++ : item.id,
            wheelId: wheelId,
          ),
        )
        .toList();
    _wheels[index] = _wheels[index].copyWith(
      items: _normalizeOrders(withIds),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> saveSettings(AppSettingsModel settings) async {
    _settings = settings;
  }

  @override
  Future<void> saveWheel(WheelModel wheel) async {
    final index = _wheels.indexWhere((entry) => entry.id == wheel.id);
    if (index >= 0) {
      _wheels[index] = wheel;
    }
  }

  List<WheelItemModel> _normalizeOrders(List<WheelItemModel> items) {
    return [
      for (var index = 0; index < items.length; index++)
        items[index].copyWith(order: index),
    ];
  }
}
