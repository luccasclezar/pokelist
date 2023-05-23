import 'package:flutter/material.dart';
import 'package:pokeapi/model/pokemon/pokemon.dart';
import 'package:pokeapi/pokeapi.dart';
import 'package:pokelist/main.dart';

const int _pageSize = 12;

/// Controls the current Pokemon list and handles loading new pokemon.
class PokemonController extends ChangeNotifier {
  /// Initializes the [PokemonController], calling [loadMore].
  PokemonController() {
    loadMore();
  }

  // Public variables ----------------------------------------------------------

  /// The current Pokemon list loaded from PokeAPI.
  ///
  /// Null Pokemon means that it's currently being loaded.
  List<Pokemon?> pokemonList = [];

  // Private variables ---------------------------------------------------------

  bool _isLoading = false;
  int _fetchCount = 0;

  // Methods -------------------------------------------------------------------

  /// Loads the next batch of pokemon.
  ///
  /// Only runs again when done loading, even if called multiple times.
  void loadMore() {
    if (_isLoading) {
      return;
    }

    // Mark as loading and set all the new Pokemon batch to null as they are
    // loading.
    _isLoading = true;
    pokemonList.addAll(List.filled(_pageSize, null));

    // Now notify the listeners that a new batch is being loaded.
    notifyListeners();

    // Get the next bacth from PokeAPI.
    PokeAPI.getObjectList<Pokemon>(_fetchCount * _pageSize + 1, _pageSize).then(
      (value) {
        // When loaded, replace the null values with the returned pokemon.
        pokemonList.replaceRange(
          _fetchCount * _pageSize,
          _fetchCount * _pageSize + _pageSize,
          value,
        );

        // Update the local variables
        _isLoading = false;
        _fetchCount++;

        // Then notify the listeners again.
        notifyListeners();
      },
      onError: (error, stackTrace) {
        // If error, just show a generic snackbar. Maybe this could be expanded
        // to show a more specific error in the future.
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          const SnackBar(
            content: Text('Oops... Something went wrong'),
          ),
        );
      },
    );
  }
}
