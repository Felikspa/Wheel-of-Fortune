import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../domain/models.dart';
import '../services/spin_engine.dart';
import '../state/app_controller.dart';
import 'widgets/liquid_glass_chrome.dart';
import 'wheel_ui_tuning.dart';
import 'widgets/wheel_canvas.dart';

class WheelPage extends StatefulWidget {
  const WheelPage({super.key, required this.onOpenManage});

  final VoidCallback onOpenManage;

  @override
  State<WheelPage> createState() => _WheelPageState();
}

class _WheelPageState extends State<WheelPage> with TickerProviderStateMixin {
  late final TransformationController _wheelTransformController;
  late final Ticker _spinTicker;
  double _rotation = 0;
  double _baseRotation = 0;
  int? _lastSelectedWheelId;
  Brightness? _lastBrightness;
  String? _lastPalette;
  String? _lastLocaleCode;
  String? _funHint;
  int _hintSeed = DateTime.now().microsecondsSinceEpoch;
  int _glowJitterSeed = DateTime.now().microsecondsSinceEpoch;
  int _sliceLightSeed = DateTime.now().microsecondsSinceEpoch ^ 0x2E1B4C3A;
  Alignment _glowAlignmentA = const Alignment(-0.58, -0.56);
  Alignment _glowAlignmentB = const Alignment(0.48, 0.54);
  Offset _glowJitterA = Offset.zero;
  Offset _glowJitterB = Offset.zero;
  double _glowScaleA = 0.86;
  double _glowScaleB = 0.94;
  Alignment _sliceSheenCenter = const Alignment(-0.16, -0.12);
  Alignment _sliceDepthCenter = const Alignment(0.2, 0.16);
  double _sliceSheenIntensity = 1.0;
  double _sliceDepthIntensity = 1.0;
  double _wheelDetailScale = 1.0;
  double? _pendingWheelDetailScale;
  bool _wheelDetailScaleUpdateScheduled = false;
  double? _lastLayoutWheelSize;
  Size _wheelViewportSize = Size.zero;
  double _wheelBaseSize = 0;
  bool _syncingWheelTransform = false;
  bool _viewportResetScheduled = false;
  int? _edgePointerId;
  bool _edgePointerOnRim = false;
  Offset? _edgeDownLocal;
  Duration? _edgeDownTime;
  Timer? _edgePressTimer;
  Timer? _brakeHapticTimer;
  bool _edgeBrakeActive = false;
  bool _spinRunning = false;
  bool _spinTargeted = false;
  double _spinAngularVelocity = 0;
  double _spinInitialVelocity = 0;
  Duration _spinLastElapsed = Duration.zero;
  AppController? _spinController;
  WheelModel? _spinWheel;
  SpinOutcome? _targetSpinOutcome;
  double _targetSpinStart = 0;
  double _targetSpinEnd = 0;
  double _targetSpinDurationSec = 0;
  double _targetSpinElapsedSec = 0;

  @override
  void initState() {
    super.initState();
    _wheelTransformController = TransformationController()
      ..addListener(_handleWheelTransformChanged);
    _spinTicker = createTicker(_onSpinTick);
    _refreshGlowJitter();
    _refreshSliceLight();
  }

