import '../domain/models.dart';

abstract class WheelRepository {
  Future<void> init();

  Future<List<WheelModel>> loadWheels();

  Future<WheelModel> createWheel(String name);

  Future<void> saveWheel(WheelModel wheel);

  Future<void> deleteWheel(int wheelId);

  Future<void> saveItems(int wheelId, List<WheelItemModel> items);

  Future<void> deleteItem(int itemId);

  Future<AppSettingsModel> loadSettings();

  Future<void> saveSettings(AppSettingsModel settings);
}
