/// Data model for one Pokémon returned by PokéAPI.
class Pokemon {
  final String name;
  final int id;
  final String imageUrl;

  const Pokemon({
    required this.name,
    required this.id,
    required this.imageUrl,
  });

  /// "bulbasaur" -> "Bulbasaur"
  String get displayName => name.isEmpty
      ? name
      : '${name[0].toUpperCase()}${name.substring(1)}';

  /// 1 -> "#001"
  String get formattedId => '#${id.toString().padLeft(3, '0')}';
}
