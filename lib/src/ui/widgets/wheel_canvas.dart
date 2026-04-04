import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../app_theme.dart';
import '../color_utils.dart';

final int _sessionColorSeed = DateTime.now().millisecondsSinceEpoch;

class WheelCanvas extends StatelessWidget {
  const WheelCanvas({
    super.key,
    required this.wheel,
    required this.rotation,
    required this.winnerItemId,
    required this.onTapSlice,
    required this.enabled,
  });

  final WheelModel wheel;
  final double rotation;
  final int? winnerItemId;
  final ValueChanged<int> onTapSlice;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: GestureDetector(
            onTapUp: enabled
                ? (details) {
                    final index = _hitTestIndex(
                      localPosition: details.localPosition,
                      size: size,
                      itemCount: wheel.items.length,
                    );
                    if (index != null) {
                      onTapSlice(index);
                    }
                  }
                : null,
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size.square(size),
                    painter: _WheelPainter(
                      wheel: wheel,
                      rotation: rotation,
                      winnerItemId: winnerItemId,
                      brightness: Theme.of(context).brightness,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    child: CustomPaint(
                      size: const Size(24, 28),
                      painter: _PointerPainter(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
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

  int? _hitTestIndex({
    required Offset localPosition,
    required double size,
    required int itemCount,
  }) {
    if (itemCount == 0) {
      return null;
    }
    final center = Offset(size / 2, size / 2);
    final vector = localPosition - center;
    final radius = size / 2;
    if (vector.distance > radius) {
      return null;
    }
    var angle = atan2(vector.dy, vector.dx);
    if (angle < 0) {
      angle += 2 * pi;
    }
    var relative = angle - (-pi / 2 + rotation);
    while (relative < 0) {
      relative += 2 * pi;
    }
    relative %= (2 * pi);
    final index = (relative / ((2 * pi) / itemCount)).floor();
    return index.clamp(0, itemCount - 1);
  }
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter({
    required this.wheel,
    required this.rotation,
    required this.winnerItemId,
    required this.brightness,
  });

  final WheelModel wheel;
  final double rotation;
  final int? winnerItemId;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final wheelRadius = radius * 0.88;
    final wheelRect = Rect.fromCircle(center: center, radius: wheelRadius);
    final slices = wheel.items;
    final isDark = brightness == Brightness.dark;

    _drawOuterRing(canvas, center, radius, isDark);

    if (slices.isEmpty) {
      final paint = Paint()..color = Colors.grey.withValues(alpha: 0.22);
      canvas.drawCircle(center, wheelRadius, paint);
      return;
    }

    final sliceColors = _buildSliceColors(slices, wheel.palette, isDark);
    final wedge = (2 * pi) / slices.length;

    for (var i = 0; i < slices.length; i++) {
      final item = slices[i];
      final start = (-pi / 2) + rotation + (i * wedge);
      final base = sliceColors[i];
      final paint = Paint()..color = base;
      canvas.drawArc(wheelRect, start, wedge, true, paint);

      final gloss = Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.03 : 0.08)
        ..style = PaintingStyle.fill;
      canvas.drawArc(wheelRect, start, wedge, true, gloss);

      if (winnerItemId != null && winnerItemId == item.id) {
        final highlight = Paint()
          ..color = Colors.white.withValues(alpha: isDark ? 0.14 : 0.28);
        canvas.drawArc(wheelRect, start, wedge, true, highlight);
      }

      final labelAngle = start + (wedge / 2);
      final labelOffset = Offset(
        center.dx + cos(labelAngle) * wheelRadius * 0.63,
        center.dy + sin(labelAngle) * wheelRadius * 0.63,
      );
      final text = item.title.length > 14 ? '${item.title.substring(0, 14)}…' : item.title;
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.96),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            fontSize: 12,
            shadows: [
              Shadow(
                blurRadius: 8,
                color: Colors.black.withValues(alpha: 0.45),
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: wheelRadius * 0.56);
      canvas.save();
      canvas.translate(labelOffset.dx, labelOffset.dy);
      canvas.rotate(labelAngle + pi / 2);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }

    final dividerPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.3 : 0.65)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (var i = 1; i < slices.length; i++) {
      final angle = (-pi / 2) + rotation + (i * wedge);
      final p1 = Offset(center.dx + cos(angle) * 0, center.dy + sin(angle) * 0);
      final p2 = Offset(center.dx + cos(angle) * wheelRadius, center.dy + sin(angle) * wheelRadius);
      canvas.drawLine(p1, p2, dividerPaint);
    }

    canvas.drawCircle(
      center,
      wheelRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..color = Colors.white.withValues(alpha: isDark ? 0.35 : 0.82),
    );
    _drawCenterHub(canvas, center, wheelRadius, isDark);
  }

  void _drawOuterRing(Canvas canvas, Offset center, double radius, bool isDark) {
    final ringRect = Rect.fromCircle(center: center, radius: radius * 0.94);
    final ringPaint = Paint()
      ..shader = SweepGradient(
        colors: isDark
            ? const [Color(0xFF2A2F41), Color(0xFF1A1E2B), Color(0xFF31374A), Color(0xFF2A2F41)]
            : const [Color(0xFFF8FAFF), Color(0xFFDFE7FF), Color(0xFFF4F7FF), Color(0xFFF8FAFF)],
      ).createShader(ringRect);
    canvas.drawCircle(center, radius * 0.94, ringPaint);
    canvas.drawCircle(
      center,
      radius * 0.93,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.06),
    );
  }

