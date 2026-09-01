import 'package:flutter/material.dart';

import '../models/character_model.dart';

/// A single row in the character list or favourites list.
/// Shows the character's avatar, name, status/species, and a favourite toggle.
class CharacterListTile extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;
  final VoidCallback onFavourite;

  const CharacterListTile({
    super.key,
    required this.character,
    required this.onTap,
    required this.onFavourite,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildAvatar(),
      title: Text(character.name),
      subtitle: Text('${character.status} · ${character.species}'),
      trailing: IconButton(
        icon: Icon(
          character.isFavourite ? Icons.favorite : Icons.favorite_border,
          color: character.isFavourite ? Colors.red : null,
        ),
        onPressed: onFavourite,
      ),
      onTap: onTap,
    );
  }

  /// Builds the avatar: shows the character's image if available,
  /// otherwise shows a placeholder person icon.
  Widget _buildAvatar() {
    final hasImage = character.image.isNotEmpty;
    return CircleAvatar(
      backgroundImage: hasImage ? NetworkImage(character.image) : null,
      child: hasImage ? null : const Icon(Icons.person),
    );
  }
}
