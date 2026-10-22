import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favorites_provider.dart';
import '../providers/nickname_provider.dart';
import '../providers/pokemon_provider.dart';
import '../utils/text_utils.dart';
import '../widgets/nickname_dialog.dart';

class PokemonDetailScreen extends ConsumerWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(pokemonProvider.select((s) => s.selectedPokemon));

    if (pokemon == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pokémon Details')),
        body: const Center(child: Text('No Pokémon selected.')),
      );
    }

    final nickname = ref.watch(nicknameProvider.select((m) => m[pokemon.id]));
    final isFavorite =
        ref.watch(favoritesProvider.select((f) => f.contains(pokemon.id)));
    final originalName = capitalize(pokemon.name);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Details'),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: () =>
                ref.read(favoritesProvider.notifier).toggleFavorite(pokemon.id),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Image.network(
                    pokemon.imageUrl,
                    height: 240,
                    width: 240,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : const SizedBox(
                            height: 240,
                            width: 240,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                    errorBuilder: (context, error, stackTrace) => const SizedBox(
                      height: 240,
                      width: 240,
                      child: Icon(Icons.image_not_supported_outlined, size: 72),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '#${pokemon.id.toString().padLeft(3, '0')}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                nickname ?? originalName,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (nickname != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Original name: $originalName',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final type in pokemon.types)
                    Chip(label: Text(capitalize(type))),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => showNicknameDialog(context, pokemon),
                icon: const Icon(Icons.edit_outlined),
                label: Text(nickname == null ? 'Add nickname' : 'Edit nickname'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
