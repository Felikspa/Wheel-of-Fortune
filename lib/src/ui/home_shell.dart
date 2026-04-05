import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../domain/models.dart';
import '../state/app_controller.dart';
import 'draw_mode_page.dart';
import 'manage_page.dart';
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
  late final Offset _orbJitterBottomLeft;
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
    _orbJitterBottomLeft = Offset(
      (rng.nextDouble() - 0.5) * 64,
      (rng.nextDouble() - 0.5) * 64,
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        final l10n = AppLocalizations.of(context)!;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final palette = controller.selectedWheel?.palette ?? 'random';
        final orbColors = _paletteBackdropOrbColors(palette, isDark);
        final canOpenDrawer = _currentPage == 0 && !controller.busy;
        return Scaffold(
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
            accentColor: _paletteDrawerAccentColor(palette, isDark),
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
                Positioned(
                  top: -80 + _orbJitterTopRight.dy,
                  right: -40 + _orbJitterTopRight.dx,
                  child: _BackgroundOrb(size: 220, color: orbColors[0]),
                ),
                Positioned(
                  bottom: 120 + _orbJitterBottomLeft.dy,
                  left: -70 + _orbJitterBottomLeft.dx,
                  child: _BackgroundOrb(size: 250, color: orbColors[1]),
                ),
                SafeArea(
                  child: Stack(
                    children: [
                      PageView(
                        controller: _pageController,
                        physics: controller.busy
                            ? const NeverScrollableScrollPhysics()
                            : const BouncingScrollPhysics(),
                        onPageChanged: (value) =>
                            setState(() => _currentPage = value),
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
        );
      },
    );
  }

  List<Color> _paletteBackdropOrbColors(String palette, bool isDark) {
    return switch (palette) {
      'random' =>
        isDark
            ? [const Color(0x336B8BFF), const Color(0x3345D9C8)]
            : [const Color(0x557A95FF), const Color(0x5558DCCF)],
      'ocean' =>
        isDark
            ? [const Color(0x334EB7FF), const Color(0x3336D9C9)]
            : [const Color(0x5562B9FF), const Color(0x5554DACD)],
      'sunset' =>
        isDark
            ? [const Color(0x33FF915F), const Color(0x33FF4F89)]
            : [const Color(0x55FF9868), const Color(0x55FF679D)],
      'mint' =>
        isDark
            ? [const Color(0x3357E1C1), const Color(0x334EC4F2)]
            : [const Color(0x5561DEC6), const Color(0x5569CCF7)],
      'mono' =>
        isDark
            ? [const Color(0x337D879A), const Color(0x33666F80)]
            : [const Color(0x559AA3B0), const Color(0x55B3BBC8)],
      'pink' =>
        isDark
            ? [const Color(0x33FF74B5), const Color(0x339889FF)]
            : [const Color(0x55FF93C6), const Color(0x55B7A3FF)],
      _ =>
        isDark
            ? [const Color(0x336B8BFF), const Color(0x3345D9C8)]
            : [const Color(0x557A95FF), const Color(0x5558DCCF)],
    };
  }

  Color _paletteDrawerAccentColor(String palette, bool isDark) {
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
    final drawerTextColor = isDark ? Colors.white : Colors.black;
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
                            const Color(0xFF1A2233).withValues(alpha: 0.5),
                            const Color(0xFF131A28).withValues(alpha: 0.46),
                          ],
                  ),
                  border: Border.all(
                    color: primary.withValues(alpha: isDark ? 0.28 : 0.24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.36 : 0.24,
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
                            textColor: drawerTextColor,
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
                                    color: drawerTextColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${wheels.length}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: drawerTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close_rounded,
                              size: 19,
                              color: drawerTextColor,
                            ),
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
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: drawerTextColor,
                                  ),
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
                                  textColor: drawerTextColor,
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
    required this.textColor,
    required this.onChanged,
  });

  final DrawDisplayMode selectedMode;
  final String modeLabel;
  final Color accentColor;
  final bool isDark;
  final Color textColor;
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
            : const Color(0xFF141D2C).withValues(alpha: 0.42),
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
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: textColor),
            items: [
              DropdownMenuItem(
                value: DrawDisplayMode.wheel,
                child: Text(
                  '$modeLabel: ${l10n.displayModeWheel}',
                  style: TextStyle(color: textColor),
                ),
              ),
              DropdownMenuItem(
                value: DrawDisplayMode.coin,
                child: Text(
                  '$modeLabel: ${l10n.displayModeCoin}',
                  style: TextStyle(color: textColor),
                ),
              ),
              DropdownMenuItem(
                value: DrawDisplayMode.dice,
                child: Text(
                  '$modeLabel: ${l10n.displayModeDice}',
                  style: TextStyle(color: textColor),
                ),
              ),
              DropdownMenuItem(
                value: DrawDisplayMode.card,
                child: Text(
                  '$modeLabel: ${l10n.displayModeCard}',
                  style: TextStyle(color: textColor),
                ),
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
    required this.textColor,
    required this.onTap,
  });

  final WheelModel wheel;
  final bool selected;
  final Color accentColor;
  final Color textColor;
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
                            const Color(0xFF1A2231).withValues(alpha: 0.34),
                            const Color(0xFF141C2B).withValues(alpha: 0.28),
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
                    color: textColor,
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
                    color: textColor,
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
