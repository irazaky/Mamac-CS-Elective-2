import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import 'favorites_provider.dart';
import 'pokemon_provider.dart';

/// The selected type (e.g. 'fire'), or null when no filter is applied.
class TypeFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void selectType(String type) => state = type;

  void clearFilter() => state = null;
}

final typeFilterProvider =
    NotifierProvider<TypeFilterNotifier, String?>(TypeFilterNotifier.new);

/// Derived provider: every type that really appears in the loaded data.
final availableTypesProvider = Provider<List<String>>((ref) {
  final all = ref.watch(pokemonProvider.select((s) => s.pokemon));
  final types = <String>{for (final p in all) ...p.types};
  return types.toList()..sort();
});

/// Derived provider: the list the home page shows.
/// 1) applies the type filter, 2) moves favorites to the top (order inside each
/// group stays the same, so nothing else in the app is affected).
final filteredPokemonProvider = Provider<List<Pokemon>>((ref) {
  final all = ref.watch(pokemonProvider.select((s) => s.pokemon));
  final type = ref.watch(typeFilterProvider);
  final favoriteIds = ref.watch(favoritesProvider);

  final matching =
      type == null ? all : all.where((p) => p.types.contains(type)).toList();

  return [
    ...matching.where((p) => favoriteIds.contains(p.id)),
    ...matching.where((p) => !favoriteIds.contains(p.id)),
  ];
});

