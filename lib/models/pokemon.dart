/// Data model for one Pokémon returned by PokéAPI.
class Pokemon {
  final String name;
  final int id;
  final String imageUrl;

  /// Real type data from PokéAPI, e.g. ['grass', 'poison'].
  final List<String> types;

  const Pokemon({
    required this.name,
    required this.id,
    required this.imageUrl,
    this.types = const [],
  });
}
