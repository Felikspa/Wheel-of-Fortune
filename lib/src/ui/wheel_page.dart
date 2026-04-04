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
  Brightness? _lastBrightness;
  String? _lastPalette;
  String? _lastLocaleCode;
  String? _funHint;
  int _hintSeed = DateTime.now().microsecondsSinceEpoch;
  int _glowJitterSeed = DateTime.now().microsecondsSinceEpoch;
  Offset _glowJitterA = Offset.zero;
  Offset _glowJitterB = Offset.zero;
  double _glowScaleA = 0.86;
  double _glowScaleB = 0.94;

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
    _refreshGlowJitter();
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
    final localeCode = Localizations.localeOf(context).languageCode;
    return Consumer<AppController>(
      builder: (context, controller, _) {
        final wheel = controller.selectedWheel;
        if (_lastLocaleCode != localeCode) {
          _lastLocaleCode = localeCode;
          _refreshFunHint(localeCode: localeCode, wheelId: wheel?.id);
        }
        if (_lastSelectedWheelId != wheel?.id && !controller.spinning) {
          _lastSelectedWheelId = wheel?.id;
          _rotation = 0;
          _baseRotation = 0;
          _refreshGlowJitter(wheelId: wheel?.id, palette: wheel?.palette);
          _refreshFunHint(localeCode: localeCode, wheelId: wheel?.id);
        }
        if (_lastBrightness != Theme.of(context).brightness) {
          _lastBrightness = Theme.of(context).brightness;
          _refreshGlowJitter(wheelId: wheel?.id, palette: wheel?.palette);
        }
        if (_lastPalette != wheel?.palette) {
          _lastPalette = wheel?.palette;
          _refreshGlowJitter(wheelId: wheel?.id, palette: wheel?.palette);
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
        final accentColor = _paletteAccentColor(wheel.palette, isDark);
        final glowColors = _paletteGlowColors(wheel.palette, isDark);
        final onAccentColor = accentColor.computeLuminance() > 0.45
            ? Colors.black
            : Colors.white;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 46),
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
                          _funHint ?? l10n.tapSliceForDetails,
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
                    accentColor: accentColor,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = min(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return Center(
                      child: SizedBox(
                        width: size,
                        height: size,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: _buildGlowSource(
                                size: size,
                                alignment: Alignment(
                                  -0.58 + _glowJitterA.dx,
                                  -0.56 + _glowJitterA.dy,
                                ),
                                color: glowColors[0],
                                radiusFactor: _glowScaleA,
                                isDark: isDark,
                                tilt: -0.28,
                              ),
                            ),
                            Positioned.fill(
                              child: _buildGlowSource(
                                size: size,
                                alignment: Alignment(
                                  0.48 + _glowJitterB.dx,
                                  0.54 + _glowJitterB.dy,
                                ),
                                color: glowColors[1],
                                radiusFactor: _glowScaleB,
                                isDark: isDark,
                                tilt: 0.42,
                              ),
                            ),
                            WheelCanvas(
                              wheel: wheel,
                              rotation: _rotation,
                              winnerItemId: controller.winnerItemId,
                              enabled: !controller.spinning,
                              onTapSlice: (index) =>
                                  _showItemDetails(context, wheel.items[index]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: canSpin
                    ? () => _spin(context, controller, wheel)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: onAccentColor,
                ),
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
              const SizedBox(height: 8),
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
                        : accentColor.withValues(alpha: isDark ? 0.65 : 0.45),
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
                        Icon(
                          Icons.chevron_right_rounded,
                          color: winner == null ? null : accentColor,
                        ),
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
    _refreshFunHint(
      localeCode: Localizations.localeOf(context).languageCode,
      wheelId: wheel.id,
    );
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

  Color _paletteAccentColor(String palette, bool isDark) {
    return switch (palette) {
      'random' => isDark ? const Color(0xFFBFA3FF) : const Color(0xFF7367F0),
      'ocean' => isDark ? const Color(0xFF71C5FF) : const Color(0xFF2188F6),
      'sunset' => isDark ? const Color(0xFFFFA36E) : const Color(0xFFEE6C2B),
      'mint' => isDark ? const Color(0xFF7DE4CA) : const Color(0xFF16B38A),
      'mono' => isDark ? const Color(0xFF9EA7B4) : const Color(0xFF6F7783),
      'pink' => isDark ? const Color(0xFFFFA3C8) : const Color(0xFFFF8AB6),
      _ => isDark ? const Color(0xFF9AB4FF) : const Color(0xFF4E6BDB),
    };
  }

  List<Color> _paletteGlowColors(String palette, bool isDark) {
    return switch (palette) {
      'random' =>
        isDark
            ? [const Color(0xFF9E8BFF), const Color(0xFF54AFFF)]
            : [const Color(0xFF7A6CF4), const Color(0xFF3E8EF9)],
      'ocean' =>
        isDark
            ? [const Color(0xFF53B8FF), const Color(0xFF35D7C8)]
            : [const Color(0xFF2A96FF), const Color(0xFF2CCFBA)],
      'sunset' =>
        isDark
            ? [const Color(0xFFFF9B65), const Color(0xFFFF5A86)]
            : [const Color(0xFFF57A38), const Color(0xFFEC4E6F)],
      'mint' =>
        isDark
            ? [const Color(0xFF59DFC1), const Color(0xFF5CCBF7)]
            : [const Color(0xFF26C8A0), const Color(0xFF3AAAE8)],
      'mono' =>
        isDark
            ? [const Color(0xFF8D97A7), const Color(0xFF6B7585)]
            : [const Color(0xFF858E9A), const Color(0xFFA8B0BC)],
      'pink' =>
        isDark
            ? [const Color(0xFFFF79BA), const Color(0xFFAD8DFF)]
            : [const Color(0xFFFF63AE), const Color(0xFFC29CFF)],
      _ =>
        isDark
            ? [const Color(0xFF9AB4FF), const Color(0xFF6FA0FF)]
            : [const Color(0xFF4E6BDB), const Color(0xFF3F8AF1)],
    };
  }

  void _refreshGlowJitter({int? wheelId, String? palette}) {
    final seedBase =
        _glowJitterSeed ^
        (wheelId ?? 0) ^
        (palette?.hashCode ?? 0) ^
        DateTime.now().millisecondsSinceEpoch;
    final rng = Random(seedBase);
    _glowJitterA = Offset(
      (rng.nextDouble() - 0.5) * 0.18,
      (rng.nextDouble() - 0.5) * 0.18,
    );
    _glowJitterB = Offset(
      (rng.nextDouble() - 0.5) * 0.18,
      (rng.nextDouble() - 0.5) * 0.18,
    );
    _glowScaleA = 0.78 + rng.nextDouble() * 0.2;
    _glowScaleB = 0.86 + rng.nextDouble() * 0.22;
    _glowJitterSeed = seedBase ^ 0x5F3759DF;
  }

  void _refreshFunHint({required String localeCode, int? wheelId}) {
    final hints = localeCode.startsWith('zh') ? _funHintsZh : _funHintsEn;
    if (hints.isEmpty) {
      return;
    }
    final seedBase =
        _hintSeed ^ (wheelId ?? 0) ^ DateTime.now().millisecondsSinceEpoch;
    final rng = Random(seedBase);
    _funHint = hints[rng.nextInt(hints.length)];
    _hintSeed = seedBase ^ 0x9E3779B9;
  }

  Widget _buildGlowSource({
    required double size,
    required Alignment alignment,
    required Color color,
    required double radiusFactor,
    required bool isDark,
    required double tilt,
  }) {
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(tilt)
            ..scale(1.0, isDark ? 0.88 : 0.92),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size * radiusFactor * 1.16,
                height: size * radiusFactor * 1.16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: isDark ? 0.34 : 0.18),
                      color.withValues(alpha: isDark ? 0.12 : 0.06),
                      color.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              Container(
                width: size * radiusFactor * 0.78,
                height: size * radiusFactor * 0.78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: isDark ? 0.56 : 0.3),
                      color.withValues(alpha: isDark ? 0.24 : 0.12),
                      color.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.32, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: isDark ? 0.46 : 0.2),
                      blurRadius: size * 0.11,
                      spreadRadius: size * 0.008,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const List<String> _funHintsZh = [
    '今天想吃点儿什么？',
    '需要做哪些决定？',
    '来点随机好运气？',
    '纠结不如转一下',
    '今天就交给命运吧',
    '下一步做什么更合适？',
    '试试手气，马上出结果',
    '给自己一个惊喜选择',
  ];

  static const List<String> _funHintsEn = [
    'What are we in the mood for today?',
    'What decision should we make next?',
    'Need a little random luck?',
    'Stuck? Give it a spin.',
    'Let fate decide this round.',
    'What is the best next move?',
    'Spin once and get your answer.',
    'Pick a surprise option today.',
  ];

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
  const _PillTag({
    required this.icon,
    required this.text,
    required this.accentColor,
  });

  final IconData icon;
  final String text;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accentColor.withValues(alpha: isDark ? 0.18 : 0.14),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.45 : 0.28),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: accentColor),
          const SizedBox(width: 6),
          Text(text, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
