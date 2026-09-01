import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/character_detail_controller.dart';
import '../../controllers/character_list_controller.dart';
import '../../controllers/connectivity_controller.dart';
import '../../models/character_model.dart';
import '../../repositories/character_repository.dart';
import '../../widgets/character_list_tile.dart';
import '../../widgets/offline_banner.dart';
import '../character_detail/character_detail_page.dart';

/// Main screen: shows a paginated, searchable list of characters.
/// Also displays an offline banner when there is no network connection.
class CharactersListScreen extends StatefulWidget {
  const CharactersListScreen({super.key});

  @override
  State<CharactersListScreen> createState() => _CharactersListScreenState();
}

class _CharactersListScreenState extends State<CharactersListScreen> {
  late final ScrollController _scrollController;
  late final CharacterListController _controller;

  @override
  void initState() {
    super.initState();
    // Get the controller from Provider (already created in app.dart).
    _controller = context.read<CharacterListController>();
    // Listen to scroll events to trigger pagination.
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  /// When the user scrolls near the bottom, load the next page.
  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rick & Morty')),
      body: Consumer<CharacterListController>(
        builder: (context, controller, _) {
          return Column(
            children: [
              _buildOfflineBanner(controller),
              _buildSearchField(controller),
              Expanded(child: _buildBody(controller)),
            ],
          );
        },
      ),
    );
  }

  /// Shows the offline banner with connectivity status and cache age.
  Widget _buildOfflineBanner(CharacterListController controller) {
    return Consumer<ConnectivityController>(
      builder: (context, connectivity, _) => OfflineBanner(
        isOnline: connectivity.isOnline,
        lastUpdated: controller.lastUpdated,
      ),
    );
  }

  /// The search input field. Calls [onSearchChanged] which debounces.
  Widget _buildSearchField(CharacterListController controller) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search characters...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: controller.onSearchChanged,
      ),
    );
  }

  /// Decides which body to show based on the current state:
  /// loading, error, empty, or the character list.
  Widget _buildBody(CharacterListController controller) {
    if (controller.isLoadingInitial && controller.characters.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.failure != null && controller.characters.isEmpty) {
      return _buildErrorView(controller);
    }

    if (controller.characters.isEmpty && controller.failure == null) {
      return Center(child: Text('No results for "${controller.query}"'));
    }

    return _buildCharacterList(controller);
  }

  /// Error view with a retry button.
  Widget _buildErrorView(CharacterListController controller) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(controller.failure!.message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.retry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// The scrollable character list with pull-to-refresh and pagination.
  Widget _buildCharacterList(CharacterListController controller) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.characters.length +
            (controller.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show a loading spinner at the bottom while loading more.
          if (index == controller.characters.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final character = controller.characters[index];
          return CharacterListTile(
            character: character,
            onTap: () => _openDetail(context, character),
            onFavourite: () => controller.toggleFavourite(character),
          );
        },
      ),
    );
  }

  /// Navigates to the detail screen for the tapped character.
  /// Creates a fresh [CharacterDetailController] for that character.
  void _openDetail(BuildContext context, Character character) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider(
        create: (context) => CharacterDetailController(
          context.read<CharacterRepository>(),
          character.id,
          character: character,
        )..load(),
        child: CharacterDetailScreen(
          character: character,
          id: character.id,
        ),
      ),
    ));
  }
}
