import 'package:flutter/material.dart';

Color paletteAccentColor(String palette, bool isDark) {
  return switch (palette) {
    'random' => isDark ? const Color(0xFFBFA3FF) : const Color(0xFF7367F0),
    'transparent' => isDark ? const Color(0xFFD6DCE8) : const Color(0xFF8F98A8),
    'ocean' => isDark ? const Color(0xFF71C5FF) : const Color(0xFF2188F6),
    'sunset' => isDark ? const Color(0xFFFFA36E) : const Color(0xFFEE6C2B),
    'mint' => isDark ? const Color(0xFF7DE4CA) : const Color(0xFF16B38A),
    'mono' => isDark ? const Color(0xFF9EA7B4) : const Color(0xFF6F7783),
    'pink' => isDark ? const Color(0xFFFFA3C8) : const Color(0xFFFF8AB6),
    _ => isDark ? const Color(0xFF9AB4FF) : const Color(0xFF4E6BDB),
  };
}

List<Color> paletteGlowColors(String palette, bool isDark) {
  return switch (palette) {
    'random' =>
      isDark
          ? [const Color(0xFF9E8BFF), const Color(0xFF54AFFF)]
          : [const Color(0xFF7A6CF4), const Color(0xFF3E8EF9)],
    'transparent' => [
      Colors.white.withValues(alpha: 0),
      Colors.white.withValues(alpha: 0),
    ],
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
}

List<Color> paletteBackdropOrbColors(String palette, bool isDark) {
  return switch (palette) {
    'random' =>
      isDark
          ? [const Color(0x336B8BFF), const Color(0x3345D9C8)]
          : [const Color(0x557A95FF), const Color(0x5558DCCF)],
    'transparent' =>
      isDark
          ? [const Color(0x22FFFFFF), const Color(0x14000000)]
          : [const Color(0x22FFFFFF), const Color(0x12000000)],
    'ocean' =>
      isDark
          ? [const Color(0x334EB7FF), const Color(0x3336D9C9)]
          : [const Color(0x5562B9FF), const Color(0x5554DACD)],
    'sunset' =>
      isDark
          ? [const Color(0x33FF915F), const Color(0x33FF4F89)]
          : [const Color(0x55FF9868), const Color(0x55FF679D)],
    'mint' =>
      isDark
          ? [const Color(0x3357E1C1), const Color(0x334EC4F2)]
          : [const Color(0x5561DEC6), const Color(0x5569CCF7)],
    'mono' =>
      isDark
          ? [const Color(0x337D879A), const Color(0x33666F80)]
          : [const Color(0x559AA3B0), const Color(0x55B3BBC8)],
    'pink' =>
      isDark
          ? [const Color(0x33FF74B5), const Color(0x339889FF)]
          : [const Color(0x55FF93C6), const Color(0x55B7A3FF)],
    _ =>
      isDark
          ? [const Color(0x336B8BFF), const Color(0x3345D9C8)]
          : [const Color(0x557A95FF), const Color(0x5558DCCF)],
  };
}
