import 'package:pokeapi/model/pokemon/pokemon.dart';

/// Extensions for the [Pokemon] model.
extension PokemonExtensions on Pokemon {
  /// Large resolution image from pokemondb.net.
  String get largeImage =>
      'https://img.pokemondb.net/artwork/vector/large/$name.png';
}
