import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pokemon_provider.dart';
import '../providers/type_filter_provider.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/type_filter_bar.dart';
import 'pokemon_detail_screen.dart';

class PokedexScreen extends ConsumerWidget {
  const PokedexScreen({super.key});

  int _getColumns(double width) {
    if (width < 500) return 2;
    if (width < 800) return 3;
    if (width < 1100) return 4;
    return 5;
  }

  /// Refresh = call the SAME fetch() method again through Riverpod.
  Future<void> _refresh(WidgetRef ref) => ref.read(pokemonProvider.notifier).fetch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pokemonProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh Pokémon',
            onPressed:
                state.status == PokemonStatus.loading ? null : () => _refresh(ref),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.status == PokemonStatus.success) const TypeFilterBar(),
          Expanded(child: _buildBody(context, ref, state)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, PokemonState state) {
    switch (state.status) {
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
                Text(
                  state.errorMessage ?? 'Something went wrong.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _refresh(ref),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        );

      case PokemonStatus.success:
        if (state.pokemon.isEmpty) {
          return const Center(child: Text('No Pokémon found.'));
        }

        final visible = ref.watch(filteredPokemonProvider);
        final selectedType = ref.watch(typeFilterProvider);

        return RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: visible.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(32),
                  children: [
                    Text(
                      'No Pokémon match the "$selectedType" type.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: OutlinedButton(
                        onPressed: ref.read(typeFilterProvider.notifier).clearFilter,
                        child: const Text('Clear filter'),
                      ),
                    ),
                  ],
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: visible.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _getColumns(constraints.maxWidth),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        final pokemon = visible[index];
                        return PokemonCard(
                          pokemon: pokemon,
                          onTap: () {
                            ref.read(pokemonProvider.notifier).selectPokemon(pokemon);
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
        );
    }
  }
}
