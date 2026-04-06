import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../domain/models.dart';
import '../state/app_controller.dart';
import 'palette_tokens.dart';
import 'draw_mode_page.dart';
import 'manage_page.dart';
import 'wheel_ui_tuning.dart';
import 'widgets/wheel_canvas.dart';
import 'widgets/page_dots.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final PageController _pageController;
  late final Offset _orbJitterTopRight;
  DateTime? _lastBackPressAt;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    final rng = Random(DateTime.now().microsecondsSinceEpoch);
    _orbJitterTopRight = Offset(
      (rng.nextDouble() - 0.5) * 56,
      (rng.nextDouble() - 0.5) * 56,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToManagePage() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _openDrawer() {
    final scaffoldState = _scaffoldKey.currentState;
    if (scaffoldState == null || scaffoldState.isDrawerOpen) {
      return;
    }
    scaffoldState.openDrawer();
  }

  Future<bool> _handleWillPop() async {
    final scaffoldState = _scaffoldKey.currentState;
    if (scaffoldState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
      return false;
    }

    final now = DateTime.now();
    final last = _lastBackPressAt;
    if (last == null ||
        now.difference(last) > const Duration(milliseconds: 1500)) {
      _lastBackPressAt = now;
      if (mounted) {
        final locale = Localizations.localeOf(context).languageCode;
        final message = locale.startsWith('zh')
            ? '再按一次返回键退出应用'
            : 'Press back again to exit';
        final messenger = ScaffoldMessenger.of(context);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(milliseconds: 1200),
            ),
          );
      }
      return false;
    }
    return true;
  }

  Future<void> _handleBackNavigationRequest() async {
    final shouldPop = await _handleWillPop();
    if (!shouldPop || !mounted) {
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        final l10n = AppLocalizations.of(context)!;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final selectedWheel = controller.selectedWheel;
        final globalBackgroundPath =
            controller.settings.globalBackgroundImagePath;
        final hasBackgroundImage =
            controller.settings.globalBackgroundImageEnabled &&
            globalBackgroundPath?.isNotEmpty == true;
        final palette = selectedWheel?.palette ?? 'random';
        final wheelViewport =
            controller.wheelViewportStateForWheel(controller.selectedWheelId) ??
            const WheelViewportState(
              rotation: 0,
              scale: 1.0,
              translateX: 0,
              translateY: 0,
              glowAx: -0.58,
              glowAy: -0.56,
              glowBx: 0.48,
              glowBy: 0.54,
              glowScaleA: 0.86,
              glowScaleB: 0.94,
              sliceSheenX: -0.16,
              sliceSheenY: -0.12,
              sliceDepthX: 0.2,
              sliceDepthY: 0.16,
              sliceSheenIntensity: 1.0,
              sliceDepthIntensity: 1.0,
            );
        final orbColors = paletteBackdropOrbColors(palette, isDark);
        final canOpenDrawer = _currentPage == 0 && !controller.busy;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              return;
            }
            unawaited(_handleBackNavigationRequest());
          },
          child: Scaffold(
            key: _scaffoldKey,
            drawerEnableOpenDragGesture: canOpenDrawer,
            drawerEdgeDragWidth: canOpenDrawer ? 84 : null,
            drawerScrimColor: Colors.black.withValues(
              alpha: isDark ? 0.22 : 0.12,
            ),
            drawer: _WheelDrawer(
              wheels: controller.wheels,
              selectedWheelId: controller.selectedWheelId,
              selectedMode: controller.selectedDisplayMode,
              accentColor: paletteAccentColor(palette, isDark),
              title: l10n.wheels,
              modeLabel: l10n.drawMode,
              emptyLabel: l10n.noWheelsYet,
              onSelectWheel: (wheelId) {
                controller.selectWheel(wheelId);
              },
              onSelectMode: (mode) => controller.setSelectedDisplayMode(mode),
            ),
            body: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? const [
                          Color(0xFF080A12),
                          Color(0xFF0D1020),
                          Color(0xFF0B0C10),
                        ]
                      : const [
                          Color(0xFFF9FBFF),
                          Color(0xFFF2F5FF),
                          Color(0xFFEFF2F8),
                        ],
                ),
              ),
              child: Stack(
                children: [
                  if (!hasBackgroundImage)
                    Positioned.fill(
                      child: ValueListenableBuilder<int>(
                        valueListenable: controller.wheelViewportRevision,
                        builder: (context, _, _) {
                          final syncEnabled =
                              _currentPage == 0 &&
                              controller.selectedDisplayMode ==
                                  DrawDisplayMode.wheel;
                          final liveViewport = controller
                              .wheelViewportStateForWheel(
                                controller.selectedWheelId,
                              );
                          return _BackgroundOrbLayer(
                            topRightJitter: _orbJitterTopRight,
                            orbColors: orbColors,
                            viewportState: syncEnabled ? liveViewport : null,
                          );
                        },
                      ),
                    ),
                  if (hasBackgroundImage && globalBackgroundPath != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: controller
                              .settings
                              .globalBackgroundImageOpacity
                              .clamp(0.0, 1.0),
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: controller
                                  .settings
                                  .globalBackgroundImageBlurSigma,
                              sigmaY: controller
                                  .settings
                                  .globalBackgroundImageBlurSigma,
                            ),
                            child: Image.file(
                              File(globalBackgroundPath),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  SafeArea(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: IgnorePointer(
                            child: ValueListenableBuilder<int>(
                              valueListenable: controller.wheelViewportRevision,
                              builder: (context, _, _) {
                                final liveViewport =
                                    controller.wheelViewportStateForWheel(
                                      controller.selectedWheelId,
                                    ) ??
                                    wheelViewport;
                                return AnimatedBuilder(
                                  animation: _pageController,
                                  builder: (context, _) {
                                    final pagePosition =
                                        _pageController.hasClients
                                        ? (_pageController.page ??
                                              _currentPage.toDouble())
                                        : _currentPage.toDouble();
                                    return _WheelCarryoverLayer(
                                      wheel:
                                          controller.selectedDisplayMode ==
                                              DrawDisplayMode.wheel
                                          ? controller.selectedWheel
                                          : null,
                                      winnerItemId: controller.winnerItemId,
                                      viewportState: liveViewport,
                                      palette: palette,
                                      isDark: isDark,
                                      pagePosition: pagePosition,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        PageView(
                          controller: _pageController,
                          physics: controller.busy
                              ? const NeverScrollableScrollPhysics()
                              : const BouncingScrollPhysics(),
                          onPageChanged: (value) => setState(() {
                            _currentPage = value;
                          }),
                          children: [
                            DrawModePage(onOpenManage: _goToManagePage),
                            const ManagePage(),
                          ],
                        ),
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: IgnorePointer(
                              child: PageDots(
                                count: 2,
                                activeIndex: _currentPage,
                              ),
                            ),
                          ),
                        ),
                        if (canOpenDrawer)
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: 28,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onHorizontalDragUpdate: (details) {
                                final delta = details.primaryDelta ?? 0;
                                if (delta > 7) {
                                  _openDrawer();
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WheelDrawer extends StatelessWidget {
  const _WheelDrawer({
    required this.wheels,
    required this.selectedWheelId,
    required this.selectedMode,
    required this.accentColor,
    required this.title,
    required this.modeLabel,
    required this.emptyLabel,
    required this.onSelectWheel,
    required this.onSelectMode,
  });

  final List<WheelModel> wheels;
  final int? selectedWheelId;
  final DrawDisplayMode selectedMode;
  final Color accentColor;
  final String title;
  final String modeLabel;
  final String emptyLabel;
  final ValueChanged<int> onSelectWheel;
  final Future<void> Function(DrawDisplayMode mode) onSelectMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = accentColor;
    final width = min(MediaQuery.of(context).size.width * 0.84, 330.0);
    return Drawer(
      width: width,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 20, 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF111622).withValues(alpha: 0.62),
                            const Color(0xFF0A0F19).withValues(alpha: 0.58),
                          ]
                        : [
                            const Color(0xFFF8FBFF).withValues(alpha: 0.84),
                            const Color(0xFFEFF4FF).withValues(alpha: 0.8),
                          ],
                  ),
                  border: Border.all(
                    color: primary.withValues(alpha: isDark ? 0.28 : 0.18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.36 : 0.14,
                      ),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
                      child: Row(
                        children: [
                          _ModeDropdown(
                            selectedMode: selectedMode,
                            modeLabel: modeLabel,
                            accentColor: primary,
                            isDark: isDark,
                            onChanged: (mode) async {
                              await onSelectMode(mode);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${wheels.length}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded, size: 19),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: wheels.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  emptyLabel,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                12,
                                12,
                                14,
                              ),
                              itemCount: wheels.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final wheel = wheels[index];
                                final selected = wheel.id == selectedWheelId;
                                return _WheelDrawerTile(
                                  wheel: wheel,
                                  selected: selected,
                                  accentColor: primary,
                                  onTap: () {
                                    onSelectWheel(wheel.id);
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeDropdown extends StatelessWidget {
  const _ModeDropdown({
    required this.selectedMode,
    required this.modeLabel,
    required this.accentColor,
    required this.isDark,
    required this.onChanged,
  });

  final DrawDisplayMode selectedMode;
  final String modeLabel;
  final Color accentColor;
  final bool isDark;
  final Future<void> Function(DrawDisplayMode mode) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: isDark
            ? const Color(0xFF0E1420).withValues(alpha: 0.54)
            : const Color(0xFFF2F7FF).withValues(alpha: 0.72),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.34 : 0.28),
        ),
      ),
      child: Theme(
        data: theme.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<DrawDisplayMode>(
            value: selectedMode,
            focusColor: Colors.transparent,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: accentColor,
              size: 18,
            ),
            style: Theme.of(context).textTheme.labelMedium,
            items: [
              DropdownMenuItem(
                value: DrawDisplayMode.wheel,
                child: Text('$modeLabel: ${l10n.displayModeWheel}'),
              ),
              DropdownMenuItem(
                value: DrawDisplayMode.coin,
                child: Text('$modeLabel: ${l10n.displayModeCoin}'),
              ),
              DropdownMenuItem(
                value: DrawDisplayMode.dice,
                child: Text('$modeLabel: ${l10n.displayModeDice}'),
              ),
              DropdownMenuItem(
                value: DrawDisplayMode.card,
                child: Text('$modeLabel: ${l10n.displayModeCard}'),
              ),
            ],
            onChanged: (value) {
              if (value == null || value == selectedMode) {
                return;
              }
              unawaited(onChanged(value));
            },
          ),
        ),
      ),
    );
  }
}

class _WheelDrawerTile extends StatelessWidget {
  const _WheelDrawerTile({
    required this.wheel,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final WheelModel wheel;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = accentColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 190),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primary.withValues(alpha: isDark ? 0.24 : 0.2),
                      primary.withValues(alpha: isDark ? 0.16 : 0.14),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF131B29).withValues(alpha: 0.48),
                            const Color(0xFF0F1622).withValues(alpha: 0.42),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.56),
                            const Color(0xFFEFF4FF).withValues(alpha: 0.48),
                          ],
                  ),
            border: Border.all(
              color: selected
                  ? primary.withValues(alpha: isDark ? 0.4 : 0.32)
                  : (theme.dividerTheme.color ?? Colors.transparent).withValues(
                      alpha: isDark ? 0.92 : 1,
                    ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? primary.withValues(alpha: isDark ? 0.32 : 0.24)
                      : theme.colorScheme.surface.withValues(
                          alpha: isDark ? 0.4 : 0.72,
                        ),
                ),
                child: Text(
                  '${wheel.items.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  wheel.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: selected ? 20 : 18,
                color: selected
                    ? primary
                    : theme.iconTheme.color?.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelCarryoverLayer extends StatelessWidget {
  const _WheelCarryoverLayer({
    required this.wheel,
    required this.winnerItemId,
    required this.viewportState,
    required this.palette,
    required this.isDark,
    required this.pagePosition,
  });

  final WheelModel? wheel;
  final int? winnerItemId;
  final WheelViewportState? viewportState;
  final String palette;
  final bool isDark;
  final double pagePosition;

  @override
  Widget build(BuildContext context) {
    final currentWheel = wheel;
    final viewport = viewportState;
    if (currentWheel == null || viewport == null) {
      return const SizedBox.shrink();
    }
    final carryProgress = pagePosition.clamp(-0.35, 1.0);
    final scale = viewport.scale.clamp(1.0, WheelUiTuning.wheelMaxScale);
    final glowColors = paletteGlowColors(palette, isDark);
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth;
        final translatedWheel = Transform.translate(
          offset: Offset(-pageWidth * carryProgress, 0),
          child: Padding(
            padding: WheelUiTuning.pagePadding,
            child: LayoutBuilder(
              builder: (context, innerConstraints) {
                final wheelSize =
                    innerConstraints.maxWidth *
                    WheelUiTuning.wheelSizeByWidthFactor;
                return Transform.translate(
                  offset: Offset(viewport.translateX, viewport.translateY),
                  child: Transform.scale(
                    alignment: Alignment.topLeft,
                    scale: scale,
                    child: SizedBox.expand(
                      child: Align(
                        alignment: const Alignment(
                          0,
                          WheelUiTuning.wheelVerticalAlignmentY,
                        ),
                        child: SizedBox(
                          width: wheelSize,
                          height: wheelSize,
                          child: ClipOval(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned.fill(
                                  child: _CarryoverGlowSource(
                                    size: wheelSize,
                                    alignment: Alignment(
                                      viewport.glowAx,
                                      viewport.glowAy,
                                    ),
                                    color: glowColors[0],
                                    radiusFactor: viewport.glowScaleA,
                                    isDark: isDark,
                                    tilt: -0.28,
                                  ),
                                ),
                                Positioned.fill(
                                  child: _CarryoverGlowSource(
                                    size: wheelSize,
                                    alignment: Alignment(
                                      viewport.glowBx,
                                      viewport.glowBy,
                                    ),
                                    color: glowColors[1],
                                    radiusFactor: viewport.glowScaleB,
                                    isDark: isDark,
                                    tilt: 0.42,
                                  ),
                                ),
                                WheelCanvas(
                                  wheel: currentWheel,
                                  rotation: viewport.rotation,
                                  winnerItemId: winnerItemId,
                                  onTapSlice: (_) {},
                                  enabled: false,
                                  detailScale: scale,
                                  materialSheenCenter: Alignment(
                                    viewport.sliceSheenX,
                                    viewport.sliceSheenY,
                                  ),
                                  materialDepthCenter: Alignment(
                                    viewport.sliceDepthX,
                                    viewport.sliceDepthY,
                                  ),
                                  materialSheenIntensity:
                                      viewport.sliceSheenIntensity,
                                  materialDepthIntensity:
                                      viewport.sliceDepthIntensity,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
        return RepaintBoundary(child: translatedWheel);
      },
    );
  }
}

class _CarryoverGlowSource extends StatelessWidget {
  const _CarryoverGlowSource({
    required this.size,
    required this.alignment,
    required this.color,
    required this.radiusFactor,
    required this.isDark,
    required this.tilt,
  });

  final double size;
  final Alignment alignment;
  final Color color;
  final double radiusFactor;
  final bool isDark;
  final double tilt;

  @override
  Widget build(BuildContext context) {
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
                width: size * radiusFactor * 1.02,
                height: size * radiusFactor * 1.02,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: isDark ? 0.24 : 0.12),
                      color.withValues(alpha: isDark ? 0.08 : 0.04),
                      color.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.52, 1.0],
                  ),
                ),
              ),
              Container(
                width: size * radiusFactor * 0.72,
                height: size * radiusFactor * 0.72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: isDark ? 0.44 : 0.24),
                      color.withValues(alpha: isDark ? 0.16 : 0.08),
                      color.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundOrbLayer extends StatelessWidget {
  const _BackgroundOrbLayer({
    required this.topRightJitter,
    required this.orbColors,
    required this.viewportState,
  });

  final Offset topRightJitter;
  final List<Color> orbColors;
  final WheelViewportState? viewportState;

  @override
  Widget build(BuildContext context) {
    final viewport = viewportState;
    final scale = (viewport?.scale ?? 1.0).clamp(
      1.0,
      WheelUiTuning.wheelMaxScale,
    );
    final translateX = viewport?.translateX ?? 0;
    final translateY = viewport?.translateY ?? 0;
    return IgnorePointer(
      child: Transform.translate(
        offset: Offset(translateX, translateY),
        child: Transform.scale(
          alignment: Alignment.center,
          scale: scale,
          child: Stack(
            children: [
              Positioned(
                top: -80 + topRightJitter.dy,
                right: -40 + topRightJitter.dx,
                child: _BackgroundOrb(size: 200, color: orbColors[0]),
              ),
              Positioned(
                bottom: -96 + topRightJitter.dy * 0.35,
                left: -72 - topRightJitter.dx * 0.25,
                child: _BackgroundOrb(size: 236, color: orbColors[1]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
