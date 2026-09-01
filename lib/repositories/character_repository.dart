import '../tools/result.dart';
import '../models/character_model.dart';
import '../models/character_list_model.dart';

/// Abstract contract for character data operations.
/// The app depends on this interface, not the concrete implementation,
/// which makes it easy to swap or mock in tests.
abstract class CharacterRepository {
  /// Fetches a page of characters, optionally filtered by name.
  Future<Result<CharacterList>> getCharacters({
    required int page,
    String? name,
  });

  /// Fetches a single character by ID.
  Future<Result<Character>> getCharacter(int id);

  /// Returns all favourite characters from local storage.
  Future<Result<List<Character>>> getFavouriteCharacters();

  /// Toggles whether a character is in the favourites list.
  Future<Result<void>> toggleFavourite(Character character);
}
