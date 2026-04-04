import 'package:flutter/material.dart';

class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == activeIndex ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: onSurface.withValues(alpha: index == activeIndex ? 0.42 : 0.18),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
