# Rick and Morty Explorer

A Flutter application that explores the [Rick and Morty API](https://rickandmortyapi.com). It demonstrates clean architecture, Provider state management, offline caching, and typed error handling.

## Features

- Paginated character list with infinite scroll
- Search with 400 ms debounce
- Pull-to-refresh
- Character detail screen with favourite toggle
- Favourites screen with persisted favourites
- Offline mode using cached data
- Connectivity-aware offline banner
- Typed failures (Network, Server, Parsing, Cache, NotFound)
- Unit and widget tests

## Architecture

The project follows a layered architecture:

- `core/` — shared utilities (`Result`, `Failure`, `NetworkInfo`)
- `data/` — DTOs, mappers, local and remote data sources, repository implementation
- `domain/` — entities and repository contracts
- `presentation/` — Providers, screens and widgets

### Key packages

- `get` (GetX) for state management and dependency injection
- `http` for REST API calls
- `hive` + `hive_flutter` for local persistence
- `connectivity_plus` for network status

## Running the app

```sh
flutter pub get
flutter run
```

## Running tests

```sh
flutter test
```

## Offline behaviour

The app caches list and detail responses in Hive. When the device is offline, previously cached data is returned and an offline banner is shown with the age of the cache.

## Assumptions and limitations

- Favourites are stored locally only and are not synced to the API.
- Episode batching/lookup is not implemented; the bonus requirement was skipped to keep the implementation focused on the mandatory scope.
- The app targets iOS, Android and macOS. Web support has not been verified.

## AI tool usage

This project was implemented with the assistance of an AI coding assistant (Cascade) for code generation, debugging, and documentation.
