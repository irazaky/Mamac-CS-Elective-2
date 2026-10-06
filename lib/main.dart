import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/pokemon_provider.dart';
import 'screens/pokedex_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PokemonProvider()..fetchPokemon(),
      child: const MyApp(),
    ),
  );
}

/// By default Flutter only lets touch drag a scrollable, so pull-to-refresh
/// does nothing with a mouse (Chrome / desktop). This allows mouse drag too.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokédex',
      scrollBehavior: AppScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        useMaterial3: true,
      ),
      home: const PokedexScreen(),
    );
  }
}
