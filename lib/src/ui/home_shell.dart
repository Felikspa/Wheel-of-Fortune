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
        return Scaffold(
          body: SafeArea(
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
        );
      },
    );
  }
}
