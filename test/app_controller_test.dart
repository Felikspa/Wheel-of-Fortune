import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_of_fortune/src/data/in_memory_wheel_repository.dart';
import 'package:wheel_of_fortune/src/state/app_controller.dart';

void main() {
  test('quick import appends items to current wheel', () async {
    final controller = AppController(repository: InMemoryWheelRepository());
    await controller.initialize();
    final wheel = controller.selectedWheel!;
    final baseCount = wheel.items.length;

    final summary = await controller.quickImportItemsToCurrentWheel('apple;banana;');
    final updated = controller.selectedWheel!;

    expect(summary.importedItems, 2);
    expect(summary.errors, isEmpty);
    expect(updated.items.length, baseCount + 2);
    expect(updated.items[baseCount].title, 'apple');
    expect(updated.items[baseCount + 1].title, 'banana');
  });
}
