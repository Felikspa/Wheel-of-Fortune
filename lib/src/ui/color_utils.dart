import 'package:flutter/material.dart';

Color? parseHexColor(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  final hex = value.replaceFirst('#', '');
  if (hex.length != 6 && hex.length != 8) {
    return null;
  }
  final normalized = hex.length == 6 ? 'FF$hex' : hex;
  final colorInt = int.tryParse(normalized, radix: 16);
  if (colorInt == null) {
    return null;
  }
  return Color(colorInt);
}
