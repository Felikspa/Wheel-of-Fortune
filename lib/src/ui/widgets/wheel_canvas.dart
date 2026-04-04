import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../app_theme.dart';
import '../color_utils.dart';

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

    final palette = wheelPalettes(brightness)[wheel.palette] ?? wheelPalettes(brightness)['ocean']!;
    final wedge = (2 * pi) / slices.length;

    for (var i = 0; i < slices.length; i++) {
      final item = slices[i];
      final start = (-pi / 2) + rotation + (i * wedge);
      final base = parseHexColor(item.colorHex) ?? palette[i % palette.length];
      final sliceGradient = SweepGradient(
        startAngle: start,
        endAngle: start + wedge,
        colors: [
          Color.lerp(base, Colors.white, isDark ? 0.08 : 0.18)!,
          Color.lerp(base, Colors.black, isDark ? 0.22 : 0.12)!,
        ],
      );
      final paint = Paint()..shader = sliceGradient.createShader(wheelRect);
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
    for (var i = 0; i < slices.length; i++) {
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
