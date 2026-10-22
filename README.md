# Pokédex – Midterm Exam (Riverpod)

CS Elective 2: Mobile Development with Flutter. The Pokédex now uses **Riverpod** (`flutter_riverpod`) instead of Provider.

## Features
- **List management** – `PokemonNotifier.fetch()` loads the list from PokéAPI (plus each Pokémon's types) and exposes loading / success / error states. The refresh button and pull-to-refresh call the same `fetch()`.
- **Nickname editor** – `NicknameNotifier` (`setNickname`, `removeNickname`). Cards and the detail page show the nickname and keep the original name.
- **Favorites** – `FavoritesNotifier` (`toggleFavorite`, `removeFavorite`). A retractable panel at the bottom of every screen lists them.
- **Favorite indicator** – heart on every card, driven by `favoritesProvider`.
- **Type filter** – `TypeFilterNotifier` (`selectType`, `clearFilter`) + derived `filteredPokemonProvider` using real type data.

## Structure
```
lib/
  main.dart                      ProviderScope + app-wide favorites panel
  app_navigator.dart             global navigator key
  models/pokemon.dart
  providers/
    pokemon_provider.dart        PokemonState, PokemonNotifier.fetch()
    nickname_provider.dart
    favorites_provider.dart      favorites, panel open/closed, favoritePokemonProvider
    type_filter_provider.dart    selected type, availableTypesProvider, filteredPokemonProvider
  screens/ pokedex_screen.dart, pokemon_detail_screen.dart
  widgets/ pokemon_card.dart, nickname_dialog.dart, favorites_panel.dart, type_filter_bar.dart
  utils/text_utils.dart
```

## Run
```
flutter pub get
flutter run -d chrome
```
Needs internet (PokéAPI + artwork).
