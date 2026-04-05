import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../../l10n/app_localizations.dart';
import '../widgets/liquid_glass_chrome.dart';

class DrawModeVisualStyle {
  const DrawModeVisualStyle({
    required this.accentColor,
    required this.glowColors,
    required this.onAccentColor,
  });

  final Color accentColor;
  final List<Color> glowColors;
  final Color onAccentColor;
}

DrawModeVisualStyle resolveDrawModeVisualStyle({
  required String palette,
  required bool isDark,
}) {
  final accentColor = switch (palette) {
    'random' => isDark ? const Color(0xFFBFA3FF) : const Color(0xFF7367F0),
    'ocean' => isDark ? const Color(0xFF71C5FF) : const Color(0xFF2188F6),
    'sunset' => isDark ? const Color(0xFFFFA36E) : const Color(0xFFEE6C2B),
    'mint' => isDark ? const Color(0xFF7DE4CA) : const Color(0xFF16B38A),
    'mono' => isDark ? const Color(0xFF9EA7B4) : const Color(0xFF6F7783),
    'pink' => isDark ? const Color(0xFFFFA3C8) : const Color(0xFFFF8AB6),
    _ => isDark ? const Color(0xFF9AB4FF) : const Color(0xFF4E6BDB),
  };

  final glowColors = switch (palette) {
    'random' =>
      isDark
          ? [const Color(0xFF9E8BFF), const Color(0xFF54AFFF)]
          : [const Color(0xFF7A6CF4), const Color(0xFF3E8EF9)],
    'ocean' =>
      isDark
          ? [const Color(0xFF53B8FF), const Color(0xFF35D7C8)]
          : [const Color(0xFF2A96FF), const Color(0xFF2CCFBA)],
    'sunset' =>
      isDark
          ? [const Color(0xFFFF9B65), const Color(0xFFFF5A86)]
          : [const Color(0xFFF57A38), const Color(0xFFEC4E6F)],
    'mint' =>
      isDark
          ? [const Color(0xFF59DFC1), const Color(0xFF5CCBF7)]
          : [const Color(0xFF26C8A0), const Color(0xFF3AAAE8)],
    'mono' =>
      isDark
          ? [const Color(0xFF8D97A7), const Color(0xFF6B7585)]
          : [const Color(0xFF858E9A), const Color(0xFFA8B0BC)],
    'pink' =>
      isDark
          ? [const Color(0xFFFF79BA), const Color(0xFFAD8DFF)]
          : [const Color(0xFFFF63AE), const Color(0xFFC29CFF)],
    _ =>
      isDark
          ? [const Color(0xFF9AB4FF), const Color(0xFF6FA0FF)]
          : [const Color(0xFF4E6BDB), const Color(0xFF3F8AF1)],
  };

  final onAccentColor = accentColor.computeLuminance() > 0.45
      ? Colors.black
      : Colors.white;

  return DrawModeVisualStyle(
    accentColor: accentColor,
    glowColors: glowColors,
    onAccentColor: onAccentColor,
  );
}

class DrawModeGlowBackdrop extends StatelessWidget {
  const DrawModeGlowBackdrop({
    super.key,
    required this.glowColors,
    required this.isDark,
    required this.child,
  });

  final List<Color> glowColors;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _ModeGlow(
            color: glowColors[0],
            alignment: const Alignment(-0.48, -0.38),
            radiusFactor: 0.72,
            isDark: isDark,
          ),
        ),
        Positioned.fill(
          child: _ModeGlow(
            color: glowColors[1],
            alignment: const Alignment(0.56, 0.34),
            radiusFactor: 0.78,
            isDark: isDark,
          ),
        ),
        child,
      ],
    );
  }
}

class DrawModePillTag extends StatelessWidget {
  const DrawModePillTag({
    super.key,
    required this.icon,
    required this.text,
    required this.accentColor,
  });

