import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokelist/controllers/pokemon_controller.dart';
import 'package:pokelist/pages/pokemon_list/widgets/pokemon_tile.dart';

/// The minimum dimensions of each tile in pokemon list.
const Size pokemonMinSize = Size(200, 200);

/// The minimum dimensions of each tile in pokemon list.
const Size pokemonMaxSize = Size(300, 300);

/// Provides the current [PokemonController].
final pokemonControllerProvider =
    ChangeNotifierProvider.autoDispose((ref) => PokemonController());

/// Provides the size for each list tile.
///
/// This changes based on the current window size.
final tileSizeProvider = StateProvider.autoDispose((ref) => pokemonMinSize);

/// Page that displays a list of Pokemon.
///
/// The list is displayed in batches and updated when scrolled to the end.
class PokemonListPage extends ConsumerStatefulWidget {
  /// Creates a new [PokemonListPage].
  const PokemonListPage({super.key});

  @override
  ConsumerState<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends ConsumerState<PokemonListPage> {
  final scrollController = ScrollController();
  final gridViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.extentAfter < 40) {
      ref.read(pokemonControllerProvider).loadMore();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pokemonList = ref.watch(pokemonControllerProvider).pokemonList;

    return Scaffold(
      appBar: AppBar(title: const Text('PokeList')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            _scrollListener();

            final dimension =
                lerpDouble(100, 300, constraints.biggest.shortestSide / 1080)!;

            ref.read(tileSizeProvider.notifier).state =
                Size(dimension, dimension);
            // ref.read(tileSizeProvider.notifier).state = Size(
            //   lerpDouble(
            //     pokemonMinSize.width,
            //     pokemonMaxSize.width,
            //     constraints.biggest.shortestSide / 1080,
            //   )!,
            //   lerpDouble(
            //     pokemonMinSize.height,
            //     pokemonMaxSize.height,
            //     constraints.biggest.shortestSide / 1080,
            //   )!,
            // );
          });

          final size = ref.watch(tileSizeProvider);

          return Scrollbar(
            controller: scrollController,
            child: GridView.builder(
              key: gridViewKey,
              controller: scrollController,
              itemCount: pokemonList.length,
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.biggest.width ~/ size.width,
                mainAxisExtent: size.height,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return PokemonTile(pokemon: pokemonList[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
