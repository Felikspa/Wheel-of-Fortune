import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import 'mode_visuals.dart';

class DiceModePage extends StatefulWidget {
  const DiceModePage({super.key, required this.onOpenManage});

  final VoidCallback onOpenManage;

  @override
  State<DiceModePage> createState() => _DiceModePageState();
}

class _DiceModePageState extends State<DiceModePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rollController;
  int _rollSeed = 1;
  int? _targetFaceIndex;

  @override
  void initState() {
    super.initState();
    _rollController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1100),
        )..addListener(() {
          if (mounted) {
            setState(() {});
          }
        });
  }

  @override
  void dispose() {
    _rollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AppController>(
      builder: (context, controller, _) {
        final wheel = controller.selectedWheel;
        if (wheel == null) {
          return DrawModeEmptyState(
            l10n: l10n,
            onOpenManage: widget.onOpenManage,
          );
        }
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final style = resolveDrawModeVisualStyle(
          palette: wheel.palette,
          isDark: isDark,
        );
        final sides = controller.selectedDiceSidesForSelectedWheel;
        final validation = controller.validateSelectedDiceMapping();
        final mapping = validation.mapping;
        final idUsageCounts = <int, int>{};
        for (final mappedId in mapping) {
          if (mappedId == null) {
            continue;
          }
          idUsageCounts[mappedId] = (idUsageCounts[mappedId] ?? 0) + 1;
        }
        final itemById = {for (final item in wheel.items) item.id: item};
        final shownFace = _displayFaceIndex(sides);
        final shownItemId = shownFace >= 0 && shownFace < mapping.length
            ? mapping[shownFace]
            : null;
        final shownItem = shownItemId == null ? null : itemById[shownItemId];
        final winner = controller.winnerItemForMode(DrawDisplayMode.dice);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 46),
          child: DrawModeGlowBackdrop(
            glowColors: style.glowColors,
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wheel.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.modeDiceHint,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    DrawModePillTag(
                      icon: Icons.tune_rounded,
                      text: switch (wheel.probabilityMode) {
                        ProbabilityMode.equal => l10n.modeEqual,
                        ProbabilityMode.weighted => l10n.modeWeighted,
                        ProbabilityMode.softAntiRepeat =>
                          l10n.modeSoftAntiRepeat,
                      },
                      accentColor: style.accentColor,
                      colorlessGlass: style.colorlessGlass,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DrawModeFrostedPanel(
                  accentColor: style.accentColor,
                  isDark: isDark,
                  colorlessGlass: style.colorlessGlass,
                  child: DropdownButtonFormField<int>(
                    key: ValueKey<String>('dice-sides-$sides'),
                    initialValue: sides,
                    isExpanded: true,
                    menuMaxHeight: 320,
                    decoration: InputDecoration(
                      labelText: l10n.diceSides,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      for (final value in AppController.supportedDiceSides)
                        DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        ),
                    ],
                    onChanged: controller.busy
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            _targetFaceIndex = null;
                            controller.setSelectedDiceSidesForSelectedWheel(
                              value,
                            );
                          },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: DrawModeFrostedPanel(
                    accentColor: style.accentColor,
                    isDark: isDark,
                    colorlessGlass: style.colorlessGlass,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: ListView.separated(
                      itemCount: sides,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final selectedItemId = mapping[index];
                        final isMissing =
                            selectedItemId != null &&
                            !itemById.containsKey(selectedItemId);

                        final items = <DropdownMenuItem<int?>>[
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text(
                              l10n.notSelected,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isMissing)
                            DropdownMenuItem<int?>(
                              value: selectedItemId,
                              child: Text(
                                l10n.diceMissingItem,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          for (final item in wheel.items)
                            DropdownMenuItem<int?>(
                              value: item.id,
                              enabled: item.id == selectedItemId
                                  ? true
                                  : (idUsageCounts[item.id] ?? 0) == 0,
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ];

                        return Row(
                          children: [
                            SizedBox(
                              width: 62,
                              child: Text(
                                l10n.diceFaceNumber('${index + 1}'),
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<int?>(
                                key: ValueKey<String>(
                                  'dice-face-$index-$selectedItemId',
                                ),
                                initialValue: selectedItemId,
                                isExpanded: true,
                                menuMaxHeight: 360,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                items: items,
                                onChanged: controller.busy
                                    ? null
                                    : (value) async {
                                        final ok = await controller
                                            .setDiceFaceItemForSelectedWheel(
                                              faceIndex: index,
                                              itemId: value,
                                            );
                                        if (!ok && context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                l10n.diceDuplicateNotAllowed,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (!validation.canRoll)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _mappingIssueLabel(l10n, validation),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        style.accentColor.withValues(
                          alpha: isDark ? 0.26 : 0.19,
                        ),
                        style.glowColors[0].withValues(
                          alpha: isDark ? 0.18 : 0.13,
                        ),
                      ],
                    ),
                    border: Border.all(
                      color: style.accentColor.withValues(
                        alpha: isDark ? 0.52 : 0.32,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'D$sides',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.diceFaceNumber('${shownFace + 1}'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        shownItem?.title ?? l10n.notSelected,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                DrawModeGlassActionButton(
                  onPressed: controller.busy || !validation.canRoll
                      ? null
                      : () => _roll(controller),
                  accentColor: style.accentColor,
                  onAccentColor: style.onAccentColor,
                  colorlessGlass: style.colorlessGlass,
                  icon: controller.busy
                      ? Icons.motion_photos_paused_rounded
                      : Icons.casino_rounded,
                  label: controller.busy ? l10n.spinning : l10n.diceRoll,
                ),
                const SizedBox(height: 10),
                DrawModeResultCard(
                  title: l10n.result,
                  value: winner?.title ?? l10n.noResultYet,
                  accentColor: style.accentColor,
                  isDark: isDark,
                  colorlessGlass: style.colorlessGlass,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _roll(AppController controller) async {
    final result = controller.rollDiceForSelectedWheel();
    if (result == null) {
      return;
    }
    _targetFaceIndex = result.winnerFaceIndex;
    _rollSeed = Random(DateTime.now().microsecondsSinceEpoch).nextInt(1 << 30);
    controller.beginAuxiliaryAnimation();
    try {
      await _rollController.forward(from: 0);
    } on TickerCanceled {
      // Expected when leaving page during active animation.
    } finally {
      controller.endAuxiliaryAnimation();
    }
  }

  int _displayFaceIndex(int sides) {
    if (_targetFaceIndex == null) {
      return 0;
    }
    if (!_rollController.isAnimating) {
      return _targetFaceIndex!.clamp(0, sides - 1);
    }
    final progress = _rollController.value;
    if (progress >= 0.82) {
      return _targetFaceIndex!.clamp(0, sides - 1);
    }
    final steps = (progress * 24).floor();
    return (steps + _rollSeed) % sides;
  }

  String _mappingIssueLabel(
    AppLocalizations l10n,
    DiceMappingValidation validation,
  ) {
    if (validation.missingFaces.isNotEmpty &&
        validation.duplicateFaces.isNotEmpty) {
      return '${l10n.diceNeedCompleteMapping}\n${l10n.diceDuplicateNotAllowed}';
    }
    if (validation.missingFaces.isNotEmpty) {
      return l10n.diceNeedCompleteMapping;
    }
    return l10n.diceDuplicateNotAllowed;
  }
}
