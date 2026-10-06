import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

enum PokemonStatus { loading, success, error }

/// App-wide state for the Pokédex. Every value the screens display
/// (list, status, errors, selection, last-updated info) lives here.
class PokemonProvider extends ChangeNotifier {
  PokemonProvider({PokemonService? service})
      : _service = service ?? PokemonService();

  final PokemonService _service;

  List<Pokemon> _pokemon = const [];
  PokemonStatus _status = PokemonStatus.loading;
  String? _errorMessage;
  bool _isFetching = false;
  int? _selectedId;
  DateTime? _lastUpdated;
  int _fetchCount = 0;

  List<Pokemon> get pokemon => UnmodifiableListView(_pokemon);
  PokemonStatus get status => _status;
  String? get errorMessage => _errorMessage;

  /// True while ANY request is in flight (first load or refresh).
  bool get isFetching => _isFetching;

  /// When the last successful request finished.
  DateTime? get lastUpdated => _lastUpdated;

  /// How many API requests have succeeded so far (proves refresh re-calls the API).
  int get fetchCount => _fetchCount;

  /// The Pokémon shown on the detail page, looked up from the list in state.
  Pokemon? get selectedPokemon {
    final id = _selectedId;
    if (id == null) return null;
    for (final p in _pokemon) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Loads Pokémon from PokéAPI. Used for the first load AND for refresh.
  ///
  /// On a refresh the existing list stays on screen (no full-screen spinner),
  /// and if the refresh fails the old list is kept.
  Future<void> fetchPokemon() async {
    if (_isFetching) return; // ignore double-taps / overlapping refreshes
    _isFetching = true;
    _errorMessage = null;

    final hadData = _pokemon.isNotEmpty;
    if (!hadData) _status = PokemonStatus.loading;
    notifyListeners();

    try {
      _pokemon = await _service.getPokemon();
      _status = PokemonStatus.success;
      _lastUpdated = DateTime.now();
      _fetchCount++;
    } catch (e) {
      debugPrint('fetchPokemon failed: $e');
      if (hadData) {
        _errorMessage = 'Refresh failed. Showing the previous results.';
      } else {
        _errorMessage =
            'Unable to load Pokémon. Check your connection and try again.';
        _status = PokemonStatus.error;
      }
    }

    _isFetching = false;
    notifyListeners();
  }

  /// Stores which Pokémon was tapped so the detail page can read it from state.
  void selectPokemon(Pokemon pokemon) {
    _selectedId = pokemon.id;
    notifyListeners();
  }
}
