import 'dart:math';

import '../domain/models.dart';

class SpinOutcome {
  const SpinOutcome({
    required this.winnerIndex,
    required this.winnerItemId,
    required this.targetDelta,
    required this.initialVelocity,
  });

  final int winnerIndex;
  final int winnerItemId;
  final double targetDelta;
  final double initialVelocity;
}

class SpinEngine {
  static const int _softWindowSize = 8;
  static const double _softPenaltyAlpha = 1.15;

  SpinOutcome spin(
    List<WheelItemModel> items,
    ProbabilityMode mode, {
    Random? random,
    List<int> recentWinnerItemIds = const [],
  }) {
    final rng = random ?? Random();
    final winnerIndex = switch (mode) {
      ProbabilityMode.equal => rng.nextInt(items.length),
      ProbabilityMode.weighted => _chooseWeightedIndex(items, rng),
      ProbabilityMode.softAntiRepeat => _chooseSoftAntiRepeatIndex(
        items,
        rng,
        recentWinnerItemIds,
      ),
    };
    final itemCount = items.length;
    final wedgeAngle = (2 * pi) / itemCount;
    final edgeSafeMargin = wedgeAngle * 0.1;
    final randomOffsetInWedge =
        edgeSafeMargin + (rng.nextDouble() * (wedgeAngle - 2 * edgeSafeMargin));
    final landingAngle = (winnerIndex * wedgeAngle) + randomOffsetInWedge;
    final turns = 6 + rng.nextInt(4);
    final targetDelta = (turns * 2 * pi) - landingAngle;

    return SpinOutcome(
      winnerIndex: winnerIndex,
      winnerItemId: items[winnerIndex].id,
      targetDelta: targetDelta,
      initialVelocity: 12 + (rng.nextDouble() * 8),
    );
  }

  int _chooseSoftAntiRepeatIndex(
    List<WheelItemModel> items,
    Random rng,
    List<int> recentWinnerItemIds,
  ) {
    final recent = recentWinnerItemIds.length <= _softWindowSize
        ? recentWinnerItemIds
        : recentWinnerItemIds.sublist(
            recentWinnerItemIds.length - _softWindowSize,
          );
    final recentCounts = <int, int>{};
    for (final itemId in recent) {
      recentCounts[itemId] = (recentCounts[itemId] ?? 0) + 1;
    }

    final adjustedWeights = <double>[];
    for (final item in items) {
      final baseWeight = (item.weight == null || item.weight! <= 0)
          ? 1.0
          : item.weight!;
      final count = recentCounts[item.id] ?? 0;
      final penalty = exp(-_softPenaltyAlpha * count);
      adjustedWeights.add(baseWeight * penalty);
    }
    return _chooseIndexFromWeights(adjustedWeights, rng);
  }

  int _chooseIndexFromWeights(List<double> weights, Random rng) {
    final total = weights.fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) {
      return rng.nextInt(weights.length);
    }
    var target = rng.nextDouble() * total;
    for (var i = 0; i < weights.length; i++) {
      target -= weights[i];
      if (target <= 0) {
        return i;
      }
    }
    return weights.length - 1;
  }

  int _chooseWeightedIndex(List<WheelItemModel> items, Random rng) {
    final weights = items
        .map(
          (item) =>
              (item.weight == null || item.weight! <= 0) ? 1.0 : item.weight!,
        )
        .toList();
    return _chooseIndexFromWeights(weights, rng);
  }
}
