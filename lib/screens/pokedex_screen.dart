import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_detail_screen.dart';

class PokedexScreen extends StatelessWidget {
  const PokedexScreen({super.key});

  int _getColumns(double width) {
    if (width < 500) return 2;
    if (width < 800) return 3;
    if (width < 1100) return 4;
    return 5;
  }

  /// Re-triggers the API call (lives in the provider). Used by the app bar
  /// button, pull-to-refresh and the error screen's "Try Again" button.
  Future<void> _refresh(BuildContext context) {
    return context.read<PokemonProvider>().fetchPokemon();
  }

  String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PokemonProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh Pokémon',
            onPressed: provider.isFetching ? null : () => _refresh(context),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(context, provider),
    );
  }

  /// Small status line, built only from provider state.
  Widget _buildInfoBar(PokemonProvider provider) {
    final error = provider.errorMessage;
    final updated = provider.lastUpdated;

    final String text;
    if (error != null) {
      text = error;
    } else if (updated != null) {
      text = 'Updated ${_formatTime(updated)}  |  ${provider.pokemon.length} Pokémon  |  request #${provider.fetchCount}';
    } else {
      text = '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: error != null ? Colors.red : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PokemonProvider provider) {
    switch (provider.status) {
      case PokemonStatus.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Loading Pokémon...'),
            ],
          ),
        );
      case PokemonStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56, color: Colors.red),
                const SizedBox(height: 12),
                Text(provider.errorMessage ?? 'Something went wrong.', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _refresh(context),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        );
      case PokemonStatus.success:
        if (provider.pokemon.isEmpty) {
          return const Center(child: Text('No Pokémon found.'));
        }
        // The list stays on screen during a refresh, so the RefreshIndicator
        // is never torn down mid-request.
        return Column(
          children: [
            if (provider.isFetching) const LinearProgressIndicator(minHeight: 3),
            _buildInfoBar(provider),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _refresh(context),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: provider.pokemon.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _getColumns(constraints.maxWidth),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final Pokemon pokemon = provider.pokemon[index];
                        return PokemonCard(
                          pokemon: pokemon,
                          onTap: () {
                            context.read<PokemonProvider>().selectPokemon(pokemon);
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const PokemonDetailScreen(),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
    }
  }
}
