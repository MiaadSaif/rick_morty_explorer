import 'character_model.dart';

/// Holds a page of characters plus metadata about pagination and freshness.
class CharacterList {
  final List<Character> characters;
  final int total;
  final bool hasMore;
  final DateTime? fetchedAt;

  const CharacterList({
    required this.characters,
    required this.total,
    required this.hasMore,
    this.fetchedAt,
  });
}
