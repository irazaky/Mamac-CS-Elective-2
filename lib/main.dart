import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_navigator.dart';
import 'screens/pokedex_screen.dart';
import 'widgets/favorites_panel.dart';

// Classic Pokédex colors
const Color pokedexRed = Color(0xFFDC0A2D);
const Color pokedexDarkRed = Color(0xFF9E0820);
const Color pokedexBlue = Color(0xFF30A7D7); // the big blue "lens"
const Color pokedexDark = Color(0xFF212121);
const Color pokedexBackground = Color(0xFFEDEDED);

void main() {
  // ProviderScope is where every Riverpod provider's state is stored.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: pokedexRed).copyWith(
      primary: pokedexRed,
      onPrimary: Colors.white,
      secondary: pokedexBlue,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFFFE0E4),
      onSecondaryContainer: pokedexDark,
      surface: Colors.white,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokédex',
      navigatorKey: appNavigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: pokedexBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: pokedexRed,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: pokedexDarkRed,
          scrolledUnderElevation: 4,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFD0D0D0)),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: pokedexRed,
        ),
      ),
      // `builder` wraps EVERY screen, so the favorites panel is available
      // all throughout the app.
      builder: (context, child) => FavoritesShell(child: child!),
      home: const PokedexScreen(),
    );
  }
}