  @override
  void dispose() {
    _edgePressTimer?.cancel();
    _brakeHapticTimer?.cancel();
    _spinTicker.dispose();
    _wheelTransformController.removeListener(_handleWheelTransformChanged);
    _wheelTransformController.dispose();
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
          final restored = wheel == null
              ? false
              : _restoreWheelViewportIfAvailable(
                  controller: controller,
                  wheelId: wheel.id,
                );
          if (!restored) {
            _rotation = 0;
            _baseRotation = 0;
            _wheelDetailScale = 1.0;
            _scheduleWheelViewportReset();
          }
          _refreshGlowJitter(wheelId: wheel?.id, palette: wheel?.palette);
          _refreshSliceLight(wheelId: wheel?.id, palette: wheel?.palette);
          _refreshFunHint(localeCode: localeCode, wheelId: wheel?.id);
        }
        if (_lastBrightness != Theme.of(context).brightness) {
          _lastBrightness = Theme.of(context).brightness;
        }
        if (_lastPalette != wheel?.palette) {
          _lastPalette = wheel?.palette;
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
          padding: WheelUiTuning.pagePadding,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxDimension = max(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final wheelSize =
                  constraints.maxWidth * WheelUiTuning.wheelSizeByWidthFactor;
              if (_lastLayoutWheelSize == null ||
                  (_lastLayoutWheelSize! - wheelSize).abs() > 0.5) {
                _lastLayoutWheelSize = wheelSize;
                final hasCachedViewport = controller.wheelViewportStateForWheel(
                  wheel.id,
                );
                if (hasCachedViewport == null) {
                  _scheduleWheelViewportReset();
                }
              }
              _wheelViewportSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              _wheelBaseSize = wheelSize;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      transformationController: _wheelTransformController,
                      minScale: 1.0,
                      maxScale: WheelUiTuning.wheelMaxScale,
                      panEnabled:
                          !controller.spinning &&
                          _wheelDetailScale >
                              WheelUiTuning.panEnableScaleThreshold,
                      scaleEnabled: !controller.spinning,
                      boundaryMargin: EdgeInsets.all(
                        maxDimension * WheelUiTuning.wheelBoundaryMarginFactor,
                      ),
                      clipBehavior: Clip.none,
                      child: SizedBox.expand(
                        child: Align(
                          alignment: const Alignment(
                            0,
                            WheelUiTuning.wheelVerticalAlignmentY,
                          ),
                          child: Listener(
                            behavior: HitTestBehavior.translucent,
                            onPointerDown: (event) => _onWheelPointerDown(
                              event: event,
                              size: wheelSize,
                            ),
                            onPointerMove: (event) => _onWheelPointerMove(
                              event: event,
                              size: wheelSize,
                            ),
                            onPointerUp: (event) => _onWheelPointerUp(
                              event: event,
                              size: wheelSize,
                              controller: controller,
                              wheel: wheel,
                            ),
                            onPointerCancel: _onWheelPointerCancel,
                            child: SizedBox(
                              width: wheelSize,
                              height: wheelSize,
                              child: Opacity(
                                opacity: 0,
                                child: RepaintBoundary(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned.fill(
                                        child: _buildGlowSource(
                                          size: wheelSize,
                                          alignment: Alignment(
                                            _glowAlignmentA.x + _glowJitterA.dx,
                                            _glowAlignmentA.y + _glowJitterA.dy,
                                          ),
                                          color: glowColors[0],
                                          radiusFactor: _glowScaleA,
                                          isDark: isDark,
                                          tilt: -0.28,
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: _buildGlowSource(
                                          size: wheelSize,
                                          alignment: Alignment(
                                            _glowAlignmentB.x + _glowJitterB.dx,
                                            _glowAlignmentB.y + _glowJitterB.dy,
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
                                        detailScale: _wheelDetailScale,
                                        materialSheenCenter: _sliceSheenCenter,
                                        materialDepthCenter: _sliceDepthCenter,
                                        materialSheenIntensity:
                                            _sliceSheenIntensity,
                                        materialDepthIntensity:
                                            _sliceDepthIntensity,
                                        onTapSlice: (index) => _showItemDetails(
                                          context,
                                          wheel.items[index],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
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
                            text: switch (wheel.probabilityMode) {
                              ProbabilityMode.equal => l10n.modeEqual,
                              ProbabilityMode.weighted => l10n.modeWeighted,
                              ProbabilityMode.softAntiRepeat =>
                                l10n.modeSoftAntiRepeat,
                            },
                            accentColor: accentColor,
                          ),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(height: WheelUiTuning.spinControlsTopGap),
                      _LiquidGlassSpinButton(
                        onPressed: canSpin
                            ? () => _spin(context, controller, wheel)
                            : null,
                        accentColor: accentColor,
                        onAccentColor: onAccentColor,
                        icon: controller.spinning
                            ? Icons.motion_photos_paused_rounded
                            : Icons.play_arrow_rounded,
                        label: controller.spinning ? l10n.spinning : l10n.spin,
                      ),
                      const SizedBox(height: 4),
                      if (wheel.items.length < 2)
                        Text(
                          l10n.atLeastTwoItems,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      const SizedBox(height: 4),
                      LiquidGlassChrome(
                        borderRadius: 22,
                        accentColor: accentColor,
                        isDark: isDark,
                        shadowStrength: 1.0,
                        highlightStrength: 1.0,
                        child: GlassContainer(
                          useOwnLayer: true,
                          quality: GlassQuality.premium,
                          shape: const LiquidRoundedSuperellipse(
                            borderRadius: 22,
                          ),
                          settings: LiquidGlassSettings(
                            thickness: isDark ? 22 : 25,
                            blur: 0,
                            glassColor: accentColor.withValues(
                              alpha: isDark ? 0.04 : 0.045,
                            ),
                            lightAngle: isDark ? pi * 0.76 : pi * 0.72,
                            lightIntensity: isDark ? 0.0 : 1.0,
                            ambientStrength: isDark ? 0.0 : 0.03,
                            refractiveIndex: 1.5,
                            saturation: 0.92,
                            chromaticAberration: 0,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: winner == null
                                  ? null
                                  : () => _showItemDetails(context, winner),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  14,
                                  14,
                                  14,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.result,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelLarge,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            winner?.title ?? l10n.noResultYet,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          if (winner?.subtitle != null)
                                            Text(
                                              winner!.subtitle!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: winner == null
                                          ? null
                                          : accentColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
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
    _startTargetedSpin(controller: controller, wheel: wheel, outcome: outcome);
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
    final angleA = rng.nextDouble() * 2 * pi;
    final distA = 0.46 + rng.nextDouble() * 0.34;
    _glowAlignmentA = Alignment(cos(angleA) * distA, sin(angleA) * distA);
    final angleB = angleA + pi + (rng.nextDouble() - 0.5) * 0.76;
    final distB = 0.44 + rng.nextDouble() * 0.34;
    _glowAlignmentB = Alignment(cos(angleB) * distB, sin(angleB) * distB);
    _glowJitterA = Offset(
      (rng.nextDouble() - 0.5) * 0.1,
      (rng.nextDouble() - 0.5) * 0.1,
    );
    _glowJitterB = Offset(
      (rng.nextDouble() - 0.5) * 0.1,
      (rng.nextDouble() - 0.5) * 0.1,
    );
    _glowScaleA = 0.78 + rng.nextDouble() * 0.2;
    _glowScaleB = 0.86 + rng.nextDouble() * 0.22;
    _glowJitterSeed = seedBase ^ 0x5F3759DF;
  }

  void _refreshSliceLight({int? wheelId, String? palette}) {
    final seedBase =
        _sliceLightSeed ^
        (wheelId ?? 0) ^
        (palette?.hashCode ?? 0) ^
        DateTime.now().millisecondsSinceEpoch;
    final rng = Random(seedBase);
    const anchors = <Alignment>[
      Alignment(-0.72, -0.68),
      Alignment(-0.08, -0.84),
      Alignment(0.64, -0.62),
      Alignment(0.82, -0.06),
      Alignment(0.7, 0.64),
      Alignment(0.04, 0.84),
      Alignment(-0.68, 0.7),
      Alignment(-0.84, 0.02),
    ];
    final anchor = anchors[rng.nextInt(anchors.length)];
    final jitterX = (rng.nextDouble() - 0.5) * 0.22;
    final jitterY = (rng.nextDouble() - 0.5) * 0.22;
    _sliceSheenCenter = Alignment(
      (anchor.x + jitterX).clamp(-0.9, 0.9).toDouble(),
      (anchor.y + jitterY).clamp(-0.9, 0.9).toDouble(),
    );
    final depthBase = Alignment(-anchor.x, -anchor.y);
    final depthJitterX = (rng.nextDouble() - 0.5) * 0.18;
    final depthJitterY = (rng.nextDouble() - 0.5) * 0.18;
    _sliceDepthCenter = Alignment(
      (depthBase.x + depthJitterX).clamp(-0.92, 0.92).toDouble(),
      (depthBase.y + depthJitterY).clamp(-0.92, 0.92).toDouble(),
    );
    _sliceSheenIntensity = 0.92 + rng.nextDouble() * 0.3;
    _sliceDepthIntensity = 0.76 + rng.nextDouble() * 0.24;
    _sliceLightSeed = seedBase ^ 0x6A09E667;
  }

  void _onWheelPointerDown({
    required PointerDownEvent event,
    required double size,
  }) {
    if (_edgePointerId != null) {
      return;
    }
    _edgePointerId = event.pointer;
    _edgePointerOnRim = _isEdgeTouch(local: event.localPosition, size: size);
    _edgeDownLocal = event.localPosition;
    _edgeDownTime = event.timeStamp;

    if (_spinRunning && _edgePointerOnRim) {
      _edgePressTimer?.cancel();
      _edgePressTimer = Timer(
        Duration(milliseconds: WheelUiTuning.brakePressDelayMs),
        () {
          if (!_spinRunning || _edgePointerId == null) {
            return;
          }
          _setEdgeBrakeActive(true);
        },
      );
    }
  }

  void _onWheelPointerMove({
    required PointerMoveEvent event,
    required double size,
  }) {
    if (event.pointer != _edgePointerId) {
      return;
    }
    if (!_edgePointerOnRim &&
        _isEdgeTouch(local: event.localPosition, size: size)) {
      _edgePointerOnRim = true;
    }

    if (_spinRunning) {
      final stillOnRim = _isEdgeTouch(local: event.localPosition, size: size);
      if (!stillOnRim) {
        _setEdgeBrakeActive(false);
      }
    }
  }

  void _onWheelPointerUp({
    required PointerUpEvent event,
    required double size,
    required AppController controller,
    required WheelModel wheel,
  }) {
    if (event.pointer != _edgePointerId) {
      return;
    }
    _edgePressTimer?.cancel();
    _setEdgeBrakeActive(false);

    final wasOnRim = _edgePointerOnRim;
    final downLocal = _edgeDownLocal;
    final downTime = _edgeDownTime;
    final upLocal = event.localPosition;
    final upTime = event.timeStamp;
    final endedOnRim = _isEdgeTouch(local: upLocal, size: size);
    _resetEdgePointerTracking();

    if ((!wasOnRim && !endedOnRim) ||
        controller.spinning ||
        _wheelDetailScale > WheelUiTuning.panEnableScaleThreshold) {
      return;
    }
    if (downLocal == null || downTime == null) {
      return;
    }
    final dtMicros = (upTime - downTime).inMicroseconds;
    if (dtMicros <= 0) {
      return;
    }
    final velocity = (upLocal - downLocal) / (dtMicros / 1e6);
    final sideSwipeVelocity = _projectSideSwipeVelocity(
      velocity: velocity,
      local: upLocal,
      size: size,
    );
    if (sideSwipeVelocity.abs() <
        WheelUiTuning.flickTangentialVelocityThreshold) {
      return;
    }
    final angularVelocity = sideSwipeVelocity / (size / 2);
    _startFreeSpin(
      controller: controller,
      wheel: wheel,
      angularVelocity: angularVelocity,
    );
  }

  void _onWheelPointerCancel(PointerCancelEvent event) {
    if (event.pointer != _edgePointerId) {
      return;
    }
    _edgePressTimer?.cancel();
    _setEdgeBrakeActive(false);
    _resetEdgePointerTracking();
  }

  bool _isEdgeTouch({required Offset local, required double size}) {
    final center = Offset(size / 2, size / 2);
    final vector = local - center;
    final distance = vector.distance;
    final radius = size / 2;
    if (distance < radius * WheelUiTuning.edgeTouchInnerRadiusFactor ||
        distance > radius * WheelUiTuning.edgeTouchOuterRadiusFactor) {
      return false;
    }
    return vector.dx.abs() >=
        radius * WheelUiTuning.edgeTouchSideBandMinXFactor;
  }

  double _projectSideSwipeVelocity({
    required Offset velocity,
    required Offset local,
    required double size,
  }) {
    final center = Offset(size / 2, size / 2);
    final vector = local - center;
    final sideSign = vector.dx >= 0 ? 1.0 : -1.0;
    return velocity.dy * sideSign;
  }

  void _startTargetedSpin({
    required AppController controller,
    required WheelModel wheel,
    required SpinOutcome outcome,
  }) {
    if (_spinRunning) {
      return;
    }
    var delta = outcome.targetDelta - _baseRotation;
    while (delta < WheelUiTuning.spinCompleteMinTurns * 2 * pi) {
      delta += 2 * pi;
    }
    _spinController = controller;
    _spinWheel = wheel;
    _spinRunning = true;
    _spinTargeted = true;
    _spinLastElapsed = Duration.zero;
    _spinInitialVelocity = outcome.initialVelocity;
    _spinAngularVelocity = outcome.initialVelocity;
    _targetSpinOutcome = outcome;
    _targetSpinStart = _baseRotation;
    _targetSpinEnd = _baseRotation + delta;
    _targetSpinDurationSec = max(
      WheelUiTuning.targetSpinMinDurationSeconds,
      wheel.spinDurationMs / 1000,
    );
    _targetSpinElapsedSec = 0;
    _spinTicker.start();
    HapticFeedback.lightImpact();
  }

  void _startFreeSpin({
    required AppController controller,
    required WheelModel wheel,
    required double angularVelocity,
  }) {
    if (_spinRunning) {
      return;
    }
    final outcome = controller.beginSpin();
    if (outcome == null) {
      return;
    }
    _spinController = controller;
    _spinWheel = wheel;
    _spinRunning = true;
    _spinTargeted = false;
    _spinLastElapsed = Duration.zero;
    _spinAngularVelocity = angularVelocity.clamp(
      -WheelUiTuning.freeSpinAngularVelocityClamp,
      WheelUiTuning.freeSpinAngularVelocityClamp,
    );
    if (_spinAngularVelocity.abs() < WheelUiTuning.freeSpinAngularVelocityMin) {
      _spinAngularVelocity =
          _spinAngularVelocity.sign * WheelUiTuning.freeSpinAngularVelocityMin;
    }
    _spinInitialVelocity = _spinAngularVelocity.abs();
    _targetSpinOutcome = null;
    _spinTicker.start();
    HapticFeedback.lightImpact();
  }

  void _onSpinTick(Duration elapsed) {
    if (!_spinRunning || !mounted) {
      return;
    }
    final controller = _spinController;
    final wheel = _spinWheel;
    if (controller == null || wheel == null) {
      _stopSpinWithoutResult();
      return;
    }
    if (_spinLastElapsed == Duration.zero) {
      _spinLastElapsed = elapsed;
      return;
    }

    final dt =
        (elapsed - _spinLastElapsed).inMicroseconds /
        Duration.microsecondsPerSecond;
    _spinLastElapsed = elapsed;
    if (dt <= 0) {
      return;
    }

    if (_spinTargeted) {
      final speedScale = _edgeBrakeActive
          ? WheelUiTuning.targetSpinBrakeSpeedScale
          : 1.0;
      _targetSpinElapsedSec += dt * speedScale;
      final t = (_targetSpinElapsedSec / _targetSpinDurationSec).clamp(
        0.0,
        1.0,
      );
      final eased = Curves.easeOutCubic.transform(t);
      final nextRotation =
          _targetSpinStart + (_targetSpinEnd - _targetSpinStart) * eased;
      _spinAngularVelocity = (nextRotation - _rotation) / dt;
      _rotation = nextRotation;
      setState(() {});
      if (t >= 1.0) {
        _finalizeSpin(controller: controller, fixedOutcome: _targetSpinOutcome);
      }
      return;
    }

    final absVelocity = _spinAngularVelocity.abs();
    if (absVelocity <= 0.01) {
      _finalizeSpin(controller: controller);
      return;
    }
    final friction = _edgeBrakeActive
        ? WheelUiTuning.freeSpinBrakeFriction
        : WheelUiTuning.freeSpinBaseFriction;
    final nextAbsVelocity = max(0.0, absVelocity - friction * dt);
    final averageVelocity =
        _spinAngularVelocity.sign * ((absVelocity + nextAbsVelocity) * 0.5);
    _rotation += averageVelocity * dt;
    _spinAngularVelocity = _spinAngularVelocity.sign * nextAbsVelocity;
    setState(() {});

    if (nextAbsVelocity <= WheelUiTuning.freeSpinStopVelocity) {
      _finalizeSpin(controller: controller);
    }
  }

  void _setEdgeBrakeActive(bool active) {
    if (_edgeBrakeActive == active) {
      return;
    }
    _edgeBrakeActive = active;
    _brakeHapticTimer?.cancel();
    if (active) {
      HapticFeedback.mediumImpact();
      _brakeHapticTimer = Timer.periodic(
        Duration(milliseconds: WheelUiTuning.brakeHapticIntervalMs),
        (_) {
          if (_edgeBrakeActive) {
            HapticFeedback.selectionClick();
          }
        },
      );
    }
  }

  void _finalizeSpin({
    required AppController controller,
    SpinOutcome? fixedOutcome,
  }) {
    _spinTicker.stop();
    _spinRunning = false;
    _spinTargeted = false;
    _setEdgeBrakeActive(false);
    _spinLastElapsed = Duration.zero;
    final normalized = _normalizeRotation(_rotation);
    _rotation = normalized;
    _baseRotation = normalized;

    final currentWheel = controller.selectedWheel;
    if (currentWheel == null || currentWheel.items.isEmpty) {
      return;
    }

    final outcome =
        fixedOutcome ?? _outcomeFromRotation(currentWheel, normalized);
    controller.finishSpin(outcome);
    if (mounted) {
      _refreshFunHint(
        localeCode: Localizations.localeOf(context).languageCode,
        wheelId: currentWheel.id,
      );
    }
    HapticFeedback.selectionClick();
    setState(() {});
  }

  SpinOutcome _outcomeFromRotation(
    WheelModel wheel,
    double normalizedRotation,
  ) {
    final winnerIndex = _winnerIndexFromRotation(
      itemCount: wheel.items.length,
      rotation: normalizedRotation,
    );
    return SpinOutcome(
      winnerIndex: winnerIndex,
      winnerItemId: wheel.items[winnerIndex].id,
      targetDelta: 0,
      initialVelocity: _spinInitialVelocity,
    );
  }

  double _normalizeRotation(double value) {
    var result = value % (2 * pi);
    if (result < 0) {
      result += 2 * pi;
    }
    return result;
  }

  int _winnerIndexFromRotation({
    required int itemCount,
    required double rotation,
  }) {
    final wedge = (2 * pi) / itemCount;
    var relative = -rotation;
    while (relative < 0) {
      relative += 2 * pi;
    }
    relative %= (2 * pi);
    return (relative / wedge).floor().clamp(0, itemCount - 1);
  }

  void _stopSpinWithoutResult() {
    _spinTicker.stop();
    _spinRunning = false;
    _spinTargeted = false;
    _setEdgeBrakeActive(false);
    _spinLastElapsed = Duration.zero;
  }

  void _resetEdgePointerTracking() {
    _edgePointerId = null;
    _edgePointerOnRim = false;
    _edgeDownLocal = null;
    _edgeDownTime = null;
  }

  void _handleWheelTransformChanged() {
    if (_syncingWheelTransform || !mounted) {
      return;
    }
    final matrix = _wheelTransformController.value;
    final nextScale = matrix.getMaxScaleOnAxis().clamp(
      1.0,
      WheelUiTuning.wheelMaxScale,
    );
    final clampedMatrix = _clampWheelTranslation(
      matrix: matrix,
      scale: nextScale,
    );
    if (clampedMatrix != null) {
      _setWheelTransform(clampedMatrix);
    }
    final tx = matrix.entry(0, 3);
    final ty = matrix.entry(1, 3);
    final nearlyDefault = nextScale <= WheelUiTuning.panEnableScaleThreshold;
    final translated = tx.abs() > 0.5 || ty.abs() > 0.5;
    if (nearlyDefault && (translated || (nextScale - 1.0).abs() > 0.001)) {
      _pendingWheelDetailScale = null;
      _setWheelTransformIdentity();
      if (_wheelDetailScale != 1.0) {
        setState(() => _wheelDetailScale = 1.0);
        _cacheCurrentWheelViewportIfPossible();
      } else {
        _cacheCurrentWheelViewportIfPossible();
      }
      return;
    }
    if (!mounted) {
      return;
    }
    final quantizedScale = _quantizeDetailScale(nextScale);
    if ((quantizedScale - _wheelDetailScale).abs() <
        WheelUiTuning.detailScaleRepaintStep * 0.5) {
      _cacheCurrentWheelViewportIfPossible();
      return;
    }
    _scheduleWheelDetailScaleUpdate(quantizedScale);
  }

  void _scheduleWheelDetailScaleUpdate(double nextScale) {
    _pendingWheelDetailScale = nextScale;
    if (_wheelDetailScaleUpdateScheduled) {
      return;
    }
    _wheelDetailScaleUpdateScheduled = true;
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      _wheelDetailScaleUpdateScheduled = false;
      if (!mounted) {
        return;
      }
      final pending = _pendingWheelDetailScale;
      _pendingWheelDetailScale = null;
      if (pending == null ||
          (pending - _wheelDetailScale).abs() <
              WheelUiTuning.detailScaleRepaintStep * 0.5) {
        return;
      }
      setState(() {
        _wheelDetailScale = pending;
      });
      _cacheCurrentWheelViewportIfPossible();
    });
  }

  double _quantizeDetailScale(double rawScale) {
    final clamped = rawScale.clamp(1.0, WheelUiTuning.wheelMaxScale);
    final step = WheelUiTuning.detailScaleRepaintStep;
    final bucket = ((clamped - 1.0) / step).round();
    return (1.0 + bucket * step).clamp(1.0, WheelUiTuning.wheelMaxScale);
  }

  void _scheduleWheelViewportReset() {
    if (_viewportResetScheduled) {
      return;
    }
    _viewportResetScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewportResetScheduled = false;
      if (!mounted) {
        return;
      }
      _setWheelTransformIdentity();
    });
  }

  Matrix4? _clampWheelTranslation({
    required Matrix4 matrix,
    required double scale,
  }) {
    if (scale <= WheelUiTuning.panEnableScaleThreshold ||
        _wheelViewportSize.isEmpty ||
        _wheelBaseSize <= 0) {
      return null;
    }
    final viewport = _wheelViewportSize;
    final radius = (_wheelBaseSize * scale) / 2;
    final centerX = viewport.width / 2;
    final centerY = viewport.height / 2;
    final tx = matrix.entry(0, 3);
    final ty = matrix.entry(1, 3);

    const visibilityClamp = 0.32;
    final minVisibleX = viewport.width * visibilityClamp;
    final maxVisibleX = viewport.width * (1 - visibilityClamp);
    final minVisibleY = viewport.height * visibilityClamp;
    final maxVisibleY = viewport.height * (1 - visibilityClamp);

    final minTx = maxVisibleX - (scale * centerX) - radius;
    final maxTx = minVisibleX - (scale * centerX) + radius;
    final minTy = maxVisibleY - (scale * centerY) - radius;
    final maxTy = minVisibleY - (scale * centerY) + radius;

    var clampedTx = tx;
    var clampedTy = ty;
    if (minTx <= maxTx) {
      clampedTx = tx.clamp(minTx, maxTx).toDouble();
    }
    if (minTy <= maxTy) {
      clampedTy = ty.clamp(minTy, maxTy).toDouble();
    }
    if ((clampedTx - tx).abs() < 0.01 && (clampedTy - ty).abs() < 0.01) {
      return null;
    }
    return matrix.clone()
      ..setEntry(0, 3, clampedTx)
      ..setEntry(1, 3, clampedTy);
  }

  void _setWheelTransform(Matrix4 matrix) {
    _syncingWheelTransform = true;
    _wheelTransformController.value = matrix;
    _syncingWheelTransform = false;
  }

  bool _restoreWheelViewportIfAvailable({
    required AppController controller,
    required int wheelId,
  }) {
    final cached = controller.wheelViewportStateForWheel(wheelId);
    if (cached == null) {
      return false;
    }
    final cachedScale = cached.scale.clamp(1.0, WheelUiTuning.wheelMaxScale);
    final restoredMatrix = Matrix4.identity()
      ..setEntry(0, 0, cachedScale)
      ..setEntry(1, 1, cachedScale)
      ..setEntry(0, 3, cached.translateX)
      ..setEntry(1, 3, cached.translateY);
    _setWheelTransform(restoredMatrix);
    _wheelDetailScale = _quantizeDetailScale(cachedScale);
    _pendingWheelDetailScale = null;
    _rotation = _normalizeRotation(cached.rotation);
    _baseRotation = _rotation;
    _glowAlignmentA = Alignment(cached.glowAx, cached.glowAy);
    _glowJitterA = Offset.zero;
    _glowAlignmentB = Alignment(cached.glowBx, cached.glowBy);
    _glowJitterB = Offset.zero;
    _glowScaleA = cached.glowScaleA;
    _glowScaleB = cached.glowScaleB;
    _sliceSheenCenter = Alignment(cached.sliceSheenX, cached.sliceSheenY);
    _sliceDepthCenter = Alignment(cached.sliceDepthX, cached.sliceDepthY);
    _sliceSheenIntensity = cached.sliceSheenIntensity;
    _sliceDepthIntensity = cached.sliceDepthIntensity;
    return true;
  }

  void _cacheWheelViewportState({
    required AppController controller,
    required int wheelId,
  }) {
    final matrix = _wheelTransformController.value;
    controller.cacheWheelViewportState(
      wheelId: wheelId,
      rotation: _normalizeRotation(_rotation),
      scale: _wheelDetailScale,
      translateX: matrix.entry(0, 3),
      translateY: matrix.entry(1, 3),
      glowAx: _glowAlignmentA.x + _glowJitterA.dx,
      glowAy: _glowAlignmentA.y + _glowJitterA.dy,
      glowBx: _glowAlignmentB.x + _glowJitterB.dx,
      glowBy: _glowAlignmentB.y + _glowJitterB.dy,
      glowScaleA: _glowScaleA,
      glowScaleB: _glowScaleB,
      sliceSheenX: _sliceSheenCenter.x,
      sliceSheenY: _sliceSheenCenter.y,
      sliceDepthX: _sliceDepthCenter.x,
      sliceDepthY: _sliceDepthCenter.y,
      sliceSheenIntensity: _sliceSheenIntensity,
      sliceDepthIntensity: _sliceDepthIntensity,
    );
  }

  void _setWheelTransformIdentity() {
    _setWheelTransform(Matrix4.identity());
  }

  void _cacheCurrentWheelViewportIfPossible() {
    if (!mounted) {
      return;
    }
    final controller = context.read<AppController>();
    final wheelId = controller.selectedWheelId;
    if (wheelId == null) {
      return;
    }
    _cacheWheelViewportState(controller: controller, wheelId: wheelId);
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
            ..multiply(Matrix4.diagonal3Values(1.0, isDark ? 0.88 : 0.92, 1.0)),
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
    return LiquidGlassChrome(
      borderRadius: 999,
      accentColor: accentColor,
      isDark: isDark,
      shadowStrength: 0.52,
      highlightStrength: 0.95,
      child: GlassContainer(
        useOwnLayer: true,
        quality: GlassQuality.premium,
        shape: const LiquidRoundedSuperellipse(borderRadius: 999),
        settings: LiquidGlassSettings(
          blur: 0,
          thickness: isDark ? 10 : 9,
          glassColor: accentColor.withValues(alpha: isDark ? 0.18 : 0.14),
          lightIntensity: isDark ? 0.52 : 0.68,
          ambientStrength: isDark ? 0.03 : 0.02,
          refractiveIndex: 1.22,
          saturation: 1.0,
          chromaticAberration: 0,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 14, color: accentColor),
              const SizedBox(width: 6),
              Text(text, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiquidGlassSpinButton extends StatelessWidget {
  const _LiquidGlassSpinButton({
    required this.onPressed,
    required this.accentColor,
    required this.onAccentColor,
    required this.icon,
    required this.label,
  });

  final VoidCallback? onPressed;
  final Color accentColor;
  final Color onAccentColor;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onPressed != null;
    final glyphBase = isDark
        ? Colors.white.withValues(alpha: 0.94)
        : Colors.black.withValues(alpha: 0.86);
    final glyphColor = Color.lerp(
      glyphBase,
      onAccentColor,
      isDark ? 0.08 : 0.12,
    )!;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.52,
      child: LiquidStretch(
        interactionScale: 1.01,
        stretch: 0.5,
        resistance: 0.08,
        hitTestBehavior: HitTestBehavior.translucent,
        child: SizedBox(
          height: 58,
          child: LiquidGlassChrome(
            borderRadius: 30,
            accentColor: accentColor,
            isDark: isDark,
            shadowStrength: 1.0,
            highlightStrength: 1.0,
            child: GlassButton.custom(
              onTap: onPressed ?? () {},
              enabled: enabled,
              label: label,
              width: double.infinity,
              height: 58,
              useOwnLayer: true,
              quality: GlassQuality.premium,
              shape: const LiquidRoundedSuperellipse(borderRadius: 30),
              settings: LiquidGlassSettings(
                thickness: isDark ? 22 : 25,
                blur: 0,
                glassColor: accentColor.withValues(
                  alpha: isDark ? 0.04 : 0.045,
                ),
                lightAngle: isDark ? pi * 0.76 : pi * 0.72,
                lightIntensity: isDark ? 0.0 : 1.0,
                ambientStrength: isDark ? 0.0 : 0.03,
                refractiveIndex: 1.5,
                saturation: isDark ? 0.92 : 0.92,
                chromaticAberration: 0,
              ),
              interactionScale: 1.0,
              stretch: 0,
              resistance: 0.12,
              glowColor: accentColor.withValues(alpha: isDark ? 0.0 : 0.035),
              glowRadius: isDark ? 1.1 : 1.16,
              style: GlassButtonStyle.filled,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: glyphColor),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: glyphColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