  void _drawCenterHub(Canvas canvas, Offset center, double wheelRadius, bool isDark) {
    final hubRadius = wheelRadius * 0.14;
    final hubRect = Rect.fromCircle(center: center, radius: hubRadius);
    final hub = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? const [Color(0xFF3B425A), Color(0xFF1D2131)]
            : const [Color(0xFFFFFFFF), Color(0xFFD7E0FF)],
      ).createShader(hubRect);
    canvas.drawCircle(center, hubRadius, hub);
    canvas.drawCircle(
      center,
      hubRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1),
    );
    canvas.drawCircle(
      center,
      hubRadius * 0.36,
      Paint()..color = isDark ? const Color(0xFF9AB4FF) : const Color(0xFF4E6BDB),
    );
  }

  List<Color> _buildSliceColors(List<WheelItemModel> items, String palette, bool isDark) {
    final fallbackPool = _buildDynamicPool(
      count: max(1, items.length),
      palette: palette,
      isDark: isDark,
      wheelId: wheel.id,
    );
    final resolved = <Color>[];
    var fallbackIndex = 0;

    for (final item in items) {
      Color current = parseHexColor(item.colorHex) ?? fallbackPool[fallbackIndex++ % fallbackPool.length];
      if (resolved.isNotEmpty) {
        current = _enforceAdjacentContrast(
          previous: resolved.last,
          candidate: current,
          isDark: isDark,
          fallbackHueSeed: (fallbackIndex * 41 + wheel.id) % 360,
        );
      }
      resolved.add(current);
    }
    return resolved;
  }

  List<Color> _buildDynamicPool({
    required int count,
    required String palette,
    required bool isDark,
    required int wheelId,
  }) {
    final paletteMap = wheelPalettes(brightness);
    final source = paletteMap[palette] ?? paletteMap['ocean']!;
    final seed = _sessionColorSeed ^ wheelId ^ palette.hashCode ^ count;
    final rng = Random(seed);
    final baseHue = _paletteBaseHue(palette);
    final colors = <Color>[];

    for (var i = 0; i < count; i++) {
      final hueJitter = (rng.nextDouble() - 0.5) * 72;
      final hue = (baseHue + (i * 137.50776405003785) + hueJitter) % 360;
      final saturation = palette == 'mono'
          ? (isDark ? 0.12 : 0.1)
          : (isDark ? 0.68 + (i.isEven ? 0.08 : -0.06) : 0.64 + (i.isEven ? 0.09 : -0.05));
      final lightness = isDark
          ? (i.isEven ? 0.52 : 0.39)
          : (i.isEven ? 0.57 : 0.45);
      var color = HSLColor.fromAHSL(1, hue, saturation.clamp(0.08, 0.95), lightness.clamp(0.18, 0.82))
          .toColor();
      color = _blendTowardSource(color, source[i % source.length], isDark);
      if (colors.isNotEmpty) {
        color = _enforceAdjacentContrast(
          previous: colors.last,
          candidate: color,
          isDark: isDark,
          fallbackHueSeed: hue,
        );
      }
      colors.add(color);
    }
    return colors;
  }

  double _paletteBaseHue(String palette) {
    return switch (palette) {
      'ocean' => 205,
      'sunset' => 24,
      'mint' => 150,
      'mono' => 220,
      _ => 200,
    };
  }

  Color _blendTowardSource(Color generated, Color source, bool isDark) {
    return Color.lerp(generated, source, isDark ? 0.28 : 0.32) ?? generated;
  }

  Color _enforceAdjacentContrast({
    required Color previous,
    required Color candidate,
    required bool isDark,
    required double fallbackHueSeed,
  }) {
    if (_contrastRatio(previous, candidate) >= 1.35) {
      return candidate;
    }

    var hsl = HSLColor.fromColor(candidate);
    for (var i = 0; i < 12; i++) {
      final sign = i.isEven ? 1 : -1;
      final hueShift = (i + 1) * 14 * sign;
      final lightShift = (i.isEven ? 0.1 : -0.1);
      final next = HSLColor.fromAHSL(
        1,
        (hsl.hue + hueShift) % 360,
        (hsl.saturation + (isDark ? 0.03 : 0.02)).clamp(0.1, 0.95),
        (hsl.lightness + lightShift).clamp(0.2, 0.82),
      ).toColor();
      if (_contrastRatio(previous, next) >= 1.35) {
        return next;
      }
    }

    final fallback = HSLColor.fromAHSL(
      1,
      (fallbackHueSeed + 160) % 360,
      isDark ? 0.8 : 0.72,
      isDark ? 0.62 : 0.35,
    ).toColor();
    return fallback;
  }

  double _contrastRatio(Color a, Color b) {
    final l1 = a.computeLuminance();
    final l2 = b.computeLuminance();
    final hi = max(l1, l2);
    final lo = min(l1, l2);
    return (hi + 0.05) / (lo + 0.05);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.wheel != wheel ||
        oldDelegate.winnerItemId != winnerItemId ||
        oldDelegate.brightness != brightness;
  }
}

class _PointerPainter extends CustomPainter {
  const _PointerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.3), 5, true);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.95), color.withValues(alpha: 0.75)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
