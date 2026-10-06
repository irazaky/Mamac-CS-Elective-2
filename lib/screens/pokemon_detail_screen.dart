import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokemon_provider.dart';

/// Detail page. Name, ID and image all come from PokemonProvider.
class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pokemon = context.watch<PokemonProvider>().selectedPokemon;

    if (pokemon == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pokémon Details')),
        body: const Center(child: Text('No Pokémon selected.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(pokemon.displayName)),
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
                pokemon.formattedId,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                pokemon.displayName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
