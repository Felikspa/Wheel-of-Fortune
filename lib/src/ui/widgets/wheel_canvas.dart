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
              child: CustomPaint(
                size: Size.square(size),
                painter: _WheelPainter(
                  wheel: wheel,
                  rotation: rotation,
                  winnerItemId: winnerItemId,
                  brightness: Theme.of(context).brightness,
                ),
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
    final hubRadius = wheelRadius * 0.14;
    final hubAccentColor = _hubAccentColor(isDark);

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
      final labelInnerRadius = wheelRadius * 0.3;
      final labelOuterRadius = wheelRadius * 0.9;
      final labelRadius = (labelInnerRadius + labelOuterRadius) / 2;
      final labelOffset = Offset(
        center.dx + cos(labelAngle) * labelRadius,
        center.dy + sin(labelAngle) * labelRadius,
      );
      final maxLabelWidth = max(32.0, labelOuterRadius - labelInnerRadius);
      final text = item.title.trim();
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
        ellipsis: '…',
      )..layout(maxWidth: maxLabelWidth);
      var textRotation = labelAngle;
      if (textRotation > pi / 2 && textRotation < 3 * pi / 2) {
        textRotation += pi;
      }
      canvas.save();
      canvas.translate(labelOffset.dx, labelOffset.dy);
      canvas.rotate(textRotation);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    final dividerPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.3 : 0.65)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < slices.length; i++) {
      final angle = (-pi / 2) + rotation + (i * wedge);
      final p1 = Offset(center.dx + cos(angle) * 0, center.dy + sin(angle) * 0);
      final p2 = Offset(
        center.dx + cos(angle) * wheelRadius,
        center.dy + sin(angle) * wheelRadius,
      );
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
    _drawCenterHub(canvas, center, wheelRadius, isDark, hubAccentColor);
    _drawMiniPointer(
      canvas: canvas,
      center: center,
      hubRadius: hubRadius,
      isDark: isDark,
      color: hubAccentColor,
    );
  }

  void _drawOuterRing(
    Canvas canvas,
    Offset center,
    double radius,
    bool isDark,
  ) {
    final ringRect = Rect.fromCircle(center: center, radius: radius * 0.94);
    final ringPaint = Paint()
      ..shader = SweepGradient(
        colors: isDark
            ? const [
                Color(0xFF2A2F41),
                Color(0xFF1A1E2B),
                Color(0xFF31374A),
                Color(0xFF2A2F41),
              ]
            : const [
                Color(0xFFF8FAFF),
                Color(0xFFDFE7FF),
                Color(0xFFF4F7FF),
                Color(0xFFF8FAFF),
              ],
      ).createShader(ringRect);
    canvas.drawCircle(center, radius * 0.94, ringPaint);
    canvas.drawCircle(
      center,
      radius * 0.93,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.06),
    );
  }

  void _drawCenterHub(
    Canvas canvas,
    Offset center,
    double wheelRadius,
    bool isDark,
    Color accentColor,
  ) {
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
        ..color = isDark
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.1),
    );
    canvas.drawCircle(center, hubRadius * 0.36, Paint()..color = accentColor);
  }

  void _drawMiniPointer({
    required Canvas canvas,
    required Offset center,
    required double hubRadius,
    required bool isDark,
    required Color color,
  }) {
    final pointerHeight = hubRadius * 0.75;
    final halfBase = hubRadius * 0.18;
    final baseY = center.dy - hubRadius * 0.25;
    final apexY = baseY - pointerHeight;
    final path = Path()
      ..moveTo(center.dx, apexY)
      ..lineTo(center.dx - halfBase, baseY)
      ..lineTo(center.dx + halfBase, baseY)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = color.withValues(alpha: isDark ? 0.94 : 0.9),
    );
  }

  Color _hubAccentColor(bool isDark) {
    return isDark ? const Color(0xFF9AB4FF) : const Color(0xFF4E6BDB);
  }

  List<Color> _buildSliceColors(
    List<WheelItemModel> items,
    String palette,
    bool isDark,
  ) {
    final fallbackPool = _buildDynamicPool(
      count: max(1, items.length),
      palette: palette,
      isDark: isDark,
      wheelId: wheel.id,
    );
    final resolved = <Color>[];
    var fallbackIndex = 0;

    for (final item in items) {
      Color current =
          parseHexColor(item.colorHex) ??
          fallbackPool[fallbackIndex++ % fallbackPool.length];
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
    final paletteMap = wheelPalettes(Brightness.light);
    final source = switch (palette) {
      'random' => <Color>[
        ...?paletteMap['ocean'],
        ...?paletteMap['sunset'],
        ...?paletteMap['mint'],
        ...?paletteMap['mono'],
      ],
      _ => paletteMap[palette] ?? paletteMap['ocean']!,
    };
    final seed = _sessionColorSeed ^ wheelId ^ palette.hashCode ^ count;
    final rng = Random(seed);
    final colors = <Color>[];

    for (var i = 0; i < count; i++) {
      final anchor = source[(i + rng.nextInt(source.length)) % source.length];
      final anchorHsl = HSLColor.fromColor(anchor);
      final hue = switch (palette) {
        'ocean' => _wrapHue(185 + rng.nextDouble() * 70 + (i * 9)),
        'mint' => _wrapHue(
          anchorHsl.hue + (rng.nextDouble() - 0.5) * 42 + (i * 13),
        ),
        'sunset' => _wrapHue(
          anchorHsl.hue + (rng.nextDouble() - 0.5) * 52 + (i * 17),
        ),
        'mono' => _wrapHue(anchorHsl.hue + (rng.nextDouble() - 0.5) * 8),
        'random' => _wrapHue(
          anchorHsl.hue + (rng.nextDouble() - 0.5) * 120 + (i * 29),
        ),
        _ => _wrapHue(anchorHsl.hue + (rng.nextDouble() - 0.5) * 64 + (i * 23)),
      };

      late final double saturation;
      late final double lightness;
      if (palette == 'mono') {
        saturation = (isDark ? 0.04 : 0.03) + rng.nextDouble() * 0.08;
        lightness = isDark
            ? 0.34 + rng.nextDouble() * 0.42
            : 0.42 + rng.nextDouble() * 0.38;
      } else if (palette == 'ocean') {
        saturation =
            (isDark ? 0.82 : 0.76) +
            (rng.nextDouble() - 0.5) * (isDark ? 0.18 : 0.16) +
            (i.isEven ? 0.06 : -0.02);
        lightness =
            (isDark ? 0.5 : 0.44) +
            rng.nextDouble() * 0.24 +
            (i % 3 == 0 ? 0.04 : -0.01);
      } else {
        saturation =
            (isDark ? 0.78 : 0.72) +
            (rng.nextDouble() - 0.5) * (isDark ? 0.22 : 0.2) +
            (i.isEven ? 0.08 : -0.04);
        lightness =
            (isDark ? 0.46 : 0.4) +
            rng.nextDouble() * (isDark ? 0.26 : 0.26) +
            (i % 3 == 0 ? 0.04 : -0.02);
      }
      final sat = saturation.clamp(0.0, 0.98);
      final lit = lightness.clamp(0.16, 0.9);

      var color = HSLColor.fromAHSL(1, hue, sat, lit).toColor();
      if (palette != 'mono') {
        color = Color.lerp(color, anchor, 0.18) ?? color;
      }
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

  double _wrapHue(double hue) {
    final wrapped = hue % 360;
    return wrapped < 0 ? wrapped + 360 : wrapped;
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.wheel != wheel ||
        oldDelegate.winnerItemId != winnerItemId ||
        oldDelegate.brightness != brightness;
  }
}
