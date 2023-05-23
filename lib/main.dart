import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokelist/pages/pokemon_details/pokemon_page.dart';
import 'package:pokelist/pages/pokemon_list/pokemon_list_page.dart';

/// The root navigator's global key.
final navigatorKey = GlobalKey<NavigatorState>();

/// The root navigator's context.
///
/// The app must already be loaded for this to be called.
BuildContext get navigatorContext => navigatorKey.currentContext!;

void main() {
  runApp(const ProviderScope(child: PokeListApp()));
}

/// My take on the Pokemon list apps
class PokeListApp extends StatelessWidget {
  /// Creates a [PokeListApp].
  const PokeListApp({super.key});

  /// Creates a theme based on [colorScheme] or a default [ColorScheme.fromSeed]
  /// if null.
  static ThemeData createTheme(
    Brightness brightness, {
    ColorScheme? colorScheme,
  }) {
    final baseTheme = ThemeData(
      colorScheme: colorScheme ??
          ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: brightness,
          ),
      useMaterial3: true,
    );

    return baseTheme.copyWith(
      cardTheme: baseTheme.cardTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: baseTheme.textTheme.copyWith(
        displayLarge: baseTheme.textTheme.displayLarge!.copyWith(
          color: baseTheme.colorScheme.tertiary,
        ),
        displayMedium: baseTheme.textTheme.displayMedium!.copyWith(
          color: baseTheme.colorScheme.tertiary,
        ),
        displaySmall: baseTheme.textTheme.displaySmall!.copyWith(
          color: baseTheme.colorScheme.tertiary,
        ),
        titleLarge: baseTheme.textTheme.titleLarge!.copyWith(
          color: baseTheme.colorScheme.secondary,
        ),
        titleMedium: baseTheme.textTheme.titleMedium!.copyWith(
          color: baseTheme.colorScheme.secondary,
        ),
        titleSmall: baseTheme.textTheme.titleSmall!.copyWith(
          color: baseTheme.colorScheme.secondary,
        ),
      ),
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'PokeList',
      theme: createTheme(Brightness.light),
      darkTheme: createTheme(Brightness.dark),
      builder: (context, child) {
        if (Platform.isMacOS) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: const EdgeInsets.only(top: 30),
            ),
            child: child!,
          );
        } else {
          return child!;
        }
      },
      routes: {
        '/': (_) => const PokemonListPage(),
        '/pokemon': (_) => const PokemonPage.fromRoute(),
      },
    );
  }
}
