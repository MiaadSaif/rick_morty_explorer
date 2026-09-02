import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/character_detail_controller.dart';
import '../../models/character_model.dart';

/// Shows detailed information about a single character.
/// Receives a [Character] (if available from the list) and an [id].
/// The [CharacterDetailController] is provided by the parent screen.
class CharacterDetailScreen extends StatelessWidget {
  final Character? character;
  final int id;

  const CharacterDetailScreen({super.key, this.character, required this.id});

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterDetailController>(
      builder: (context, controller, _) {
        final character = controller.character;

        return Scaffold(
          appBar: AppBar(title: Text(character?.name ?? 'Character')),
          body: character != null
              ? _buildCharacterDetails(context, character, controller)
              : controller.failure != null
              ? _buildError(context, controller)
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildError(
    BuildContext context,
    CharacterDetailController controller,
  ) {
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

  /// Builds the scrollable detail content for a loaded character.
  Widget _buildCharacterDetails(
    BuildContext context,
    Character character,
    CharacterDetailController controller,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCharacterImage(character),
          _buildCharacterHeader(character, controller),
          _InfoRow('Gender', character.gender),
          _InfoRow('Origin', character.origin),
          _InfoRow('Location', character.location),
        ],
      ),
    );
  }

  /// Shows the character's image if one is available.
  Widget _buildCharacterImage(Character character) {
    if (character.image.isEmpty) return const SizedBox.shrink();

    return Image.network(
      character.image,
      width: double.infinity,
      height: 300,
      fit: BoxFit.cover,
    );
  }

  /// Shows the character's name, status, species, and favourite toggle.
  Widget _buildCharacterHeader(
    Character character,
    CharacterDetailController controller,
  ) {
    return ListTile(
      title: Text(character.name),
      subtitle: Text('${character.status} · ${character.species}'),
      trailing: IconButton(
        icon: Icon(
          character.isFavourite ? Icons.favorite : Icons.favorite_border,
          color: character.isFavourite ? Colors.red : null,
        ),
        onPressed: controller.toggleFavourite,
      ),
    );
  }
}

/// A simple label-value row used in the detail screen.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(label), subtitle: Text(value));
  }
}
