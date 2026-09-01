import 'package:flutter/material.dart';

import '../tools/failures.dart';
import '../tools/result.dart';
import '../models/character_model.dart';
import '../repositories/character_repository.dart';

/// Manages the list of favourite characters.
/// Loads favourites from local storage and allows removing them.
class FavouritesController extends ChangeNotifier {
  final CharacterRepository _repository;

  FavouritesController(this._repository);

  List<Character> characters = [];
  bool isLoading = false;
  Failure? failure;

  /// Loads all favourite characters from local storage.
  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    final result = await _repository.getFavouriteCharacters();

    if (result is Success<List<Character>>) {
      characters = result.value;
      failure = null;
    } else if (result is FailureResult<List<Character>>) {
      failure = result.failure;
    }

    isLoading = false;
    notifyListeners();
  }

  /// Removes a character from favourites by toggling its favourite status.
  /// Updates the UI immediately, then persists the change.
  Future<void> remove(Character character) async {
    final updated = character.copyWith(isFavourite: !character.isFavourite);
    final index = characters.indexWhere((c) => c.id == updated.id);

    if (index != -1) {
      characters[index] = updated;
      notifyListeners();
    }

    await _repository.toggleFavourite(updated);
  }
}
