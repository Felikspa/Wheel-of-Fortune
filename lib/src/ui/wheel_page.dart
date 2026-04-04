import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../domain/models.dart';
import '../state/app_controller.dart';
import 'widgets/wheel_canvas.dart';

class WheelPage extends StatefulWidget {
  const WheelPage({super.key, required this.onOpenManage});

  final VoidCallback onOpenManage;

  @override
  State<WheelPage> createState() => _WheelPageState();
}

class _WheelPageState extends State<WheelPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  double _rotation = 0;
  double _baseRotation = 0;
  Animation<double>? _rotationAnimation;
  int? _lastSelectedWheelId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this)
      ..addListener(() {
        final animation = _rotationAnimation;
        if (animation != null) {
          setState(() => _rotation = animation.value);
        }
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<AppController>(
      builder: (context, controller, _) {
        final wheel = controller.selectedWheel;
        if (_lastSelectedWheelId != wheel?.id && !controller.spinning) {
          _lastSelectedWheelId = wheel?.id;
          _rotation = 0;
          _baseRotation = 0;
        }
        if (wheel == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.noWheelsYet,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.createFirstWheelHint,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: widget.onOpenManage,
                    child: Text(l10n.goToManage),
                  ),
                ],
              ),
            ),
          );
        }
        final canSpin = !controller.spinning && wheel.items.length >= 2;
        final winner = controller.winnerItem;
        final panelGradient = _panelGradientForPalette(wheel.palette, isDark);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
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
                          l10n.tapSliceForDetails,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _PillTag(
                    icon: Icons.tune_rounded,
                    text: wheel.probabilityMode == ProbabilityMode.equal
                        ? l10n.modeEqual
                        : l10n.modeWeighted,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: panelGradient,
                    ),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 24,
                        spreadRadius: 0,
                        offset: const Offset(0, 12),
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.35)
                            : const Color(0x3320355F),
                      ),
                    ],
                  ),
                  child: WheelCanvas(
                    wheel: wheel,
                    rotation: _rotation,
                    winnerItemId: controller.winnerItemId,
                    enabled: !controller.spinning,
                    onTapSlice: (index) =>
                        _showItemDetails(context, wheel.items[index]),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: canSpin
                    ? () => _spin(context, controller, wheel)
                    : null,
                icon: Icon(
                  controller.spinning
                      ? Icons.motion_photos_paused_rounded
                      : Icons.play_arrow_rounded,
                ),
                label: Text(controller.spinning ? l10n.spinning : l10n.spin),
              ),
              const SizedBox(height: 8),
              if (wheel.items.length < 2)
                Text(
                  l10n.atLeastTwoItems,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Theme.of(context).cardTheme.color,
                  border: Border.all(
                    color: winner == null
                        ? Theme.of(context).dividerTheme.color ??
                              Colors.transparent
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.36),
                    width: winner == null ? 1 : 1.6,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: winner == null
                      ? null
                      : () => _showItemDetails(context, winner),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.result,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                winner?.title ?? l10n.noResultYet,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (winner?.subtitle != null)
                                Text(
                                  winner!.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _spin(
    BuildContext context,
    AppController controller,
    WheelModel wheel,
  ) async {
    final outcome = controller.beginSpin();
    if (outcome == null) {
      return;
    }
    HapticFeedback.lightImpact();
    var delta = outcome.targetDelta - _baseRotation;
    while (delta < 4 * pi) {
      delta += 2 * pi;
    }
    _animationController.duration = Duration(
      milliseconds: wheel.spinDurationMs,
    );
    final curved = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _rotationAnimation = Tween<double>(
      begin: _baseRotation,
      end: _baseRotation + delta,
    ).animate(curved);
    await _animationController.forward(from: 0);
    _baseRotation = (_baseRotation + delta) % (2 * pi);
    _rotation = _baseRotation;
    controller.finishSpin(outcome);
    HapticFeedback.lightImpact();
  }

  Future<void> _showItemDetails(BuildContext context, WheelItemModel item) {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: Theme.of(context).textTheme.titleLarge),
              if (item.subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  item.subtitle!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
              const SizedBox(height: 10),
              _detailRow(context, l10n.itemTags, item.tags),
              _detailRow(context, l10n.itemNote, item.note),
              _detailRow(context, l10n.itemColorHex, item.colorHex),
              _detailRow(context, l10n.itemWeight, item.weight?.toString()),
              for (final entry in item.customFields.entries)
                _detailRow(context, entry.key, entry.value),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _panelGradientForPalette(String palette, bool isDark) {
    return switch (palette) {
      'random' =>
        isDark
            ? const [Color(0xCC231A2F), Color(0xCC152436)]
            : const [Color(0xFFFFF7FB), Color(0xFFEFF6FF)],
      'ocean' =>
        isDark
            ? const [Color(0xCC152233), Color(0xCC0E1826)]
            : const [Color(0xF5F8FCFF), Color(0xFFEAF2FF)],
      'sunset' =>
        isDark
            ? const [Color(0xCC302015), Color(0xCC221515)]
            : const [Color(0xFFFFF5EB), Color(0xFFFFECE6)],
      'mint' =>
        isDark
            ? const [Color(0xCC152A26), Color(0xCC101F1D)]
            : const [Color(0xFFEFFFFA), Color(0xFFE8FFF5)],
      'mono' =>
        isDark
            ? const [Color(0xCC20232B), Color(0xCC171A21)]
            : const [Color(0xFFF6F7FA), Color(0xFFECEFF4)],
      _ =>
        isDark
            ? const [Color(0xCC1A1E2A), Color(0xCC11141D)]
            : const [Color(0xF9FFFFFF), Color(0xFFF2F5FF)],
    };
  }

  Widget _detailRow(BuildContext context, String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _PillTag extends StatelessWidget {
  const _PillTag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: isDark
            ? Colors.white.withValues(alpha: 0.09)
            : Colors.black.withValues(alpha: 0.05),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(text, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
