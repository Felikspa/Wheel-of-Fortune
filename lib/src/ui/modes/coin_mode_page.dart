import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import 'mode_visuals.dart';

class CoinModePage extends StatefulWidget {
  const CoinModePage({super.key, required this.onOpenManage});

  final VoidCallback onOpenManage;

  @override
  State<CoinModePage> createState() => _CoinModePageState();
}

class _CoinModePageState extends State<CoinModePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 900),
        )..addListener(() {
          if (mounted) {
            setState(() {});
          }
        });
  }

  @override
  void dispose() {
    _flipController.dispose();
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
        final coinSettings = controller.settings.coinSettingsForWheel(wheel.id);
        final resolved = controller.resolveCoinSelectionForSelectedWheel();
        final winner = controller.winnerItemForMode(DrawDisplayMode.coin);
        final itemById = {for (final item in wheel.items) item.id: item};
        final firstSelection = itemById.containsKey(coinSettings.firstItemId)
            ? coinSettings.firstItemId
            : null;
        final secondSelection = itemById.containsKey(coinSettings.secondItemId)
            ? coinSettings.secondItemId
            : null;
        final faceLabel = _faceLabel(
          l10n: l10n,
          itemById: itemById,
          resolved: resolved,
          winner: winner,
        );

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
                            l10n.modeCoinHint,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    DrawModePillTag(
                      icon: Icons.tune_rounded,
                      text: l10n.modeEqual,
                      accentColor: style.accentColor,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                DrawModeFrostedPanel(
                  accentColor: style.accentColor,
                  isDark: isDark,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 360;
                      final firstField = _CoinSelectorField(
                        fieldKey: ValueKey<String>(
                          'coin-first-$firstSelection',
                        ),
                        initialValue: firstSelection,
                        label: l10n.coinSideA,
                        emptyLabel: l10n.notSelected,
                        items: wheel.items,
                        enabled: !controller.busy,
                        onChanged: (value) {
                          controller.setCoinSelectionForSelectedWheel(
                            firstItemId: value,
                            secondItemId: secondSelection,
                          );
                        },
                      );
                      final secondField = _CoinSelectorField(
                        fieldKey: ValueKey<String>(
                          'coin-second-$secondSelection',
                        ),
                        initialValue: secondSelection,
                        label: l10n.coinSideB,
                        emptyLabel: l10n.notSelected,
                        items: wheel.items,
                        enabled: !controller.busy,
                        onChanged: (value) {
                          controller.setCoinSelectionForSelectedWheel(
                            firstItemId: firstSelection,
                            secondItemId: value,
                          );
                        },
                      );

                      if (compact) {
                        return Column(
                          children: [
                            firstField,
                            const SizedBox(height: 10),
                            secondField,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: firstField),
                          const SizedBox(width: 10),
                          Expanded(child: secondField),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                if (resolved.autoFilled)
                  Text(
                    l10n.coinAutoFilledPartner,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (resolved.issue != null)
                  Text(
                    _issueLabel(l10n, resolved.issue!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      width: 228,
                      height: 228,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            style.accentColor.withValues(
                              alpha: isDark ? 0.34 : 0.26,
                            ),
                            style.glowColors[0].withValues(
                              alpha: isDark ? 0.28 : 0.2,
                            ),
                            style.glowColors[1].withValues(
                              alpha: isDark ? 0.24 : 0.18,
                            ),
                          ],
                        ),
                        border: Border.all(
                          color: style.accentColor.withValues(
                            alpha: isDark ? 0.58 : 0.38,
                          ),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: style.accentColor.withValues(
                              alpha: isDark ? 0.32 : 0.2,
                            ),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Text(
                            faceLabel,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                DrawModeGlassActionButton(
                  onPressed: !resolved.canToss || controller.busy
                      ? null
                      : () => _toss(controller, resolved),
                  accentColor: style.accentColor,
                  onAccentColor: style.onAccentColor,
                  icon: controller.busy
                      ? Icons.motion_photos_paused_rounded
                      : Icons.casino_rounded,
                  label: controller.busy ? l10n.spinning : l10n.coinToss,
                ),
                const SizedBox(height: 10),
                DrawModeResultCard(
                  title: l10n.result,
                  value: winner?.title ?? l10n.noResultYet,
                  accentColor: style.accentColor,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toss(
    AppController controller,
    CoinSelectionResolution resolved,
  ) async {
    final firstItemId = resolved.firstItemId;
    final secondItemId = resolved.secondItemId;
    if (firstItemId == null || secondItemId == null) {
      return;
    }
    final winnerId = controller.tossCoinForSelectedWheel(
      firstItemId: firstItemId,
      secondItemId: secondItemId,
    );
    if (winnerId == null) {
      return;
    }
    controller.beginAuxiliaryAnimation();
    try {
      await _flipController.forward(from: 0);
    } on TickerCanceled {
      // Expected when leaving page during active animation.
    } finally {
      controller.endAuxiliaryAnimation();
    }
  }

  String _faceLabel({
    required AppLocalizations l10n,
    required Map<int, WheelItemModel> itemById,
    required CoinSelectionResolution resolved,
    required WheelItemModel? winner,
  }) {
    if (_flipController.isAnimating && resolved.canToss) {
      final phase = ((_flipController.value * 12).floor()) % 2;
      final itemId = phase == 0 ? resolved.firstItemId : resolved.secondItemId;
      if (itemId != null) {
        final item = itemById[itemId];
        if (item != null) {
          return item.title;
        }
      }
    }
    if (winner != null) {
      return winner.title;
    }
    return l10n.coinReady;
  }

  String _issueLabel(AppLocalizations l10n, CoinSelectionIssue issue) {
    return switch (issue) {
      CoinSelectionIssue.noSelection => l10n.coinNeedSelection,
      CoinSelectionIssue.needManualSecond => l10n.coinNeedManualSecond,
      CoinSelectionIssue.invalidPair => l10n.coinNeedDistinct,
    };
  }
}

class _CoinSelectorField extends StatelessWidget {
  const _CoinSelectorField({
    required this.fieldKey,
    required this.initialValue,
    required this.label,
    required this.emptyLabel,
    required this.items,
    required this.enabled,
    required this.onChanged,
  });

  final Key fieldKey;
  final int? initialValue;
  final String label;
  final String emptyLabel;
  final List<WheelItemModel> items;
  final bool enabled;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      key: fieldKey,
      initialValue: initialValue,
      isExpanded: true,
      decoration: InputDecoration(
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text(emptyLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        for (final item in items)
          DropdownMenuItem<int?>(
            value: item.id,
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}
