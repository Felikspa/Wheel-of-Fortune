import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_of_fortune/src/data/in_memory_wheel_repository.dart';
import 'package:wheel_of_fortune/src/domain/models.dart';
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

  test('display mode is persisted per wheel', () async {
    final controller = AppController(repository: InMemoryWheelRepository());
    await controller.initialize();
    final firstWheelId = controller.selectedWheel!.id;

    await controller.setSelectedDisplayMode(DrawDisplayMode.coin);
    await controller.createWheel('Second');
    final secondWheelId = controller.wheels.last.id;
    controller.selectWheel(secondWheelId);
    await controller.setSelectedDisplayMode(DrawDisplayMode.dice);

    expect(controller.selectedDisplayMode, DrawDisplayMode.dice);
    controller.selectWheel(firstWheelId);
    expect(controller.selectedDisplayMode, DrawDisplayMode.coin);
  });

  test('coin single selection requires manual second without valid partner', () async {
    final controller = AppController(repository: InMemoryWheelRepository());
    await controller.initialize();
    final wheel = controller.selectedWheel!;
    final firstId = wheel.items[0].id;
    final secondId = wheel.items[1].id;

    await controller.setCoinSelectionForSelectedWheel(
      firstItemId: firstId,
      secondItemId: null,
    );
    var resolved = controller.resolveCoinSelectionForSelectedWheel();
    expect(resolved.issue, CoinSelectionIssue.needManualSecond);

    await controller.setCoinSelectionForSelectedWheel(
      firstItemId: firstId,
      secondItemId: secondId,
    );
    await controller.setCoinSelectionForSelectedWheel(
      firstItemId: firstId,
      secondItemId: null,
    );
    resolved = controller.resolveCoinSelectionForSelectedWheel();
    expect(resolved.autoFilled, isTrue);
    expect(resolved.secondItemId, secondId);

    await controller.deleteItem(secondId);
    resolved = controller.resolveCoinSelectionForSelectedWheel();
    expect(resolved.issue, CoinSelectionIssue.needManualSecond);
    expect(resolved.secondItemId, isNull);
  });

  test('dice mapping seeds from recent sides and marks missing faces', () async {
    final controller = AppController(repository: InMemoryWheelRepository());
    await controller.initialize();
    final wheel = controller.selectedWheel!;
    final items = [
      for (var i = 0; i < 8; i++)
        WheelItemModel(
          id: i == 0 || i == 1 ? wheel.items[i].id : 0,
          wheelId: wheel.id,
          order: i,
          title: 'Option $i',
          weight: i == 7 ? 6 : 1,
        ),
    ];
    await controller.saveCurrentWheelItems(items);
    final updatedWheel = controller.selectedWheel!;

    await controller.setSelectedDiceSidesForSelectedWheel(6);
    for (var i = 0; i < 6; i++) {
      final ok = await controller.setDiceFaceItemForSelectedWheel(
        faceIndex: i,
        itemId: updatedWheel.items[i].id,
      );
      expect(ok, isTrue);
    }

    var validation = controller.validateSelectedDiceMapping();
    expect(validation.canRoll, isTrue);

    await controller.setSelectedDiceSidesForSelectedWheel(8);
    final mapping8 = controller.diceMappingForSelectedWheel();
    expect(mapping8.length, 8);
    expect(mapping8[0], updatedWheel.items[0].id);
    expect(mapping8[5], updatedWheel.items[5].id);
    expect(mapping8[6], isNull);
    expect(mapping8[7], isNull);

    await controller.deleteItem(updatedWheel.items[0].id);
    validation = controller.validateSelectedDiceMapping();
    expect(validation.canRoll, isFalse);
    expect(validation.missingFaces, isNotEmpty);
  });

  test('dice and card rolls follow weighted mode preference', () async {
    final controller = AppController(repository: InMemoryWheelRepository());
    await controller.initialize();
    final wheel = controller.selectedWheel!;
    final items = [
      for (var i = 0; i < 6; i++)
        WheelItemModel(
          id: i == 0 || i == 1 ? wheel.items[i].id : 0,
          wheelId: wheel.id,
          order: i,
          title: i == 5 ? 'Heavy' : 'Normal $i',
          weight: i == 5 ? 8 : 1,
        ),
    ];
    await controller.saveCurrentWheelItems(items);
    await controller.updateWheelConfig(
      wheelId: controller.selectedWheel!.id,
      mode: ProbabilityMode.weighted,
    );
    final current = controller.selectedWheel!;

    await controller.setSelectedDiceSidesForSelectedWheel(6);
    for (var i = 0; i < 6; i++) {
      final ok = await controller.setDiceFaceItemForSelectedWheel(
        faceIndex: i,
        itemId: current.items[i].id,
      );
      expect(ok, isTrue);
    }

    var diceHeavy = 0;
    var cardHeavy = 0;
    final heavyId = current.items.last.id;
    for (var i = 0; i < 300; i++) {
      final diceResult = controller.rollDiceForSelectedWheel();
      if (diceResult?.winnerItemId == heavyId) {
        diceHeavy++;
      }
      final cardResult = controller.drawCardForSelectedWheel(
        current.items.map((item) => item.id).toList(),
      );
      if (cardResult == heavyId) {
        cardHeavy++;
      }
    }

    expect(diceHeavy, greaterThan(90));
    expect(cardHeavy, greaterThan(90));
  });

  test('mode results are tracked per wheel and mode', () async {
    final controller = AppController(repository: InMemoryWheelRepository());
    await controller.initialize();
    final firstWheel = controller.selectedWheel!;
    await controller.setCoinSelectionForSelectedWheel(
      firstItemId: firstWheel.items[0].id,
      secondItemId: firstWheel.items[1].id,
    );
    final firstCoinWinner = controller.tossCoinForSelectedWheel(
      firstItemId: firstWheel.items[0].id,
      secondItemId: firstWheel.items[1].id,
    );
    expect(firstCoinWinner, isNotNull);

    await controller.createWheel('Second');
    final secondWheelId = controller.wheels.last.id;
    controller.selectWheel(secondWheelId);
    await controller.saveCurrentWheelItems(const [
      WheelItemModel(id: 0, wheelId: 0, order: 0, title: 'Second A'),
      WheelItemModel(id: 0, wheelId: 0, order: 1, title: 'Second B'),
    ]);
    final secondWheel = controller.selectedWheel!;
    await controller.setCoinSelectionForSelectedWheel(
      firstItemId: secondWheel.items[0].id,
      secondItemId: secondWheel.items[1].id,
    );
    final secondCoinWinner = controller.tossCoinForSelectedWheel(
      firstItemId: secondWheel.items[0].id,
      secondItemId: secondWheel.items[1].id,
    );
    expect(secondCoinWinner, isNotNull);

    expect(controller.winnerItemIdForMode(DrawDisplayMode.coin), secondCoinWinner);
    controller.selectWheel(firstWheel.id);
    expect(controller.winnerItemIdForMode(DrawDisplayMode.coin), firstCoinWinner);
  });
}
