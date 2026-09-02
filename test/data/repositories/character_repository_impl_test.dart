import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:rick_morty_explorer/tools/network_info.dart';
import 'package:rick_morty_explorer/services/character_local_service.dart';
import 'package:rick_morty_explorer/api/character_api.dart';
import 'package:rick_morty_explorer/repositories/character_repository_impl.dart';
import 'package:rick_morty_explorer/models/character_list_model.dart';
import 'package:rick_morty_explorer/models/dto/character_dto.dart';
import 'package:rick_morty_explorer/models/dto/character_list_response_dto.dart';
import 'package:rick_morty_explorer/models/dto/info_dto.dart';
import 'package:rick_morty_explorer/tools/result.dart';

/// A fake [NetworkInfo] that always returns a fixed connectivity value.
/// Used to simulate online/offline scenarios in tests.
class FakeNetworkInfo implements NetworkInfo {
  final bool value;
  const FakeNetworkInfo(this.value);

  @override
  Future<bool> get isConnected async => value;

  @override
  Stream<bool> get onConnectivityChanged => const Stream<bool>.empty();
}

/// Unit tests for [CharacterRepositoryImpl].
///
/// Tests three scenarios:
/// 1. Successful API response (200) → returns characters
/// 2. Not found (404) → returns an empty list
/// 3. Server error (500) → returns a failure
void main() {
  late Directory tempDir;
  int boxIndex = 0;

  setUpAll(() async {
    // Use a temporary directory for Hive storage during tests.
    tempDir = Directory.systemTemp.createTempSync('rick_test');
    Hive.init(tempDir.path);
  });

  tearDownAll(() {
    Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  /// Creates a repository with a mock HTTP client and fresh Hive boxes.
  /// Each test gets its own boxes to avoid cross-test contamination.
  Future<CharacterRepositoryImpl> makeRepository(
    http_testing.MockClient client,
  ) async {
    boxIndex++;
    final listCache = await Hive.openBox<String>('listCache_$boxIndex');
    final characterCache = await Hive.openBox<String>(
      'characterCache_$boxIndex',
    );
    final favourites = await Hive.openBox<String>('favourites_$boxIndex');

    final local = CharacterLocalDataSource(
      listCache,
      characterCache,
      favourites,
    );
    final remote = CharacterRemoteDataSource(client: client);

    return CharacterRepositoryImpl(
      networkInfo: const FakeNetworkInfo(true),
      remote: remote,
      local: local,
    );
  }

  test('getCharacters returns data on a 200 response', () async {
    final client = http_testing.MockClient((request) async {
      return http.Response(
        jsonEncode({
          'info': {'count': 1, 'pages': 1, 'next': null, 'prev': null},
          'results': [
            {
              'id': 1,
              'name': 'Rick Sanchez',
              'status': 'Alive',
              'species': 'Human',
              'gender': 'Male',
              'image': '',
              'origin': {'name': 'Earth'},
              'location': {'name': 'Earth'},
            },
          ],
        }),
        200,
      );
    });

    final repository = await makeRepository(client);
    final result = await repository.getCharacters(page: 1);

    expect(result.isSuccess, isTrue);
    final list = (result as Success<CharacterList>).value;
    expect(list.characters.length, 1);
    expect(list.characters.first.name, 'Rick Sanchez');
  });

  test('getCharacters maps 404 to an empty list', () async {
    final client = http_testing.MockClient((request) async {
      return http.Response('Not found', 404);
    });

    final repository = await makeRepository(client);
    final result = await repository.getCharacters(page: 1, name: 'unknownxyz');

    expect(result.isSuccess, isTrue);
    final list = (result as Success<CharacterList>).value;
    expect(list.characters, isEmpty);
  });

  test('getCharacters returns a failure on a 500 response', () async {
    final client = http_testing.MockClient((request) async {
      return http.Response('Internal error', 500);
    });

    final repository = await makeRepository(client);
    final result = await repository.getCharacters(page: 1);

    expect(result.isFailure, isTrue);
  });

  test(
    'list cache keeps pages and never falls back to another query',
    () async {
      boxIndex++;
      final listCache = await Hive.openBox<String>('listCache_$boxIndex');
      final characterCache = await Hive.openBox<String>(
        'characterCache_$boxIndex',
      );
      final favourites = await Hive.openBox<String>('favourites_$boxIndex');
      final local = CharacterLocalDataSource(
        listCache,
        characterCache,
        favourites,
      );
      CharacterListResponseDto pageResponse(int id) => CharacterListResponseDto(
        info: const InfoDto(count: 2, pages: 2),
        results: [
          CharacterDto(
            id: id,
            name: 'Character $id',
            status: 'Alive',
            species: 'Human',
            gender: 'Male',
            image: '',
            originName: 'Earth',
            locationName: 'Earth',
          ),
        ],
      );

      await local.saveListCache(
        pageResponse(1),
        query: 'Rick',
        page: 1,
        fetchedAt: DateTime(2026),
      );
      await local.saveListCache(
        pageResponse(2),
        query: 'Rick',
        page: 2,
        fetchedAt: DateTime(2026),
      );

      expect(
        local.getListCache(query: 'rick', page: 1)?.response.results.first.id,
        1,
      );
      expect(
        local.getListCache(query: 'RICK', page: 2)?.response.results.first.id,
        2,
      );
      expect(local.getListCache(query: 'Morty', page: 1), isNull);
    },
  );
}
