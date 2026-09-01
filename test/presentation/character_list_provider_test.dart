import 'package:flutter_test/flutter_test.dart';
import 'package:rick_morty_explorer/controllers/character_list_controller.dart';
import 'package:rick_morty_explorer/models/character_model.dart';

import '../fakes/fake_character_repository.dart';

/// Unit tests for [CharacterListController].
///
/// Tests:
/// 1. Pagination: loadMore appends pages and stops when hasMore is false
/// 2. Search debounce: typing rapidly only triggers one search after 400ms
void main() {
  group('CharacterListController', () {
    test('loadMore appends the next page and stops at the end', () async {
      // Create 3 test characters with pageSize=1 so each page has 1 character.
      final characters = List.generate(
        3,
        (i) => Character(
          id: i,
          name: 'C$i',
          status: 'Alive',
          species: 'Human',
          gender: 'Male',
          image: '',
          location: 'Earth',
          origin: 'Earth',
        ),
      );
      final repo = FakeCharacterRepository(
        characters: characters,
        pageSize: 1,
      );
      final controller = CharacterListController(repo);

      // Initial load: should fetch page 1 (1 character).
      await controller.init();
      expect(controller.characters.length, 1);
      expect(controller.hasMore, isTrue);

      // Load page 2: should now have 2 characters.
      await controller.loadMore();
      expect(controller.characters.length, 2);

      // Load page 3: should now have 3 characters, no more pages.
      await controller.loadMore();
      expect(controller.characters.length, 3);
      expect(controller.hasMore, isFalse);

      // Attempt to load more: should do nothing (hasMore is false).
      await controller.loadMore();
      expect(controller.characters.length, 3);
    });

    test('search debounce waits before reloading', () async {
      final repo = FakeCharacterRepository(
        characters: [
          const Character(
            id: 1,
            name: 'Rick',
            status: 'Alive',
            species: 'Human',
            gender: 'Male',
            image: '',
            location: 'Earth',
            origin: 'Earth',
          ),
        ],
      );
      final controller = CharacterListController(repo);

      // Type rapidly: 'r' → 'ri' → 'ric'
      // The query state updates immediately, but the API call is debounced.
      controller.onSearchChanged('r');
      controller.onSearchChanged('ri');
      controller.onSearchChanged('ric');

      expect(controller.query, 'ric');
      expect(controller.characters, isEmpty);

      // Wait for the debounce timer to fire (600ms > 400ms).
      await Future<void>.delayed(const Duration(milliseconds: 600));

      // Now the last query ('ric') should have triggered a load.
      expect(controller.query, 'ric');
      expect(controller.characters.length, 1);
    });
  });
}
