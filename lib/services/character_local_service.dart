import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../models/character_model.dart';
import '../models/dto/character_dto.dart';
import '../models/dto/character_list_response_dto.dart';
import 'list_cache.dart';

/// Local data source that reads/writes character data to Hive boxes.
/// Each box stores JSON strings. This provides offline caching.
class CharacterLocalDataSource {
  final Box<String> listCacheBox;
  final Box<String> characterBox;
  final Box<String> favouritesBox;

  CharacterLocalDataSource(
    this.listCacheBox,
    this.characterBox,
    this.favouritesBox,
  );

  // --- Key helpers ---
  // Keys are prefixed to avoid collisions within the same Hive box.

  String _listKey(String? query) => 'list_${query ?? ''}';
  String _characterKey(int id) => 'char_$id';
  String _favouriteKey(int id) => 'fav_$id';

  // --- Character list cache ---

  /// Saves a character list response to the cache, tagged by the search query.
  Future<void> saveListCache(
    CharacterListResponseDto response, {
    String? query,
    required DateTime fetchedAt,
  }) async {
    final cache = ListCache(
      query: query,
      response: response,
      fetchedAt: fetchedAt,
    );
    await listCacheBox.put(_listKey(query), jsonEncode(cache.toJson()));
  }

  /// Retrieves the cached list for the given query.
  /// If no exact match is found, returns the most recently fetched cache.
  ListCache? getListCache({String? query}) {
    // First, try to find an exact match for this query.
    final exactMatch = _getListCacheByKey(_listKey(query));
    if (exactMatch != null) return exactMatch;

    // No exact match — fall back to the most recently fetched cache.
    return _findMostRecentListCache();
  }

  /// Returns the timestamp of the most relevant cached list, or null if none.
  DateTime? getListCacheTimestamp({String? query}) {
    return getListCache(query: query)?.fetchedAt;
  }

  ListCache? _getListCacheByKey(String key) {
    final raw = listCacheBox.get(key);
    if (raw == null) return null;
    return _parseListCache(raw);
  }

  /// Scans all cached lists and returns the one with the latest [fetchedAt].
  ListCache? _findMostRecentListCache() {
    ListCache? mostRecent;
    for (final entry in listCacheBox.toMap().entries) {
      if (!entry.key.startsWith('list_')) continue;
      final cache = _parseListCache(entry.value);
      if (cache == null) continue;
      if (mostRecent == null || cache.fetchedAt.isAfter(mostRecent.fetchedAt)) {
        mostRecent = cache;
      }
    }
    return mostRecent;
  }

  /// Parses a JSON string into a [ListCache], or returns null on error.
  ListCache? _parseListCache(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return ListCache.fromJson(json);
    } on Exception catch (_) {
      return null;
    }
  }

  // --- Single character cache ---

  Future<void> saveCharacter(CharacterDto dto) async {
    await characterBox.put(_characterKey(dto.id), jsonEncode(dto.toJson()));
  }

  CharacterDto? getCharacter(int id) {
    final raw = characterBox.get(_characterKey(id));
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return CharacterDto.fromJson(json);
    } on Exception catch (_) {
      return null;
    }
  }

  // --- Favourites ---

  /// Toggles a character's favourite status in local storage.
  /// If the character is not yet a favourite, it is added.
  /// If it is already a favourite, it is removed.
  Future<void> toggleFavourite(Character character) async {
    final key = _favouriteKey(character.id);
    final existing = favouritesBox.get(key);
    if (existing == null) {
      await favouritesBox.put(key, jsonEncode(character.toJson()));
    } else {
      await favouritesBox.delete(key);
    }
  }

  /// Returns all favourite characters from local storage.
  List<Character> getFavouriteCharacters() {
    final favourites = <Character>[];
    for (final entry in favouritesBox.toMap().entries) {
      if (!entry.key.startsWith('fav_')) continue;
      try {
        final json = jsonDecode(entry.value) as Map<String, dynamic>;
        favourites.add(Character.fromJson(json));
      } on Exception catch (_) {
        // Skip corrupted entries rather than crashing.
        continue;
      }
    }
    return favourites;
  }
}
