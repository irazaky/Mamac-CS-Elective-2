
import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/pokemon_card.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  final PokemonService pokemonService = PokemonService();

  late Future<List<Pokemon>> pokemonFuture;

  @override
  void initState() {
    super.initState();

    pokemonFuture = pokemonService.getPokemon();
  }

  void tryAgain() {
    setState(() {
      pokemonFuture = pokemonService.getPokemon();
    });
  }

  int getColumns(double width) {
    if (width < 500) {
      return 2;
    } else if (width < 800) {
      return 3;
    } else if (width < 1100) {
      return 4;
    } else {
      return 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pokédex',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: pokemonFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Something went wrong.',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: tryAgain,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No Pokémon found.'),
            );
          }

          List<Pokemon> pokemonList = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              int columns = getColumns(constraints.maxWidth);

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: pokemonList.length,
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  return PokemonCard(
                    pokemon: pokemonList[index],
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