  final IconData icon;
  final String text;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LiquidGlassChrome(
      borderRadius: 999,
      accentColor: accentColor,
      isDark: isDark,
      shadowStrength: 0.52,
      highlightStrength: 0.95,
      child: GlassContainer(
        useOwnLayer: true,
        quality: GlassQuality.premium,
        shape: const LiquidRoundedSuperellipse(borderRadius: 999),
        settings: LiquidGlassSettings(
          blur: 0,
          thickness: isDark ? 10 : 9,
          glassColor: accentColor.withValues(alpha: isDark ? 0.16 : 0.14),
          lightIntensity: isDark ? 0.52 : 0.66,
          ambientStrength: isDark ? 0.03 : 0.02,
          refractiveIndex: 1.24,
          saturation: 1.0,
          chromaticAberration: 0,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: accentColor),
              const SizedBox(width: 6),
              Text(text, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawModeResultCard extends StatelessWidget {
  const DrawModeResultCard({
    super.key,
    required this.title,
    required this.value,
    required this.accentColor,
    required this.isDark,
  });

  final String title;
  final String value;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassChrome(
      borderRadius: 22,
      accentColor: accentColor,
      isDark: isDark,
      child: GlassContainer(
        useOwnLayer: true,
        quality: GlassQuality.premium,
        shape: const LiquidRoundedSuperellipse(borderRadius: 22),
        settings: LiquidGlassSettings(
          blur: 0,
          thickness: isDark ? 16 : 14,
          glassColor: accentColor.withValues(alpha: isDark ? 0.11 : 0.08),
          lightIntensity: isDark ? 0.48 : 0.62,
          ambientStrength: isDark ? 0.05 : 0.03,
          refractiveIndex: 1.22,
          saturation: 1.0,
          chromaticAberration: 0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.52 : 0.38),
              width: 1.35,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawModeFrostedPanel extends StatelessWidget {
  const DrawModeFrostedPanel({
    super.key,
    required this.accentColor,
    required this.isDark,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(12, 12, 12, 12),
  });

  final Color accentColor;
  final bool isDark;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassChrome(
      borderRadius: 22,
      accentColor: accentColor,
      isDark: isDark,
      shadowStrength: 0.86,
      highlightStrength: 0.9,
      child: GlassContainer(
        useOwnLayer: true,
        quality: GlassQuality.premium,
        shape: const LiquidRoundedSuperellipse(borderRadius: 22),
        settings: LiquidGlassSettings(
          blur: 0,
          thickness: isDark ? 14 : 12,
          glassColor: accentColor.withValues(alpha: isDark ? 0.08 : 0.06),
          lightIntensity: isDark ? 0.45 : 0.58,
          ambientStrength: isDark ? 0.04 : 0.03,
          refractiveIndex: 1.2,
          saturation: 1.0,
          chromaticAberration: 0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.46 : 0.28),
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class DrawModeGlassActionButton extends StatelessWidget {
  const DrawModeGlassActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onAccentColor,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color accentColor;
  final Color onAccentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onPressed != null;
    final glyphColor = isDark ? Colors.white : Colors.black;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 170),
      opacity: enabled ? 1 : 0.5,
      child: LiquidStretch(
        interactionScale: 1.01,
        stretch: 0.4,
        resistance: 0.08,
        hitTestBehavior: HitTestBehavior.translucent,
        child: SizedBox(
          height: 52,
          child: LiquidGlassChrome(
            borderRadius: 18,
            accentColor: accentColor,
            isDark: isDark,
            child: GlassButton.custom(
              onTap: onPressed ?? () {},
              enabled: enabled,
              label: label,
              width: double.infinity,
              height: 52,
              useOwnLayer: true,
              quality: GlassQuality.premium,
              shape: const LiquidRoundedSuperellipse(borderRadius: 18),
              settings: LiquidGlassSettings(
                blur: 0,
                thickness: isDark ? 18 : 20,
                glassColor: accentColor.withValues(alpha: isDark ? 0.08 : 0.1),
                lightIntensity: isDark ? 0.54 : 0.86,
                ambientStrength: isDark ? 0.02 : 0.03,
                refractiveIndex: 1.38,
                saturation: 1.08,
                chromaticAberration: 0,
              ),
              interactionScale: 1.0,
              stretch: 0,
              resistance: 0.1,
              glowColor: accentColor.withValues(alpha: isDark ? 0.08 : 0.12),
              glowRadius: 1.08,
              style: GlassButtonStyle.filled,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: glyphColor),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: glyphColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DrawModeEmptyState extends StatelessWidget {
  const DrawModeEmptyState({
    super.key,
    required this.l10n,
    required this.onOpenManage,
  });

  final AppLocalizations l10n;
  final VoidCallback onOpenManage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.noWheelsYet,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.createFirstWheelHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: onOpenManage, child: Text(l10n.goToManage)),
          ],
        ),
      ),
    );
  }
}

class _ModeGlow extends StatelessWidget {
  const _ModeGlow({
    required this.color,
    required this.alignment,
    required this.radiusFactor,
    required this.isDark,
  });

  final Color color;
  final Alignment alignment;
  final double radiusFactor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.shortestSide * 0.9;
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Container(
          width: size * radiusFactor,
          height: size * radiusFactor,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: isDark ? 0.32 : 0.17),
                color.withValues(alpha: isDark ? 0.11 : 0.06),
                color.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.42, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
