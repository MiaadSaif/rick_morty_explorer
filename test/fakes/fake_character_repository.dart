import 'package:rick_morty_explorer/tools/failures.dart';
import 'package:rick_morty_explorer/tools/result.dart';
import 'package:rick_morty_explorer/models/character_model.dart';
import 'package:rick_morty_explorer/models/character_list_model.dart';
import 'package:rick_morty_explorer/repositories/character_repository.dart';

/// A fake [CharacterRepository] for use in tests.
///
/// Simulates the real repository's behavior with in-memory data:
/// - [getCharacters] supports pagination and name filtering
/// - [getCharacter] returns a single character by ID
/// - [getFavouriteCharacters] returns the current favourites list
/// - [toggleFavourite] adds/removes from the favourites list
class FakeCharacterRepository implements CharacterRepository {
  final List<Character> _characters;
  final List<Character> _favourites;
  final Character? _single;
  final int pageSize;

  FakeCharacterRepository({
    List<Character>? characters,
    List<Character>? favourites,
    Character? single,
    this.pageSize = 20,
  })  : _characters = characters ?? [],
        _favourites = List.from(favourites ?? []),
        _single = single;

  @override
  Future<Result<CharacterList>> getCharacters({
    required int page,
    String? name,
  }) async {
    // Filter by name if a search query is provided.
    var filtered = _characters;
    if (name != null && name.isNotEmpty) {
      filtered = _characters
          .where((c) => c.name.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }

    // Calculate the start and end indices for this page.
    final startIndex = (page - 1) * pageSize;

    // If the start is beyond the list, return an empty page with hasMore=false.
    if (startIndex >= filtered.length) {
      return Success(
        CharacterList(
          characters: const [],
          total: filtered.length,
          hasMore: false,
          fetchedAt: DateTime.now(),
        ),
      );
    }

    // Calculate the end index, clamped to the list length.
    final endIndex = startIndex + pageSize > filtered.length
        ? filtered.length
        : startIndex + pageSize;

    final pageItems = filtered.sublist(startIndex, endIndex);

    return Success(
      CharacterList(
        characters: pageItems,
        total: filtered.length,
        hasMore: endIndex < filtered.length,
        fetchedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Result<Character>> getCharacter(int id) async {
    // If a single character was explicitly provided, always return it.
    if (_single != null) return Success(_single);

    // Otherwise, look it up in the character list.
    final index = _characters.indexWhere((c) => c.id == id);
    if (index == -1) {
      return const FailureResult(NotFoundFailure());
    }
    return Success(_characters[index]);
  }

  @override
  Future<Result<List<Character>>> getFavouriteCharacters() async {
    return Success(List.unmodifiable(_favourites));
  }

  @override
  Future<Result<void>> toggleFavourite(Character character) async {
    final index = _favourites.indexWhere((c) => c.id == character.id);

    if (index == -1) {
      // Not in favourites yet — add it.
      _favourites.add(character.copyWith(isFavourite: true));
    } else {
      // Already a favourite — remove it.
      _favourites.removeAt(index);
    }

    return const Success(null);
  }
}
