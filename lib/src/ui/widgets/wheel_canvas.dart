import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../app_theme.dart';
import '../color_utils.dart';
import '../wheel_ui_tuning.dart';

final int _sessionColorSeed = DateTime.now().millisecondsSinceEpoch;

class WheelCanvas extends StatelessWidget {
  const WheelCanvas({
    super.key,
    required this.wheel,
    required this.rotation,
    required this.winnerItemId,
    required this.onTapSlice,
    required this.enabled,
    required this.detailScale,
    required this.materialSheenCenter,
    required this.materialDepthCenter,
    required this.materialSheenIntensity,
    required this.materialDepthIntensity,
  });

  final WheelModel wheel;
  final double rotation;
  final int? winnerItemId;
  final ValueChanged<int> onTapSlice;
  final bool enabled;
  final double detailScale;
  final Alignment materialSheenCenter;
  final Alignment materialDepthCenter;
  final double materialSheenIntensity;
  final double materialDepthIntensity;

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
                  detailScale: detailScale,
                  materialSheenCenter: materialSheenCenter,
                  materialDepthCenter: materialDepthCenter,
                  materialSheenIntensity: materialSheenIntensity,
                  materialDepthIntensity: materialDepthIntensity,
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
    required this.detailScale,
    required this.materialSheenCenter,
    required this.materialDepthCenter,
    required this.materialSheenIntensity,
    required this.materialDepthIntensity,
  });

  final WheelModel wheel;
  final double rotation;
  final int? winnerItemId;
  final Brightness brightness;
  final double detailScale;
  final Alignment materialSheenCenter;
  final Alignment materialDepthCenter;
  final double materialSheenIntensity;
  final double materialDepthIntensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final wheelRadius = radius * WheelUiTuning.paintedWheelRadiusFactor;
    final wheelRect = Rect.fromCircle(center: center, radius: wheelRadius);
    final slices = wheel.items;
    final isDark = brightness == Brightness.dark;
    final zoom = detailScale.clamp(1.0, 3.2);
    final hubRadius = wheelRadius * 0.14;
    final hubAccentColor = _paletteAccentColor(wheel.palette, isDark);

    _drawOuterRing(
      canvas,
      center,
      radius,
      isDark,
      wheel.palette,
      hubAccentColor,
    );

    if (slices.isEmpty) {
      final paint = Paint()..color = Colors.grey.withValues(alpha: 0.22);
      canvas.drawCircle(center, wheelRadius, paint);
      return;
    }

    final sliceColors = _buildSliceColors(slices, wheel.palette, isDark);
    final wedge = (2 * pi) / slices.length;
    final labelPolicy = _buildLabelPolicy(
      itemCount: slices.length,
      wheelRadius: wheelRadius,
      wedge: wedge,
      zoom: zoom,
    );
    final clampedSheenIntensity = materialSheenIntensity.clamp(0.6, 1.3);
    final clampedDepthIntensity = materialDepthIntensity.clamp(0.6, 1.2);
    final materialSheenPaint = Paint()
      ..shader = RadialGradient(
        center: materialSheenCenter,
        radius: 0.86,
        colors: [
          Colors.white.withValues(
            alpha: (isDark ? 0.08 : 0.16) * clampedSheenIntensity,
          ),
          Colors.white.withValues(
            alpha: (isDark ? 0.02 : 0.06) * clampedSheenIntensity,
          ),
          Colors.transparent,
        ],
        stops: const [0.0, 0.34, 1.0],
      ).createShader(wheelRect);
    final depthPaint = Paint()
      ..shader = RadialGradient(
        center: materialDepthCenter,
        radius: 0.98,
        colors: [
          Colors.transparent,
          Colors.black.withValues(
            alpha: (isDark ? 0.04 : 0.028) * clampedDepthIntensity,
          ),
        ],
        stops: const [0.62, 1.0],
      ).createShader(wheelRect);
    final liquidFlowPaint = Paint()
      ..blendMode = BlendMode.softLight
      ..shader = LinearGradient(
        begin: Alignment(
          materialSheenCenter.x * 0.95,
          materialSheenCenter.y * 0.95,
        ),
        end: Alignment(
          -materialSheenCenter.x * 0.75,
          -materialSheenCenter.y * 0.75,
        ),
        colors: [
          Colors.white.withValues(
            alpha: (isDark ? 0.08 : 0.12) * clampedSheenIntensity,
          ),
          Colors.white.withValues(
            alpha: (isDark ? 0.018 : 0.035) * clampedSheenIntensity,
          ),
          Colors.transparent,
        ],
        stops: const [0.0, 0.38, 1.0],
      ).createShader(wheelRect);

    for (var i = 0; i < slices.length; i++) {
      final item = slices[i];
      final start = (-pi / 2) + rotation + (i * wedge);
      final base = sliceColors[i];
      final paint = Paint()
        ..color = base.withValues(alpha: isDark ? 0.72 : 0.66);
      canvas.drawArc(wheelRect, start, wedge, true, paint);
      canvas.drawArc(wheelRect, start, wedge, true, materialSheenPaint);
      canvas.drawArc(wheelRect, start, wedge, true, depthPaint);
      canvas.drawArc(wheelRect, start, wedge, true, liquidFlowPaint);

      final gloss = Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.015 : 0.04)
        ..style = PaintingStyle.fill;
      canvas.drawArc(wheelRect, start, wedge, true, gloss);

      if (winnerItemId != null && winnerItemId == item.id) {
        final highlight = Paint()
          ..color = Colors.white.withValues(alpha: isDark ? 0.14 : 0.28);
        canvas.drawArc(wheelRect, start, wedge, true, highlight);
      }

      if (labelPolicy.show) {
        final labelAngle = start + (wedge / 2);
        final labelOffset = Offset(
          center.dx + cos(labelAngle) * labelPolicy.radius,
          center.dy + sin(labelAngle) * labelPolicy.radius,
        );
        final text = _fitTitleForPolicy(
          item.title.trim(),
          maxChars: labelPolicy.maxChars,
          singleCharOnly: labelPolicy.singleCharOnly,
        );
        if (text.isNotEmpty) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.96),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                fontSize: labelPolicy.fontSize,
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
            maxLines: labelPolicy.maxLines,
            ellipsis: labelPolicy.showEllipsis ? '…' : null,
          )..layout(maxWidth: labelPolicy.maxWidth);
          final textRotation = labelAngle;
          canvas.save();
          canvas.translate(labelOffset.dx, labelOffset.dy);
          canvas.rotate(textRotation);
          textPainter.paint(
            canvas,
            Offset(-textPainter.width / 2, -textPainter.height / 2),
          );
          canvas.restore();
        }
      }
    }

    final dividerPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.24 : 0.56)
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

    _drawCenterHub(canvas, center, wheelRadius, isDark, hubAccentColor);
    _drawMiniPointer(
      canvas: canvas,
      center: center,
      hubRadius: hubRadius,
      isDark: isDark,
      color: hubAccentColor,
    );
  }

  _LabelPolicy _buildLabelPolicy({
    required int itemCount,
    required double wheelRadius,
    required double wedge,
    required double zoom,
  }) {
    final density =
        ((itemCount - WheelUiTuning.densityBaseCount) /
                WheelUiTuning.densitySpanCount)
            .clamp(0.0, 1.0);
    final baseFontSize =
        (WheelUiTuning.baseFontStart -
                (density * WheelUiTuning.baseFontDensityDrop))
            .clamp(WheelUiTuning.baseFontMin, WheelUiTuning.baseFontMax);
    final zoomFontGain =
        (WheelUiTuning.zoomFontGainStart -
                (density * WheelUiTuning.zoomFontGainDensityDrop))
            .clamp(
              WheelUiTuning.zoomFontGainMin,
              WheelUiTuning.zoomFontGainMax,
            );
    final maxFontSize = max(
      baseFontSize + WheelUiTuning.maxFontBaseExtra,
      (WheelUiTuning.maxFontStart -
              (density * WheelUiTuning.maxFontDensityDrop))
          .clamp(WheelUiTuning.maxFontClampMin, WheelUiTuning.maxFontClampMax),
    );
    final fontSize = (baseFontSize + (zoom - 1) * zoomFontGain).clamp(
      baseFontSize,
      maxFontSize,
    );

    final outerTextRadius = wheelRadius * 0.88;
    final arcCapacity = wedge * outerTextRadius;
    // Keep baseline visibility at 1x; zoom only expands readability.
    final arcZoomGain =
        (WheelUiTuning.arcZoomGainStart +
                (zoom - 1) * WheelUiTuning.arcZoomGainPerZoom)
            .clamp(
              WheelUiTuning.arcZoomGainStart,
              WheelUiTuning.arcZoomGainMax,
            );
    final effectiveArc = arcCapacity * arcZoomGain;
    final minArcFactor = itemCount <= WheelUiTuning.lowItemCountThreshold
        ? (WheelUiTuning.minArcFactorLowBase +
              density * WheelUiTuning.minArcFactorLowDensity)
        : (WheelUiTuning.minArcFactorHighBase +
              density * WheelUiTuning.minArcFactorHighDensity);
    final minOneCharArc = fontSize * minArcFactor;
    if (effectiveArc < minOneCharArc) {
      return const _LabelPolicy.hidden();
    }

    final strictSingleChar =
        itemCount >= WheelUiTuning.strictSingleCharMinItems &&
        effectiveArc <
            fontSize *
                (WheelUiTuning.strictSingleCharBase +
                    density * WheelUiTuning.strictSingleCharDensity);
    final relaxedCharsCap = max(
      WheelUiTuning.minRelaxedChars,
      (effectiveArc / (fontSize * WheelUiTuning.relaxedCharsWidthFactor))
          .floor(),
    );
    final maxChars = strictSingleChar ? 1 : relaxedCharsCap;
    final singleCharOnly = strictSingleChar;

    var radiusFactor =
        (WheelUiTuning.labelRadiusBase +
                density * WheelUiTuning.labelRadiusDensityGain +
                (zoom - 1) * WheelUiTuning.labelRadiusZoomGain)
            .clamp(WheelUiTuning.labelRadiusMin, WheelUiTuning.labelRadiusMax);
    if (singleCharOnly) {
      radiusFactor = (radiusFactor + WheelUiTuning.labelRadiusSingleCharBoost)
          .clamp(
            WheelUiTuning.labelRadiusMin,
            WheelUiTuning.labelRadiusSingleCharMax,
          );
    }
    final radius = wheelRadius * radiusFactor;

    final innerBoundary =
        wheelRadius *
        (WheelUiTuning.innerBoundaryBase +
            density * WheelUiTuning.innerBoundaryDensityGain);
    final outerBoundary = wheelRadius * WheelUiTuning.outerBoundaryFactor;
    final radialWidth = (outerBoundary - innerBoundary).clamp(
      WheelUiTuning.radialWidthMin,
      wheelRadius,
    );
    final lowZoomWidthBoost =
        (WheelUiTuning.lowZoomWidthBoostStart -
                (zoom - 1) * WheelUiTuning.lowZoomWidthBoostPerZoom)
            .clamp(
              WheelUiTuning.lowZoomWidthBoostMin,
              WheelUiTuning.lowZoomWidthBoostStart,
            );
    final arcWidthCap =
        (effectiveArc * WheelUiTuning.arcWidthCapFactor * lowZoomWidthBoost)
            .clamp(
              fontSize * WheelUiTuning.arcWidthCapMinFontFactor,
              wheelRadius * WheelUiTuning.arcWidthCapMaxWheelFactor,
            );
    final maxWidth = singleCharOnly
        ? fontSize * WheelUiTuning.singleCharWidthFactor
        : min(arcWidthCap, radialWidth * 2);
    const maxLines = 1;
    const showEllipsis = false;

    return _LabelPolicy(
      show: true,
      singleCharOnly: singleCharOnly,
      maxChars: maxChars,
      radius: radius,
      maxWidth: maxWidth,
      fontSize: fontSize,
      maxLines: maxLines,
      showEllipsis: showEllipsis,
    );
  }

  String _fitTitleForPolicy(
    String rawTitle, {
    required int maxChars,
    required bool singleCharOnly,
  }) {
    if (rawTitle.isEmpty || maxChars <= 0) {
      return '';
    }
    final runes = rawTitle.runes.toList();
    if (runes.isEmpty) {
      return '';
    }
    if (singleCharOnly) {
      return String.fromCharCode(runes.first);
    }
    if (runes.length <= maxChars + WheelUiTuning.preTrimExtraChars) {
      return rawTitle;
    }
    return String.fromCharCodes(
      runes.take(maxChars + WheelUiTuning.preTrimExtraChars),
    );
  }

  void _drawOuterRing(
    Canvas canvas,
    Offset center,
    double radius,
    bool isDark,
    String palette,
    Color accentColor,
  ) {
    final ringRect = Rect.fromCircle(center: center, radius: radius * 0.94);
    final ringColors = _ringColorsForPalette(
      palette: palette,
      isDark: isDark,
      accentColor: accentColor,
    );
    final ringPaint = Paint()
      ..shader = SweepGradient(colors: ringColors).createShader(ringRect);
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
            ? [
                Color.lerp(accentColor, Colors.white, 0.28)!,
                Color.lerp(accentColor, Colors.black, 0.58)!,
              ]
            : [Colors.white, Color.lerp(accentColor, Colors.white, 0.72)!],
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

  List<Color> _ringColorsForPalette({
    required String palette,
    required bool isDark,
    required Color accentColor,
  }) {
    if (palette == 'random') {
      return isDark
          ? const [
              Color(0xFF2A2142),
              Color(0xFF1B2D43),
              Color(0xFF31253C),
              Color(0xFF2A2142),
            ]
          : const [
              Color(0xFFFFF7FC),
              Color(0xFFEFF3FF),
              Color(0xFFF7F2FF),
              Color(0xFFFFF7FC),
            ];
    }
    final c1 = Color.lerp(
      accentColor,
      isDark ? Colors.black : Colors.white,
      isDark ? 0.72 : 0.86,
    )!;
    final c2 = Color.lerp(
      accentColor,
      isDark ? Colors.black : Colors.white,
      isDark ? 0.82 : 0.93,
    )!;
    final c3 = Color.lerp(
      accentColor,
      isDark ? Colors.white : Colors.black,
      isDark ? 0.12 : 0.04,
    )!;
    return [c1, c2, c3, c1];
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
          minHue: palette == 'pink' ? 282 : null,
          maxHue: palette == 'pink' ? 344 : null,
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
        ...?paletteMap['pink'],
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
        'pink' => _pinkHue(i, rng),
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
      } else if (palette == 'pink') {
        saturation =
            (isDark ? 0.84 : 0.78) +
            (rng.nextDouble() - 0.5) * (isDark ? 0.18 : 0.16) +
            (i.isEven ? 0.05 : -0.03);
        lightness =
            (isDark ? 0.53 : 0.62) +
            rng.nextDouble() * (isDark ? 0.18 : 0.16) +
            (i % 3 == 0 ? 0.02 : -0.01);
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
          minHue: palette == 'pink' ? 282 : null,
          maxHue: palette == 'pink' ? 344 : null,
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
    double? minHue,
    double? maxHue,
  }) {
    if (_contrastRatio(previous, candidate) >= 1.35) {
      return candidate;
    }

    var hsl = HSLColor.fromColor(candidate);
    for (var i = 0; i < 12; i++) {
      final sign = i.isEven ? 1 : -1;
      final hueShift = (i + 1) * 14 * sign;
      final lightShift = (i.isEven ? 0.1 : -0.1);
      final shiftedHue = _wrapHue(hsl.hue + hueShift);
      final adjustedHue = (minHue != null && maxHue != null)
          ? shiftedHue.clamp(minHue, maxHue).toDouble()
          : shiftedHue;
      final next = HSLColor.fromAHSL(
        1,
        adjustedHue,
        (hsl.saturation + (isDark ? 0.03 : 0.02)).clamp(0.1, 0.95),
        (hsl.lightness + lightShift).clamp(0.2, 0.82),
      ).toColor();
      if (_contrastRatio(previous, next) >= 1.35) {
        return next;
      }
    }

    final fallbackHue = (minHue != null && maxHue != null)
        ? _wrapHue(fallbackHueSeed).clamp(minHue, maxHue).toDouble()
        : (fallbackHueSeed + 160) % 360;
    final fallback = HSLColor.fromAHSL(
      1,
      fallbackHue,
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

  double _pinkHue(int index, Random rng) {
    const offsets = [-20.0, -12.0, -6.0, 0.0, 6.0, 12.0, 18.0, 24.0];
    final base = 316 + offsets[index % offsets.length];
    return (base + (rng.nextDouble() - 0.5) * 10).clamp(282, 344).toDouble();
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.wheel != wheel ||
        oldDelegate.winnerItemId != winnerItemId ||
        oldDelegate.brightness != brightness ||
        oldDelegate.detailScale != detailScale ||
        oldDelegate.materialSheenCenter != materialSheenCenter ||
        oldDelegate.materialDepthCenter != materialDepthCenter ||
        oldDelegate.materialSheenIntensity != materialSheenIntensity ||
        oldDelegate.materialDepthIntensity != materialDepthIntensity;
  }
}

class _LabelPolicy {
  const _LabelPolicy({
    required this.show,
    required this.singleCharOnly,
    required this.maxChars,
    required this.radius,
    required this.maxWidth,
    required this.fontSize,
    required this.maxLines,
    required this.showEllipsis,
  });

  const _LabelPolicy.hidden()
    : show = false,
      singleCharOnly = false,
      maxChars = 0,
      radius = 0,
      maxWidth = 0,
      fontSize = 12,
      maxLines = 1,
      showEllipsis = true;

  final bool show;
  final bool singleCharOnly;
  final int maxChars;
  final double radius;
  final double maxWidth;
  final double fontSize;
  final int maxLines;
  final bool showEllipsis;
}
