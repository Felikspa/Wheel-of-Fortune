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

  test('quick import preserves custom fields', () async {
    final controller = AppController(repository: InMemoryWheelRepository());
    await controller.initialize();
    final summary = await controller.quickImportItemsToCurrentWheel(
      '苹果，site:楼下，type:午餐；香蕉，超市，水果；',
    );
    final wheel = controller.selectedWheel!;
    final imported = wheel.items.sublist(wheel.items.length - 2);

    expect(summary.importedItems, 2);
    expect(imported[0].customFields['site'], '楼下');
    expect(imported[0].customFields['type'], '午餐');
    expect(imported[1].customFields['site'], '超市');
    expect(imported[1].customFields['type'], '水果');
  });
}
