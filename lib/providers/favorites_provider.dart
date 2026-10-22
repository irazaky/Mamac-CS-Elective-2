import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import 'pokemon_provider.dart';

/// The ids of favorite Pokémon.
class FavoritesNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => <int>{};

  void toggleFavorite(int id) {
    final updated = {...state};
    if (!updated.remove(id)) updated.add(id);
    state = updated;
  }

  void removeFavorite(int id) {
    if (!state.contains(id)) return;
    state = {...state}..remove(id);
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<int>>(FavoritesNotifier.new);

/// Whether the favorites panel is expanded. Kept in Riverpod so the panel
/// stays open/closed while you move between screens.
class FavoritesPanelNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final favoritesPanelExpandedProvider =
    NotifierProvider<FavoritesPanelNotifier, bool>(FavoritesPanelNotifier.new);

/// Derived provider: the full Pokémon objects of the favorite ids.
/// Recomputes automatically when the list OR the favorites change.
final favoritePokemonProvider = Provider<List<Pokemon>>((ref) {
  final all = ref.watch(pokemonProvider.select((s) => s.pokemon));
  final favoriteIds = ref.watch(favoritesProvider);
  return all.where((p) => favoriteIds.contains(p.id)).toList();
});