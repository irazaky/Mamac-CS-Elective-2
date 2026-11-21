import 'package:flutter/material.dart';

// comic book theme: red + blue, like a superhero cover
const _comicRed = Color(0xFFC62828);

ThemeData _buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: _comicRed,
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
    ),
  );
}

final lightTheme = _buildTheme(Brightness.light);
final darkTheme = _buildTheme(Brightness.dark);
