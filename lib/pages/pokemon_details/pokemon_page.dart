import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokeapi/model/pokemon/pokemon.dart';
import 'package:pokelist/extensions/pokemon_extensions.dart';
import 'package:pokelist/main.dart';
import 'package:pokelist/resources/values.dart';

/// Value in 0-1 range, used to control hero banner scroll animations.
final scrollDeltaProvider = StateProvider.autoDispose((ref) => 0.0);

/// The radius used on the bottom corners of AppBar.
const _toolbarBottomRadius = 24.0;

/// The offset from the actual end of hero banner that the animations should
/// already be ended.
const _heroBannerAnimationEndOffset = 88.0;

/// Page detailing a [Pokemon].
class PokemonPage extends ConsumerStatefulWidget {
  /// Creates a [PokemonPage] that details the passed [pokemon].
  const PokemonPage({required this.pokemon, super.key});

  /// Creates a [PokemonPage] that details the [pokemon] contained in the Route
  /// arguments.
  const PokemonPage.fromRoute({super.key}) : pokemon = null;

  /// The [Pokemon] associated with this tile.
  final Pokemon? pokemon;

  @override
  ConsumerState<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends ConsumerState<PokemonPage> {
  bool pokemonInitialized = false;
  late Pokemon pokemon;

  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Value in 0-1 range for the scroll related to the window's size, this is
    // used to guide scroll animations. The _heroBannerAnimationEndOffset part
    // is to end the animations early, as the AppBar should already be opaque
    // when the scroll ends.
    scrollController.addListener(
      () {
        final scrollEnd =
            MediaQuery.of(context).size.height - _heroBannerAnimationEndOffset;
        final delta = scrollController.offset / scrollEnd;

        ref.read(scrollDeltaProvider.notifier).state = delta.clamp(0, 1);
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
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
                appBar: PreferredSize(
                  // Taken from [AppBar] implementation.
                  preferredSize: Size.fromHeight(
                    AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight,
                  ),

                  // It's better to scope the Consumer here as a ref.watch
                  // updating the whole children on every scroll event was a
                  // little too unperformant.
                  child: Consumer(
                    builder: (context, ref, child) {
                      final scrollAnimation = ref.watch(scrollDeltaProvider);

                      return AppBar(
                        backgroundColor: scrollAnimation < 1
                            ? Colors.transparent
                            : theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        scrolledUnderElevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(_toolbarBottomRadius),
                          ),
                        ),
                        systemOverlayStyle:
                            theme.colorScheme.primary.computeLuminance() > .5
                                ? SystemUiOverlayStyle.dark
                                : SystemUiOverlayStyle.light,
                        title: Text(pokemon.name!),
                        titleTextStyle: theme.textTheme.titleLarge!.copyWith(
                          color: theme.colorScheme.onPrimary.withOpacity(
                            // The title should begin the opacity animation at
                            // 80% (.8) of the scroll animation. So:
                            // (delta - .8) / (1 - .8) => currentValue
                            // We just need to clamp between 0 and 1 because
                            // when the delta is lesser than .8, the resulting
                            // value will be < 0.
                            ((scrollAnimation - .8) / .2).clamp(0, 1),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                body: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      // Fullscreen title
                      _PokemonHero(
                        pokemon: pokemon,
                      ),

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
                        'Base Stats',
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
class _PokemonHero extends ConsumerWidget {
  const _PokemonHero({required this.pokemon});

  /// Pokemon this hero is displaying.
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
  Widget build(BuildContext context, WidgetRef ref) {
    final queryData = MediaQuery.of(context);
    final theme = Theme.of(context);

    // Because of the title below the image, we have to clamp by
    // percentage when height is less than width. When height is greater
    // than width (smartphones), just subtract 48 as margin.
    final pokemonImageDimension = min(
      queryData.size.height * .6,
      queryData.size.width - 48,
    );

    final scrollDelta = ref.watch(scrollDeltaProvider);

    return SizedBox(
      height: queryData.size.height,
      width: queryData.size.width,
      child: Stack(
        children: [
          // Top colored box just to continue the illusion of a header when the
          // user scrolls up on iOS/macOS.
          Positioned(
            height: queryData.size.height,
            width: queryData.size.width,
            child: Transform.translate(
              offset: Offset(0, -queryData.size.height),
              child: ColoredBox(
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          // Actual hero
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                // The border radius increases when scrolling down
                bottom: Radius.circular(
                  lerpDouble(0, _toolbarBottomRadius, scrollDelta)!,
                ),
              ),
              color: theme.colorScheme.primary,
            ),
            child: Transform.translate(
              // Add a translation animation on scroll to improve the fade
              // effect.
              offset: Offset(0, -scrollDelta * _heroBannerAnimationEndOffset),
              child: Opacity(
                // Fade out when scrolling.
                opacity: (1 - scrollDelta).clamp(0, 1),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Transform.translate(
                              offset: const Offset(
                                0,
                                -halfTranslation,
                              ),
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
            ),
          ),
        ],
      ),
    );
  }
}
