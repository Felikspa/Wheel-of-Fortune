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

class _WheelPageState extends State<WheelPage> with SingleTickerProviderStateMixin {
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
                  Text(l10n.noWheelsYet, style: Theme.of(context).textTheme.headlineSmall),
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

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                wheel.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.tapSliceForDetails,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: WheelCanvas(
                  wheel: wheel,
                  rotation: _rotation,
                  winnerItemId: controller.winnerItemId,
                  enabled: !controller.spinning,
                  onTapSlice: (index) => _showItemDetails(context, wheel.items[index]),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: canSpin ? () => _spin(context, controller, wheel) : null,
                child: Text(controller.spinning ? l10n.spinning : l10n.spin),
              ),
              const SizedBox(height: 8),
              if (wheel.items.length < 2)
                Text(
                  l10n.atLeastTwoItems,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 8),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: winner == null ? null : () => _showItemDetails(context, winner),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.result,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          winner?.title ?? l10n.noResultYet,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (winner?.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            winner!.subtitle!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
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

  Future<void> _spin(BuildContext context, AppController controller, WheelModel wheel) async {
    final outcome = controller.beginSpin();
    if (outcome == null) {
      return;
    }
    HapticFeedback.lightImpact();
    _animationController.duration = Duration(milliseconds: wheel.spinDurationMs);
    final curved = CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic);
    _rotationAnimation = Tween<double>(
      begin: _baseRotation,
      end: _baseRotation + outcome.targetDelta,
    ).animate(curved);
    await _animationController.forward(from: 0);
    _baseRotation = (_baseRotation + outcome.targetDelta) % (2 * pi);
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
                Text(item.subtitle!, style: Theme.of(context).textTheme.titleMedium),
              ],
              const SizedBox(height: 10),
              _detailRow(context, l10n.itemTags, item.tags),
              _detailRow(context, l10n.itemNote, item.note),
              _detailRow(context, l10n.itemColorHex, item.colorHex),
              _detailRow(context, l10n.itemWeight, item.weight?.toString()),
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
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
