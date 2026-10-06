# Pokédex Activity

A Flutter Pokédex that loads Pokémon from PokéAPI and manages application data with Provider.

## Features

- `Pokemon` model contains each Pokémon's name, ID, and image URL.
- `PokemonService` makes the HTTP request; `PokemonProvider` owns Pokémon list, loading/success/error status, error message, and selected Pokémon.
- Responsive, scrollable grid of Pokémon cards.
- Refresh button in the app bar and pull-to-refresh (touch or mouse drag) on the grid. Refresh re-calls the API through the provider and keeps the current list visible while loading.
- A status line (last updated time, Pokémon count, request number) read from provider state.
- Tapping a Pokémon opens a detail page that reads the selected Pokémon from Provider.
- Loading, error, and success UI states.

## Run locally

1. Install Flutter and ensure `flutter` is available in your terminal.
2. Open this folder in VS Code.
3. Run `flutter pub get` to install dependencies.
4. Run `flutter run`.

The app requires an internet connection to call `https://pokeapi.co/api/v2/pokemon?limit=30` and load Pokémon artwork.
