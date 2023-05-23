import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokeapi/model/pokemon/pokemon.dart';
import 'package:pokelist/extensions/pokemon_extensions.dart';
import 'package:pokelist/main.dart';
import 'package:pokelist/resources/values.dart';

/// Page detailing a [Pokemon].
class PokemonPage extends StatefulWidget {
  /// Creates a [PokemonPage] that details the passed [pokemon].
  const PokemonPage({required this.pokemon, super.key});

  /// Creates a [PokemonPage] that details the [pokemon] contained in the Route
  /// arguments.
  const PokemonPage.fromRoute({super.key}) : pokemon = null;

  /// The [Pokemon] associated with this tile.
  final Pokemon? pokemon;

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  bool pokemonInitialized = false;
  late Pokemon pokemon;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!pokemonInitialized) {
      pokemonInitialized = true;

      if (widget.pokemon != null) {
        pokemon = widget.pokemon!;
      } else {
        pokemon = ModalRoute.of(context)!.settings.arguments! as Pokemon;
      }
    }

    return FutureBuilder(
      future: ColorScheme.fromImageProvider(
        provider: CachedNetworkImageProvider(pokemon.largeImage),
        brightness: Theme.of(context).brightness,
      ),
      builder: (context, snapshot) {
        return Theme(
          data: snapshot.data == null
              ? Theme.of(context)
              : PokeListApp.createTheme(
                  Theme.of(context).brightness,
                  colorScheme: snapshot.data,
                ),
          child: Builder(
            builder: (context) {
              final theme = Theme.of(context);

              return Scaffold(
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  scrolledUnderElevation: 0,
                  backgroundColor: Colors.transparent,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Fullscreen title
                      _PokemonHero(pokemon),

                      // Spacing
                      const SizedBox(height: 32),

                      // Types
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          for (final type in pokemon.types!)
                            Chip(label: Text(type.type!.name!))
                        ],
                      ),

                      // Spacing
                      const SizedBox(height: 32),

                      // Weight and height
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Weight',
                                style: theme.textTheme.titleLarge,
                              ),
                              Text('${pokemon.weight! / 10} KG')
                            ],
                          ),
                          const SizedBox(width: 48),
                          Column(
                            children: [
                              Text(
                                'Height',
                                style: theme.textTheme.titleLarge,
                              ),
                              Text('${pokemon.height! / 10}m')
                            ],
                          ),
                        ],
                      ),

                      // Spacing
                      const SizedBox(height: 32),

                      Text(
                        'Stats',
                        style: theme.textTheme.titleLarge,
                      ),

                      // Spacing
                      const SizedBox(height: 16),

                      // Stats
                      Center(
                        child: SizedBox(
                          width: Values.maxWidth,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Table(
                              columnWidths: const {
                                0: IntrinsicColumnWidth(),
                                1: FixedColumnWidth(16),
                                2: IntrinsicColumnWidth(),
                                3: FixedColumnWidth(16),
                                4: FlexColumnWidth(),
                              },
                              children: [
                                for (final stat in pokemon.stats!)
                                  TableRow(
                                    children: [
                                      // Base stat name
                                      Text(
                                        // The name comes with dashes instead of
                                        // spaces.
                                        stat.stat!.name!.replaceAll('-', ' '),
                                      ),

                                      // Spacing
                                      const SizedBox.shrink(),

                                      // Base stat value
                                      Text(stat.baseStat!.toString()),

                                      // Spacing
                                      const SizedBox.shrink(),

                                      // Progress bar
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: LinearProgressIndicator(
                                            minHeight: 16,
                                            value: stat.baseStat! / 100,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Bottom spacing
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Fullscreen image and title of the Pokemon.
class _PokemonHero extends StatelessWidget {
  const _PokemonHero(this.pokemon);

  final Pokemon pokemon;

  /// The amount of translation to offset the image from the circle background.
  static const translation = 48.0;

  /// Half the [translation].
  ///
  /// This is used to keep the elements centered, as it can be applied to the
  /// image and the bg instead of only applying a single translation to the
  /// image, which will make it go down too much.
  static const halfTranslation = translation / 2;

  @override
  Widget build(BuildContext context) {
    final queryData = MediaQuery.of(context);
    final theme = Theme.of(context);

    // Because of the title below the image, we have to clamp by
    // percentage when height is less than width. When height is greater
    // than width (smartphones), just subtract 48 as margin.
    final pokemonImageDimension = min(
      queryData.size.height * .6,
      queryData.size.width - 48,
    );

    return SizedBox(
      height: queryData.size.height,
      width: queryData.size.width,
      child: ColoredBox(
        color: theme.colorScheme.primary,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -halfTranslation),
                      child: Center(
                        child: SizedBox.square(
                          dimension: pokemonImageDimension,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(1000),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, halfTranslation),
                      child: Center(
                        child: SizedBox.square(
                          dimension: pokemonImageDimension,
                          child: CachedNetworkImage(
                            imageUrl: pokemon.largeImage,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  pokemon.name!,
                  style: theme.textTheme.displaySmall!.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),

            // Scroll down icon
            Align(
              alignment: Alignment.bottomCenter,
              child: Icon(
                Icons.keyboard_arrow_down_sharp,
                color: theme.colorScheme.onPrimary.withOpacity(.5),
                size: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
