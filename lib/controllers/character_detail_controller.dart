import 'package:flutter/material.dart';

import '../tools/result.dart';
import '../models/character_model.dart';
import '../repositories/character_repository.dart';

/// Manages the state for a single character's detail screen.
/// If the character is already known (passed from the list), it is used
/// directly. Otherwise, it is fetched from the repository by [id].
class CharacterDetailController extends ChangeNotifier {
  final CharacterRepository _repository;
  final int id;
  Character? character;

  CharacterDetailController(
    this._repository,
    this.id, {
    this.character,
  });

  /// Loads the character if it wasn't already provided.
  Future<void> load() async {
    if (character != null) return;

    final result = await _repository.getCharacter(id);
    if (result is Success<Character>) {
      character = result.value;
      notifyListeners();
    }
  }

  /// Toggles the favourite status of this character.
  /// Updates the UI immediately, then persists the change.
  Future<void> toggleFavourite() async {
    if (character == null) return;

    final updated = character!.copyWith(isFavourite: !character!.isFavourite);
    character = updated;
    notifyListeners();

    await _repository.toggleFavourite(updated);
  }
}
