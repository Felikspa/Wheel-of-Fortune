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
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
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
                  top: -80,
                  right: -40,
                  child: _BackgroundOrb(
                    size: 220,
                    color: isDark ? const Color(0x333A8DFF) : const Color(0x5568A5FF),
                  ),
                ),
                Positioned(
                  bottom: 120,
                  left: -70,
                  child: _BackgroundOrb(
                    size: 250,
                    color: isDark ? const Color(0x3320C7A8) : const Color(0x5542D3C7),
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
