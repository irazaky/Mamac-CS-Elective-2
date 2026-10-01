# Pokédex Activity

A simple Flutter Pokédex made for the CS Elective 2 Async Activity.

## What the app does

- Gets Pokémon from PokéAPI.
- Gets the first 30 Pokémon.
- Shows the Pokémon name, ID, and image.
- Uses `Future` and `FutureBuilder` for the API request.
- Shows a loading screen while the data is being fetched.
- Shows an error message if the request fails.
- Shows an empty message if there are no Pokémon.
- Uses a responsive grid so it works on phones, tablets, and computers.
- Does not have a Pokémon details page.

## Why Future instead of Stream?

I used a `Future` because the app only needs to get the Pokémon data once when the page loads. A `Stream` would be more useful for data that keeps changing or arriving continuously.

## Folder structure

```text
lib/
├── main.dart
├── models/
│   └── pokemon.dart
├── services/
│   └── pokemon_service.dart
├── widgets/
│   └── pokemon_card.dart
└── screens/
    └── pokedex_screen.dart
```

## Run the project

```bash
flutter pub get
flutter run
```

## Git branch

```bash
git checkout -b pokedex-act
git add .
git commit -m "Complete Pokédex async activity"
git push -u origin pokedex-act
```
