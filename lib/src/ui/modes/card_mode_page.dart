import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../domain/models.dart';
import '../../state/app_controller.dart';
import 'mode_visuals.dart';

class CardModePage extends StatefulWidget {
  const CardModePage({super.key, required this.onOpenManage});

  final VoidCallback onOpenManage;

  @override
  State<CardModePage> createState() => _CardModePageState();
}

class _CardModePageState extends State<CardModePage> {
  int? _lastWheelId;
  List<int> _orderedItemIds = const [];
  bool _hasShuffled = false;
  int? _revealedCardIndex;
  int _shuffleVersion = 0;

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

        _syncCardOrderWithWheel(wheel);
        final itemById = {for (final item in wheel.items) item.id: item};
        final winner = controller.winnerItemForMode(DrawDisplayMode.card);
        final revealAll = controller.cardRevealAllForSelectedWheel;

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
                            l10n.modeCardHint,
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
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DrawModeFrostedPanel(
                  accentColor: style.accentColor,
                  isDark: isDark,
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: Text(l10n.cardRevealAllToggle),
                    value: revealAll,
                    activeThumbColor: style.accentColor,
                    onChanged: controller.busy
                        ? null
                        : (value) {
                            controller.setCardRevealAllForSelectedWheel(value);
                          },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: DrawModeFrostedPanel(
                    accentColor: style.accentColor,
                    isDark: isDark,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: GridView.builder(
                      key: ValueKey<int>(_shuffleVersion),
                      itemCount: _orderedItemIds.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.72,
                          ),
                      itemBuilder: (context, index) {
                        final cardItemId = _orderedItemIds[index];
                        final showFront =
                            !_hasShuffled ||
                            (_revealedCardIndex != null &&
                                (revealAll || _revealedCardIndex == index));
                        final frontLabel = _revealedCardIndex == index
                            ? (winner?.title ?? l10n.noResultYet)
                            : (itemById[cardItemId]?.title ?? l10n.noResultYet);

                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap:
                              (!_hasShuffled ||
                                  _revealedCardIndex != null ||
                                  controller.busy)
                              ? null
                              : () => _revealCard(controller, index),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: showFront
                                ? _CardFace(
                                    key: ValueKey('front-$index-$frontLabel'),
                                    label: frontLabel,
                                    accentColor: style.accentColor,
                                    glowColor: style.glowColors[0],
                                    isDark: isDark,
                                  )
                                : _CardBack(
                                    key: ValueKey(
                                      'back-$index-$_shuffleVersion',
                                    ),
                                    accentColor: style.accentColor,
                                    isDark: isDark,
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                DrawModeGlassActionButton(
                  onPressed: controller.busy
                      ? null
                      : () => _shuffle(controller, wheel),
                  accentColor: style.accentColor,
                  onAccentColor: style.onAccentColor,
                  icon: controller.busy
                      ? Icons.motion_photos_paused_rounded
                      : Icons.shuffle_rounded,
                  label: controller.busy ? l10n.spinning : l10n.cardShuffle,
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

  void _syncCardOrderWithWheel(WheelModel wheel) {
    if (_lastWheelId != wheel.id) {
      _lastWheelId = wheel.id;
      _orderedItemIds = [for (final item in wheel.items) item.id];
      _hasShuffled = false;
      _revealedCardIndex = null;
      return;
    }

    final validIds = wheel.items.map((item) => item.id).toSet();
    final next = [
      for (final id in _orderedItemIds)
        if (validIds.contains(id)) id,
    ];
    for (final item in wheel.items) {
      if (!next.contains(item.id)) {
        next.add(item.id);
      }
    }
    _orderedItemIds = next;
    if (_revealedCardIndex != null &&
        _revealedCardIndex! >= _orderedItemIds.length) {
      _revealedCardIndex = null;
    }
  }

  Future<void> _shuffle(AppController controller, WheelModel wheel) async {
    final random = Random(DateTime.now().microsecondsSinceEpoch);
    final next = [for (final item in wheel.items) item.id]..shuffle(random);
    controller.beginAuxiliaryAnimation();
    setState(() {
      _orderedItemIds = next;
      _hasShuffled = true;
      _revealedCardIndex = null;
      _shuffleVersion++;
    });
    try {
      await Future<void>.delayed(const Duration(milliseconds: 420));
    } finally {
      controller.endAuxiliaryAnimation();
    }
  }

  void _revealCard(AppController controller, int index) {
    final winnerItemId = controller.drawCardForSelectedWheel(_orderedItemIds);
    if (winnerItemId == null) {
      return;
    }
    setState(() {
      _revealedCardIndex = index;
    });
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    super.key,
    required this.label,
    required this.accentColor,
    required this.glowColor,
    required this.isDark,
  });

  final String label;
  final Color accentColor;
  final Color glowColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: isDark ? 0.3 : 0.22),
            glowColor.withValues(alpha: isDark ? 0.24 : 0.16),
          ],
        ),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.48 : 0.34),
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({super.key, required this.accentColor, required this.isDark});

  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF161A24).withValues(alpha: 0.94),
                  const Color(0xFF10131B).withValues(alpha: 0.9),
                ]
              : [
                  Colors.white.withValues(alpha: 0.86),
                  const Color(0xFFF3F6FF).withValues(alpha: 0.8),
                ],
        ),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.4 : 0.28),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.style_rounded,
          color: accentColor.withValues(alpha: 0.78),
        ),
      ),
    );
  }
}
