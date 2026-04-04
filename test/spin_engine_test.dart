import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_of_fortune/src/domain/models.dart';
import 'package:wheel_of_fortune/src/services/spin_engine.dart';

void main() {
  group('SpinEngine', () {
    final items = [
      const WheelItemModel(id: 1, wheelId: 1, order: 0, title: 'A'),
      const WheelItemModel(id: 2, wheelId: 1, order: 1, title: 'B'),
      const WheelItemModel(id: 3, wheelId: 1, order: 2, title: 'C'),
    ];

    test('equal mode is approximately uniform', () {
      final engine = SpinEngine();
      final random = Random(42);
      final counts = [0, 0, 0];
      for (var i = 0; i < 6000; i++) {
        final result = engine.spin(items, ProbabilityMode.equal, random: random);
        counts[result.winnerIndex]++;
      }
      for (final count in counts) {
        final ratio = count / 6000;
        expect(ratio, inInclusiveRange(0.28, 0.38));
      }
    });

    test('weighted mode prefers larger weights and uses default weight 1', () {
      final engine = SpinEngine();
      final random = Random(9);
      final weightedItems = [
        items[0].copyWith(weight: 1),
        items[1].copyWith(weight: null),
        items[2].copyWith(weight: 7),
      ];
      final counts = [0, 0, 0];
      for (var i = 0; i < 5000; i++) {
        final result = engine.spin(weightedItems, ProbabilityMode.weighted, random: random);
        counts[result.winnerIndex]++;
      }
      expect(counts[2], greaterThan(counts[0]));
      expect(counts[2], greaterThan(counts[1]));
    });
  });
}
