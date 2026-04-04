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
                    top: -4,
                    child: Icon(
                      Icons.navigation_rounded,
                      size: 26,
                      color: Theme.of(context).colorScheme.onSurface,
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
    final rect = Rect.fromCircle(center: center, radius: radius - 2);
    final slices = wheel.items;
    if (slices.isEmpty) {
      final paint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    final palette = wheelPalettes(brightness)[wheel.palette] ?? wheelPalettes(brightness)['ocean']!;
    final wedge = (2 * pi) / slices.length;
    final dividerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < slices.length; i++) {
      final item = slices[i];
      final start = (-pi / 2) + rotation + (i * wedge);
      final color = parseHexColor(item.colorHex) ?? palette[i % palette.length];
      final paint = Paint()..color = color;
      canvas.drawArc(rect, start, wedge, true, paint);

      if (winnerItemId != null && winnerItemId == item.id) {
        final highlight = Paint()
          ..color = Colors.white.withValues(alpha: brightness == Brightness.dark ? 0.14 : 0.24);
        canvas.drawArc(rect, start, wedge, true, highlight);
      }

      final labelAngle = start + (wedge / 2);
      final labelOffset = Offset(
        center.dx + cos(labelAngle) * radius * 0.62,
        center.dy + sin(labelAngle) * radius * 0.62,
      );
      final text = item.title.length > 12 ? '${item.title.substring(0, 12)}…' : item.title;
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: radius * 0.52);
      canvas.save();
      canvas.translate(labelOffset.dx, labelOffset.dy);
      canvas.rotate(labelAngle + pi / 2);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }

    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      center,
      radius * 0.12,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
    canvas.drawCircle(
      center,
      radius * 0.12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.black.withValues(alpha: 0.15),
    );
    canvas.drawArc(rect, -pi / 2, 2 * pi, false, dividerPaint);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.wheel != wheel ||
        oldDelegate.winnerItemId != winnerItemId ||
        oldDelegate.brightness != brightness;
  }
}
