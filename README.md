# pokelist

My take on the whole Pokemon list app thing.

This is not exactly done as a challenge, it's more of a way to test some new ideas with Flutter.

## Back-end

The app uses PokeAPI for all the actual information and PokemonDB for the images (as PokeAPI's images are very low-res).

## Front-end

Riverpod is used for state-management with some other plugins for specific areas, like cached_network_image for caching images and shimmer to display a loading state before the actual information is loaded.

The app is made for any screen size, from desktop to mobile.

# Screenshots

|List|Details|
|-|-|
|![List](./screenshots/list.png)|![Details](./screenshots/details_hero.png)|
