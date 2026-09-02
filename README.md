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

- `tools/` — shared utilities (`Result`, `Failure`, `NetworkInfo`)
- `api/` and `services/` — remote and local data sources
- `models/` — domain models, DTOs, and DTO-to-domain mappers
- `repositories/` — repository contracts and implementations
- `controllers/` — Provider/ChangeNotifier presentation state
- `modules/` and `widgets/` — screens and reusable UI components

Provider supplies dependencies and screen controllers, while ChangeNotifier exposes loading, data, error, pagination, and favourite state. This keeps widgets focused on rendering and user interaction and makes repositories replaceable in tests.

### Key packages

- `provider` for state management
- `http` for REST API calls
- `hive` + `hive_flutter` for local persistence
- `connectivity_plus` for network status

## Sources

- [Rick and Morty API](https://rickandmortyapi.com)
- [`connectivity_plus` on pub.dev](https://pub.dev/packages/connectivity_plus)
- [`provider` on pub.dev](https://pub.dev/packages/provider)
- [`http` on pub.dev](https://pub.dev/packages/http)
- [`hive` on pub.dev](https://pub.dev/packages/hive)
- [`hive_flutter` on pub.dev](https://pub.dev/packages/hive_flutter)

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

The app caches each list response in Hive using the normalized search query and page number, and caches individual detail responses by character ID. When the device is offline, only an exact cached query/page is returned; data from another search is never used. An offline banner shows the age of the cached data, and the list refreshes when connectivity is restored.

## Assumptions and limitations

- Favourites are stored locally only and are not synced to the API.
- Episode batching/lookup is not implemented; the bonus requirement was skipped to keep the implementation focused on the mandatory scope.
- The app targets iOS, Android and macOS. Web support has not been verified.

## AI tool usage

This project was implemented with the assistance of an AI coding assistant (Cascade) for code generation, debugging, and documentation.
