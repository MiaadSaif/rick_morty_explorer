import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/character_detail_controller.dart';
import '../../controllers/favourites_controller.dart';
import '../../models/character_model.dart';
import '../../repositories/character_repository.dart';
import '../../widgets/character_list_tile.dart';
import '../character_detail/character_detail_page.dart';

/// Shows the list of favourite characters saved by the user.
/// Tapping a character opens its detail screen.
/// Tapping the heart icon removes it from favourites.
class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: Consumer<FavouritesController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.failure != null) {
            return Center(child: Text(controller.failure!.message));
          }

          if (controller.characters.isEmpty) {
            return const Center(child: Text('No favourites yet.'));
          }

          return _buildFavouritesList(context, controller);
        },
      ),
    );
  }

  /// Builds the list of favourite characters.
  Widget _buildFavouritesList(
    BuildContext context,
    FavouritesController controller,
  ) {
    return ListView.builder(
      itemCount: controller.characters.length,
      itemBuilder: (context, index) {
        final character = controller.characters[index];
        return CharacterListTile(
          character: character,
          onTap: () => _openDetail(context, character),
          onFavourite: () => controller.remove(character),
        );
      },
    );
  }

  /// Navigates to the detail screen for the tapped character.
  void _openDetail(BuildContext context, Character character) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (context) => CharacterDetailController(
            context.read<CharacterRepository>(),
            character.id,
            character: character,
            favouritesController: context.read<FavouritesController>(),
          )..load(),
          child: CharacterDetailScreen(character: character, id: character.id),
        ),
      ),
    );
  }
}
