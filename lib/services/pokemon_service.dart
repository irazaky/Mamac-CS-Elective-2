import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

/// Talks to PokéAPI. Knows nothing about UI or app state.
class PokemonService {
  static const String _listUrl = 'https://pokeapi.co/api/v2/pokemon?limit=30';
  static const String _artworkBase =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork';

  Future<List<Pokemon>> getPokemon() async {
    final response = await http
        .get(Uri.parse(_listUrl))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('PokéAPI returned status ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final results = decoded['results'] as List<dynamic>;

    return results.map((item) {
      final entry = item as Map<String, dynamic>;
      final pokemonUrl = entry['url'] as String;

      // The ID is the last number in the Pokémon URL.
      final id = int.parse(
        pokemonUrl.split('/').where((part) => part.isNotEmpty).last,
      );

      return Pokemon(
        name: entry['name'] as String,
        id: id,
        imageUrl: '$_artworkBase/$id.png',
      );
    }).toList();
  }
}
