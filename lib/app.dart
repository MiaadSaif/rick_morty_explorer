import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'tools/network_info.dart';
import 'services/character_local_service.dart';
import 'api/character_api.dart';
import 'repositories/character_repository_impl.dart';
import 'repositories/character_repository.dart';
import 'controllers/character_list_controller.dart';
import 'controllers/connectivity_controller.dart';
import 'controllers/favourites_controller.dart';
import 'modules/characters/characters_page.dart';
import 'modules/favourites/favourites_page.dart';

/// Root widget of the app.
///
/// Sets up dependency injection via [MultiProvider]:
/// - [NetworkInfo] — checks internet connectivity
/// - [CharacterRepository] — data access layer (remote + local)
/// - [CharacterListController] — state for the character list screen
/// - [ConnectivityController] — state for online/offline status
/// - [FavouritesController] — state for the favourites screen
///
/// The optional [repository] and [networkInfo] parameters allow tests
/// to inject mock/fake implementations.
class MyApp extends StatelessWidget {
  final CharacterRepository? repository;
  final NetworkInfo? networkInfo;

  const MyApp({
    super.key,
    this.repository,
    this.networkInfo,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Network connectivity checker
        Provider<NetworkInfo>(
          create: (_) => networkInfo ?? NetworkInfoImpl(Connectivity()),
        ),
        // Repository: uses the injected one, or creates a real one
        Provider<CharacterRepository>(
          create: (context) =>
              repository ?? _createRepository(context.read<NetworkInfo>()),
        ),
        // Character list controller — loads first page on creation
        ChangeNotifierProvider<CharacterListController>(
          create: (context) =>
              CharacterListController(context.read<CharacterRepository>())
                ..init(),
        ),
        // Connectivity controller — checks status on creation
        ChangeNotifierProvider<ConnectivityController>(
          create: (context) =>
              ConnectivityController(context.read<NetworkInfo>())
                ..initConnectivity(),
        ),
        // Favourites controller — loads favourites on creation
        ChangeNotifierProvider<FavouritesController>(
          create: (context) =>
              FavouritesController(context.read<CharacterRepository>())..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Rick & Morty Explorer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }

  /// Creates the real repository with remote and local data sources.
  /// Uses Hive boxes that were opened in main.dart.
  CharacterRepository _createRepository(NetworkInfo networkInfo) {
    final remote = CharacterRemoteDataSource(client: http.Client());
    final local = CharacterLocalDataSource(
      Hive.box<String>('listCache'),
      Hive.box<String>('characterCache'),
      Hive.box<String>('favourites'),
    );
    return CharacterRepositoryImpl(
      networkInfo: networkInfo,
      remote: remote,
      local: local,
    );
  }
}

/// The main screen with a bottom navigation bar.
/// Switches between the character list and favourites screens.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Both screens are kept alive using IndexedStack so their state persists.
  final _screens = const [
    CharactersListScreen(),
    FavouritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Characters'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
        ],
      ),
    );
  }
}
