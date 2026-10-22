import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/favorites_provider.dart';
import '../providers/nickname_provider.dart';
import '../utils/text_utils.dart';
import 'nickname_dialog.dart';

class PokemonCard extends ConsumerWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;

  const PokemonCard({super.key, required this.pokemon, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // select() = rebuild this card ONLY when its own nickname / favorite changes.
    final nickname = ref.watch(nicknameProvider.select((m) => m[pokemon.id]));
    final isFavorite =
        ref.watch(favoritesProvider.select((f) => f.contains(pokemon.id)));

    final originalName = capitalize(pokemon.name);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: Image.network(
                      pokemon.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) => progress == null
                          ? child
                          : const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported_outlined,
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${pokemon.id.toString().padLeft(3, '0')}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  // Nickname (if any) is the headline; the original name stays visible.
                  Text(
                    nickname ?? originalName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (nickname != null)
                    Text(
                      originalName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  Text(
                    pokemon.types.map(capitalize).join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
            ),
            // Heart indicator + toggle
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                visualDensity: VisualDensity.compact,
                iconSize: 22,
                onPressed: () =>
                    ref.read(favoritesProvider.notifier).toggleFavorite(pokemon.id),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
              ),
            ),
            // Nickname editor
            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                tooltip: 'Edit nickname',
                visualDensity: VisualDensity.compact,
                iconSize: 20,
                onPressed: () => showNicknameDialog(context, pokemon),
                icon: const Icon(Icons.edit_outlined, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
