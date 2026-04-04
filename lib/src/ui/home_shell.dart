import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import 'manage_page.dart';
import 'wheel_page.dart';
import 'widgets/page_dots.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final palette = controller.selectedWheel?.palette ?? 'random';
        final orbColors = _paletteBackdropOrbColors(palette, isDark);
        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [Color(0xFF080A12), Color(0xFF0D1020), Color(0xFF0B0C10)]
                    : const [Color(0xFFF9FBFF), Color(0xFFF2F5FF), Color(0xFFEFF2F8)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -80 + _orbJitterTopRight.dy,
                  right: -40 + _orbJitterTopRight.dx,
                  child: _BackgroundOrb(
                    size: 220,
                    color: orbColors[0],
                  ),
                ),
                Positioned(
                  bottom: 120 + _orbJitterBottomLeft.dy,
                  left: -70 + _orbJitterBottomLeft.dx,
                  child: _BackgroundOrb(
                    size: 250,
                    color: orbColors[1],
                  ),
                ),
                SafeArea(
                  child: Stack(
                    children: [
                      PageView(
                        controller: _pageController,
                        physics: controller.spinning
                            ? const NeverScrollableScrollPhysics()
                            : const BouncingScrollPhysics(),
                        onPageChanged: (value) => setState(() => _currentPage = value),
                        children: [
                          WheelPage(onOpenManage: _goToManagePage),
                          const ManagePage(),
                        ],
                      ),
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: IgnorePointer(
                            child: PageDots(count: 2, activeIndex: _currentPage),
                          ),
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
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
