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
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Loads all favourite characters from local storage.
  Future<void> load() async {
    if (_disposed) return;
    isLoading = true;
    notifyListeners();

    final result = await _repository.getFavouriteCharacters();
    if (_disposed) return;

    if (result is Success<List<Character>>) {
      characters = result.value;
      failure = null;
    } else if (result is FailureResult<List<Character>>) {
      failure = result.failure;
    }

    isLoading = false;
    notifyListeners();
  }

  /// Toggles a character and keeps the shared favourites state current.
  Future<void> toggle(Character character) async {
    if (_disposed) return;
    final isCurrentlyFavourite = characters.any((c) => c.id == character.id);
    final updated = character.copyWith(isFavourite: !isCurrentlyFavourite);

    if (isCurrentlyFavourite) {
      characters.removeWhere((c) => c.id == character.id);
    } else {
      characters.add(updated);
    }
    notifyListeners();

    final result = await _repository.toggleFavourite(updated);
    if (result is FailureResult<void>) {
      if (isCurrentlyFavourite) {
        characters.add(character.copyWith(isFavourite: true));
      } else {
        characters.removeWhere((c) => c.id == character.id);
      }
      failure = result.error;
      notifyListeners();
    }
  }

  /// Removes a character from favourites and updates the visible list.
  Future<void> remove(Character character) => toggle(character);
}
