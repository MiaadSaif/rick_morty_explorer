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

Requirements:

- Flutter 3.32.7 (stable)
- Dart 3.8.1
- Xcode and an iOS simulator/device for iOS builds

Setup and run:

```sh
flutter pub get
flutter run
```

The app was built and tested on iOS using an iPhone 17 Pro Max simulator. Android configuration is included but was not used for the final manual verification.

## Running tests

```sh
flutter test
```

## Offline behaviour

The app caches each list response in Hive using the normalized search query and page number, and caches individual detail responses by character ID. When the device is offline, only an exact cached query/page is returned; data from another search is never used. An offline banner shows the age of the cached data, and the list refreshes when connectivity is restored.

## Assumptions and limitations

- Favourites are stored locally only and are not synced to the API.
- Cached list pages are keyed by normalized search query and page; an uncached offline query does not use another query's data.
- Episode batching/lookup is not implemented; the optional bonus was intentionally skipped to keep the mandatory scope solid.
- The app was manually verified on iOS. Android configuration is included but was not manually tested for this submission; web support has not been verified.
- Images are loaded from the API image URLs and may fail independently of cached character data when offline or rate-limited.
- Rough time spent was not tracked.

## Submission checklist

- [x] Source code and incremental commit history
- [x] README with setup, architecture, state, cache, assumptions, limitations, and AI disclosure
- [ ] Record a 2–3 minute demo showing the app and at least one airplane-mode/offline scenario
- [ ] Send the public repository link by email as requested by the assignment

## AI tool usage


AI coding assistance (Cascade) was used during development for code suggestions, debugging support, and documentation assistance. All generated suggestions were reviewed, adapted, tested, and integrated by me. I remain responsible for the final implementation and understand the submitted code.on.
