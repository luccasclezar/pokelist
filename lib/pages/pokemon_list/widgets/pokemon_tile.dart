import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokeapi/model/pokemon/pokemon.dart';
import 'package:pokelist/extensions/pokemon_extensions.dart';
import 'package:pokelist/pages/pokemon_list/pokemon_list_page.dart';
import 'package:shimmer/shimmer.dart';

/// Tile for a Pokemon in the list.
class PokemonTile extends ConsumerWidget {
  /// Creates a [PokemonTile] for the passed [pokemon].
  const PokemonTile({required this.pokemon, super.key});

  /// The [Pokemon] associated with this tile.
  final Pokemon? pokemon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = ref.watch(tileSizeProvider);

    final theme = Theme.of(context);

    if (pokemon == null) {
      return SizedBox(
        height: size.height,
        width: size.width,
        child: Shimmer.fromColors(
          baseColor: Colors.black12,
          highlightColor: Colors.black26,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: size.height,
      width: size.width,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.hardEdge,
        elevation: 6,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/pokemon',
              arguments: pokemon,
            );
          },
          child: Column(
            children: [
              // Image
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    color: theme.brightness == Brightness.dark
                        ? Colors.black26
                        : Colors.black12,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: pokemon!.largeImage,
                    ),
                  ),
                ),
              ),

              // Name
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '${pokemon!.name![0].toUpperCase()}'
                    '${pokemon!.name!.substring(1)}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
