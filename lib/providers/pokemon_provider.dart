import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

enum PokemonStatus { loading, success, error }

/// Immutable snapshot of the Pokémon list. Riverpod replaces the whole object
/// every time something changes, which is what tells widgets to rebuild.
class PokemonState {
  final List<Pokemon> pokemon;
  final PokemonStatus status;
  final String? errorMessage;
  final int? selectedId;

  const PokemonState({
    this.pokemon = const [],
    this.status = PokemonStatus.loading,
    this.errorMessage,
    this.selectedId,
  });

  /// The Pokémon currently opened on the detail page (null if none).
  Pokemon? get selectedPokemon {
    for (final p in pokemon) {
      if (p.id == selectedId) return p;
    }
    return null;
  }

  PokemonState copyWith({
    List<Pokemon>? pokemon,
    PokemonStatus? status,
    String? errorMessage,
    bool clearError = false,
    int? selectedId,
  }) {
    return PokemonState(
      pokemon: pokemon ?? this.pokemon,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedId: selectedId ?? this.selectedId,
    );
  }
}

/// Owns the Pokémon list: loading, success, error and the API call itself.
class PokemonNotifier extends Notifier<PokemonState> {
  static const _listUrl = 'https://pokeapi.co/api/v2/pokemon?limit=30';
  static const _timeout = Duration(seconds: 20);

  @override
  PokemonState build() {
    // First load happens automatically when the provider is first read.
    Future.microtask(fetch);
    return const PokemonState();
  }

  /// Loads Pokémon (and their types) from PokéAPI.
  /// The home page's refresh button and pull-to-refresh simply call this again.
  Future<void> fetch() async {
    state = state.copyWith(status: PokemonStatus.loading, clearError: true);

    try {
      final listResponse = await http.get(Uri.parse(_listUrl)).timeout(_timeout);
      if (listResponse.statusCode != 200) {
        throw Exception('PokéAPI returned status ${listResponse.statusCode}.');
      }

      final decoded = jsonDecode(listResponse.body) as Map<String, dynamic>;
      final results = decoded['results'] as List<dynamic>;

      // The list endpoint has no type data, so request each Pokémon's detail
      // endpoint (all 30 at the same time) to read its real types.
      final loaded = await Future.wait(
        results.map((item) async {
          final entry = item as Map<String, dynamic>;
          final url = entry['url'] as String;
          final id = int.parse(url.split('/').where((p) => p.isNotEmpty).last);

          final detailResponse = await http.get(Uri.parse(url)).timeout(_timeout);
          if (detailResponse.statusCode != 200) {
            throw Exception('PokéAPI returned status ${detailResponse.statusCode}.');
          }
          final detail = jsonDecode(detailResponse.body) as Map<String, dynamic>;
          final types = (detail['types'] as List<dynamic>)
              .map((t) => (t as Map<String, dynamic>)['type']['name'] as String)
              .toList();

          return Pokemon(
            name: entry['name'] as String,
            id: id,
            imageUrl:
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
            types: types,
          );
        }),
      );

      state = state.copyWith(pokemon: loaded, status: PokemonStatus.success);
    } catch (_) {
      state = state.copyWith(
        status: PokemonStatus.error,
        errorMessage: 'Unable to load Pokémon. Check your connection and try again.',
      );
    }
  }

  /// Remembers which Pokémon the detail page should show.
  void selectPokemon(Pokemon pokemon) {
    state = state.copyWith(selectedId: pokemon.id);
  }
}

final pokemonProvider =
    NotifierProvider<PokemonNotifier, PokemonState>(PokemonNotifier.new);
