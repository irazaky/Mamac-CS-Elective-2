import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonService {
  Future<List<Pokemon>> getPokemon() async {
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=30');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load Pokémon');
    }

    final data = jsonDecode(response.body);
    final results = data['results'];

    List<Pokemon> pokemonList = [];

    for (var pokemon in results) {
      String name = pokemon['name'];
      String pokemonUrl = pokemon['url'];

      // The ID is the last number in the Pokémon URL.
      String idText = pokemonUrl.split('/').where((part) => part.isNotEmpty).last;
      int id = int.parse(idText);

      String imageUrl =
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

      pokemonList.add(
        Pokemon(
          name: name,
          id: id,
          imageUrl: imageUrl,
        ),
      );
    }

    return pokemonList;
  }
}
