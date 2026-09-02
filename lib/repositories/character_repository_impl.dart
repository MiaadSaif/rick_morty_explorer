import '../tools/failures.dart';
import '../tools/network_info.dart';
import '../tools/result.dart';
import '../models/character_model.dart';
import '../models/character_list_model.dart';
import 'character_repository.dart';
import '../api/character_api.dart';
import '../services/character_local_service.dart';
import '../models/dto/character_dto.dart';
import '../models/dto/character_list_response_dto.dart';
import '../models/mappers/character_mapper.dart';
import '../services/list_cache.dart';

/// Concrete implementation of [CharacterRepository].
///
/// Decides whether to fetch data from the remote API or local cache
/// based on network connectivity. When online, it fetches from the API
/// and saves to cache. When offline, it reads from cache.
class CharacterRepositoryImpl implements CharacterRepository {
  final NetworkInfo networkInfo;
  final CharacterRemoteDataSource remote;
  final CharacterLocalDataSource local;

  CharacterRepositoryImpl({
    required this.networkInfo,
    required this.remote,
    required this.local,
  });

  /// Returns the set of favourite character IDs from local storage.
  /// Used to merge the `isFavourite` flag into characters fetched from the API.
  Set<int> _favouriteIds() =>
      local.getFavouriteCharacters().map((e) => e.id).toSet();

  @override
  Future<Result<CharacterList>> getCharacters({
    required int page,
    String? name,
  }) async {
    final isOnline = await networkInfo.isConnected;

    if (isOnline) {
      return _getCharactersFromRemote(page: page, name: name);
    }

    // Offline: try to serve the exact requested page from cache.
    try {
      return await _getCharactersFromCache(page: page, name: name);
    } on Object {
      return const FailureResult(CacheFailure());
    }
  }

  @override
  Future<Result<Character>> getCharacter(int id) async {
    final isOnline = await networkInfo.isConnected;

    if (isOnline) {
      return _getCharacterFromRemote(id);
    }

    try {
      return await _getCharacterFromCache(id);
    } on Object {
      return const FailureResult(CacheFailure());
    }
  }

  @override
  Future<Result<List<Character>>> getFavouriteCharacters() async {
    try {
      return Success(local.getFavouriteCharacters());
    } on Object {
      return const FailureResult(CacheFailure());
    }
  }

  @override
  Future<Result<void>> toggleFavourite(Character character) async {
    try {
      await local.toggleFavourite(character);
      return const Success(null);
    } on Object {
      return const FailureResult(CacheFailure());
    }
  }

  // --- Private helpers for character list ---

  /// Fetches a character list from the remote API and caches the response.
  /// Falls back to cache if the remote request fails.
  Future<Result<CharacterList>> _getCharactersFromRemote({
    required int page,
    String? name,
  }) async {
    final remoteResult = await remote.getCharacters(page: page, name: name);

    if (remoteResult is Success<CharacterListResponseDto>) {
      final response = remoteResult.value;
      final fetchedAt = DateTime.now();

      // Save to cache so we can use it later when offline.
      try {
        await local.saveListCache(
          response,
          query: name,
          page: page,
          fetchedAt: fetchedAt,
        );
      } on Object {
        return const FailureResult(CacheFailure());
      }

      return _mapResponseToCharacterList(response, fetchedAt);
    }

    // Remote failed — try the exact requested page before giving up.
    try {
      final cache = local.getListCache(query: name, page: page);
      if (cache != null) return _mapCacheToCharacterList(cache);
    } on Object {
      return const FailureResult(CacheFailure());
    }

    return FailureResult(remoteResult.failure ?? const NetworkFailure());
  }

  /// Returns a cached character list, or a failure if no cache exists.
  Future<Result<CharacterList>> _getCharactersFromCache({
    required int page,
    String? name,
  }) async {
    final cache = local.getListCache(query: name, page: page);
    if (cache != null) return _mapCacheToCharacterList(cache);

    return const FailureResult(
      NetworkFailure('No internet and no cached data available.'),
    );
  }

  // --- Private helpers for single character ---

  /// Fetches a single character from the remote API and caches it.
  /// Falls back to cache if the remote request fails.
  Future<Result<Character>> _getCharacterFromRemote(int id) async {
    final remoteResult = await remote.getCharacter(id);

    if (remoteResult is Success<CharacterDto>) {
      final dto = remoteResult.value;
      try {
        await local.saveCharacter(dto);
      } on Object {
        return const FailureResult(CacheFailure());
      }
      return _mapDtoToCharacter(dto);
    }

    // Remote failed — try cache.
    final cached = local.getCharacter(id);
    if (cached != null) return _mapDtoToCharacter(cached);

    return FailureResult(remoteResult.failure ?? const NetworkFailure());
  }

  /// Returns a cached character, or a failure if no cache exists.
  Future<Result<Character>> _getCharacterFromCache(int id) async {
    final cached = local.getCharacter(id);
    if (cached != null) return _mapDtoToCharacter(cached);

    return const FailureResult(
      NetworkFailure('No internet and no cached character.'),
    );
  }

  // --- Mapping helpers ---

  /// Converts a DTO response into a [CharacterList] entity,
  /// merging the `isFavourite` flag from local storage.
  Result<CharacterList> _mapResponseToCharacterList(
    CharacterListResponseDto response,
    DateTime fetchedAt,
  ) {
    final favouriteIds = _favouriteIds();
    final characters = response.results
        .map((dto) => dto.toEntity(isFavourite: favouriteIds.contains(dto.id)))
        .toList();

    return Success(
      CharacterList(
        characters: characters,
        total: response.info.count,
        hasMore: response.info.next != null,
        fetchedAt: fetchedAt,
      ),
    );
  }

  /// Converts a cached [ListCache] into a [CharacterList] entity,
  /// merging the `isFavourite` flag from local storage.
  Result<CharacterList> _mapCacheToCharacterList(ListCache cache) {
    final favouriteIds = _favouriteIds();
    final characters = cache.response.results
        .map((dto) => dto.toEntity(isFavourite: favouriteIds.contains(dto.id)))
        .toList();

    return Success(
      CharacterList(
        characters: characters,
        total: cache.response.info.count,
        hasMore: cache.response.info.next != null,
        fetchedAt: cache.fetchedAt,
      ),
    );
  }

  /// Converts a single [CharacterDto] into a [Character] entity,
  /// merging the `isFavourite` flag from local storage.
  Result<Character> _mapDtoToCharacter(CharacterDto dto) {
    final favouriteIds = _favouriteIds();
    return Success(dto.toEntity(isFavourite: favouriteIds.contains(dto.id)));
  }
}
