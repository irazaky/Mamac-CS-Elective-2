import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_navigator.dart';
import '../models/pokemon.dart';
import '../providers/favorites_provider.dart';
import '../providers/pokemon_provider.dart';
import '../screens/pokemon_detail_screen.dart';
import '../utils/text_utils.dart';
import '../providers/nickname_provider.dart';

/// Puts the favorites panel under every screen of the app.
class FavoritesShell extends StatelessWidget {
  final Widget child;

  const FavoritesShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Column(
      children: [
        // Index 0 always holds the Navigator, so it is never rebuilt from scratch.
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: child,
          ),
        ),
        if (!keyboardOpen) const FavoritesPanel(),
      ],
    );
  }
}

/// Retractable favorites tab. Tap the header to expand / collapse.
class FavoritesPanel extends ConsumerWidget {
  const FavoritesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = ref.watch(favoritesPanelExpandedProvider);
    final favorites = ref.watch(favoritePokemonProvider);
    final scheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 8,
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () =>
                  ref.read(favoritesPanelExpandedProvider.notifier).toggle(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Favorites (${favorites.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Icon(expanded ? Icons.expand_more : Icons.expand_less),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: expanded
                  ? _PanelBody(favorites: favorites)
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelBody extends ConsumerWidget {
  final List<Pokemon> favorites;

  const _PanelBody({required this.favorites});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (favorites.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            'No favorites yet. Tap the heart on a Pokémon card to add one.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final nicknames = ref.watch(nicknameProvider);

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final pokemon = favorites[index];
          final label = nicknames[pokemon.id] ?? capitalize(pokemon.name);

          return SizedBox(
            width: 96,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  ref.read(pokemonProvider.notifier).selectPokemon(pokemon);
                  appNavigatorKey.currentState?.push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PokemonDetailScreen(),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.network(
                              pokemon.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported_outlined),
                            ),
                          ),
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () => ref
                            .read(favoritesProvider.notifier)
                            .removeFavorite(pokemon.id),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
