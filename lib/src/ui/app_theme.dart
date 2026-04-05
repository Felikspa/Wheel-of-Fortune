import 'package:flutter/material.dart';

import '../domain/models.dart';

ThemeMode toFlutterThemeMode(AppThemeMode mode) {
  return switch (mode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}

ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF007AFF),
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    platform: TargetPlatform.iOS,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFF3F5FA),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.7),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
      ),
    ),
    dividerTheme: DividerThemeData(color: Colors.black.withValues(alpha: 0.08)),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    textTheme: Typography.blackCupertino,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 50),
        backgroundColor: Colors.white.withValues(alpha: 0.4),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF007AFF), width: 1.2),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.68),
    ),
  );
}

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF5AC8FA),
    brightness: Brightness.dark,
  );
  return ThemeData(
    useMaterial3: true,
    platform: TargetPlatform.iOS,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF0B0C10),
    cardTheme: CardThemeData(
      color: const Color(0xFF171921).withValues(alpha: 0.72),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
    ),
    dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: 0.1)),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    textTheme: Typography.whiteCupertino,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 50),
        backgroundColor: Colors.white.withValues(alpha: 0.06),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF5AC8FA), width: 1.2),
      ),
      filled: true,
      fillColor: const Color(0xFF13151A).withValues(alpha: 0.88),
    ),
  );
}

Map<String, List<Color>> wheelPalettes(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return {
    'random': dark
        ? const [
            Color(0xFF22D3EE),
            Color(0xFF60A5FA),
            Color(0xFFF472B6),
            Color(0xFF34D399),
          ]
        : const [
            Color(0xFF0EA5E9),
            Color(0xFF3B82F6),
            Color(0xFFEC4899),
            Color(0xFF10B981),
          ],
    'ocean': dark
        ? const [
            Color(0xFF146C94),
            Color(0xFF2A9D8F),
            Color(0xFF4C78A8),
            Color(0xFF0A9396),
          ]
        : const [
            Color(0xFF5AC8FA),
            Color(0xFF32D74B),
            Color(0xFF0A84FF),
            Color(0xFF64D2FF),
          ],
    'sunset': dark
        ? const [
            Color(0xFF9A3412),
            Color(0xFFB45309),
            Color(0xFFBE185D),
            Color(0xFF7C3AED),
          ]
        : const [
            Color(0xFFFF9F0A),
            Color(0xFFFF453A),
            Color(0xFFFF375F),
            Color(0xFFBF5AF2),
          ],
    'mint': dark
        ? const [
            Color(0xFF0F766E),
            Color(0xFF0E7490),
            Color(0xFF166534),
            Color(0xFF15803D),
          ]
        : const [
            Color(0xFF66D4CF),
            Color(0xFF64D2FF),
            Color(0xFF30D158),
            Color(0xFF34C759),
          ],
    'mono': dark
        ? const [
            Color(0xFF3A3D44),
            Color(0xFF2A2C31),
            Color(0xFF545863),
            Color(0xFF6B7280),
          ]
        : const [
            Color(0xFFE5E7EB),
            Color(0xFFD1D5DB),
            Color(0xFF9CA3AF),
            Color(0xFF6B7280),
          ],
    'pink': dark
        ? const [
            Color(0xFF7C1D5A),
            Color(0xFF9D2C84),
            Color(0xFF6D3CCF),
            Color(0xFFAA6DF7),
          ]
        : const [
            Color(0xFFFF8FC6),
            Color(0xFFFF5FAF),
            Color(0xFFC9A4FF),
            Color(0xFFAB7DFF),
          ],
  };
}
