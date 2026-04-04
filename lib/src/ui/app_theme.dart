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
    scaffoldBackgroundColor: const Color(0xFFF2F3F7),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.9),
      elevation: 0.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    dividerTheme: DividerThemeData(color: Colors.black.withValues(alpha: 0.06)),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    textTheme: Typography.blackCupertino,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
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
      fillColor: Colors.white.withValues(alpha: 0.95),
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
      color: const Color(0xFF171921).withValues(alpha: 0.92),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: 0.08)),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    textTheme: Typography.whiteCupertino,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
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
      fillColor: const Color(0xFF13151A),
    ),
  );
}

Map<String, List<Color>> wheelPalettes(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return {
    'ocean': dark
        ? const [Color(0xFF146C94), Color(0xFF2A9D8F), Color(0xFF4C78A8), Color(0xFF0A9396)]
        : const [Color(0xFF5AC8FA), Color(0xFF32D74B), Color(0xFF0A84FF), Color(0xFF64D2FF)],
    'sunset': dark
        ? const [Color(0xFF9A3412), Color(0xFFB45309), Color(0xFFBE185D), Color(0xFF7C3AED)]
        : const [Color(0xFFFF9F0A), Color(0xFFFF453A), Color(0xFFFF375F), Color(0xFFBF5AF2)],
    'mint': dark
        ? const [Color(0xFF0F766E), Color(0xFF0E7490), Color(0xFF166534), Color(0xFF15803D)]
        : const [Color(0xFF66D4CF), Color(0xFF64D2FF), Color(0xFF30D158), Color(0xFF34C759)],
    'mono': dark
        ? const [Color(0xFF3A3D44), Color(0xFF2A2C31), Color(0xFF545863), Color(0xFF6B7280)]
        : const [Color(0xFFE5E7EB), Color(0xFFD1D5DB), Color(0xFF9CA3AF), Color(0xFF6B7280)],
  };
}
