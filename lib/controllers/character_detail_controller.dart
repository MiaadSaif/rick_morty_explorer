import 'package:flutter/material.dart';

import '../tools/failures.dart';
import '../tools/result.dart';
import '../models/character_model.dart';
import '../repositories/character_repository.dart';
import 'favourites_controller.dart';

/// Manages the state for a single character's detail screen.
/// If the character is already known (passed from the list), it is used
/// directly. Otherwise, it is fetched from the repository by [id].
class CharacterDetailController extends ChangeNotifier {
  final CharacterRepository _repository;
  final int id;
  final FavouritesController? _favouritesController;
  Character? character;
  Failure? failure;
  bool isLoading = false;
  bool _disposed = false;

  CharacterDetailController(
    this._repository,
    this.id, {
    this.character,
    FavouritesController? favouritesController, // this is optional, if not provided, the controller will not be able to sync favourite state
  }) : _favouritesController = favouritesController {
    _favouritesController?.addListener(_syncFavouriteState);  // this listener will update the UI when the favourite state changes
  }

  @override
  void dispose() {
    _disposed = true;
    _favouritesController?.removeListener(_syncFavouriteState); // this removes the listener to prevent memory leaks
    super.dispose();
  }

  /// Loads the character if it wasn't already provided.
  Future<void> load() async {
    if (_disposed || character != null) return;

    isLoading = true;
    failure = null;
    notifyListeners();
    final result = await _repository.getCharacter(id);
    if (_disposed) return;

    if (result is Success<Character>) {
      character = result.value;
    } else if (result is FailureResult<Character>) {
      failure = result.failure;
    }
    isLoading = false;
    notifyListeners();
  }

  void retry() {
    load();
  }

  /// Toggles the favourite status of this character.
  /// Updates the UI immediately, then persists the change.
  Future<void> toggleFavourite() async {
    final current = character;
    if (current == null) return;
    final updated = current.copyWith(isFavourite: !current.isFavourite);
    character = updated;
    if (!_disposed) notifyListeners();

    final favouritesController = _favouritesController;
    if (favouritesController != null) {
      await favouritesController.toggle(updated);
    } else {
      final result = await _repository.toggleFavourite(updated);
      if (result is FailureResult<void>) {
        character = current;
        if (!_disposed) notifyListeners();
      }
    }
  }

  void _syncFavouriteState() {
    final favouritesController = _favouritesController;
    final current = character;
    if (_disposed || current == null || favouritesController == null) return;
    final isFavourite = favouritesController.characters.any(
      (item) => item.id == id,
    );
    if (current.isFavourite == isFavourite) return;
    character = current.copyWith(isFavourite: isFavourite);
    notifyListeners();
  }
}
