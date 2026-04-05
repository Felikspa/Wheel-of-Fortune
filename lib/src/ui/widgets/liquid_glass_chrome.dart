import 'package:flutter/material.dart';

class LiquidGlassChrome extends StatelessWidget {
  const LiquidGlassChrome({
    super.key,
    required this.child,
    required this.accentColor,
    required this.isDark,
    this.borderRadius = 22,
    this.shadowStrength = 1.0,
    this.highlightStrength = 1.0,
  });

  final Widget child;
  final Color accentColor;
  final bool isDark;
  final double borderRadius;
  final double shadowStrength;
  final double highlightStrength;

  @override
  Widget build(BuildContext context) {
    final shadow = shadowStrength.clamp(0.0, 1.6).toDouble();
    final highlight = highlightStrength.clamp(0.0, 1.6).toDouble();
    final radius = borderRadius.isFinite ? borderRadius : 22.0;
    final shallowSurface = radius >= 100;

    Widget content = child;
    if (highlight > 0) {
      content = CustomPaint(
        foregroundPainter: _LiquidGlassEdgeHighlightPainter(
          borderRadius: radius,
          highlightColor: Colors.white.withValues(
            alpha: (isDark ? 0.66 : 0.88) * highlight,
          ),
          tintColor: accentColor.withValues(
            alpha: (isDark ? 0.24 : 0.32) * highlight,
          ),
        ),
        child: content,
      );
    }

    if (shadow > 0) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: (isDark ? 0.22 : 0.1) * shadow,
              ),
              blurRadius: shallowSurface ? 12 : 16,
              spreadRadius: shallowSurface ? 0.12 : 0.25,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: accentColor.withValues(
                alpha: (isDark ? 0.1 : 0.1) * shadow,
              ),
              blurRadius: shallowSurface ? 14 : 20,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: content,
      );
    }

    return content;
  }
}

class _LiquidGlassEdgeHighlightPainter extends CustomPainter {
  const _LiquidGlassEdgeHighlightPainter({
    required this.borderRadius,
    required this.highlightColor,
    required this.tintColor,
  });

  final double borderRadius;
  final Color highlightColor;
  final Color tintColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final outer = RRect.fromRectAndRadius(
      rect.deflate(0.85),
      Radius.circular(borderRadius),
    );
    final inner = RRect.fromRectAndRadius(
      rect.deflate(1.8),
      Radius.circular((borderRadius - 1).clamp(0.0, borderRadius)),
    );

    final outerStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          highlightColor.withValues(alpha: highlightColor.a * 0.8),
          highlightColor.withValues(alpha: highlightColor.a * 0.28),
          tintColor.withValues(alpha: tintColor.a * 0.85),
        ],
        stops: const [0.0, 0.54, 1.0],
      ).createShader(rect);

    final innerStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          highlightColor.withValues(alpha: highlightColor.a * 0.22),
          Colors.transparent,
        ],
      ).createShader(rect);

    canvas.drawRRect(outer, outerStroke);
    canvas.drawRRect(inner, innerStroke);
  }

  @override
  bool shouldRepaint(covariant _LiquidGlassEdgeHighlightPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.tintColor != tintColor;
  }
}
