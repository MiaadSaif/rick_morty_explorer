import 'dart:async';

import 'package:flutter/material.dart';

import '../tools/failures.dart';
import '../tools/result.dart';
import '../models/character_model.dart';
import '../models/character_list_model.dart';
import '../repositories/character_repository.dart';

/// Manages the state for the character list screen.
///
/// Responsibilities:
/// - Loading characters with pagination
/// - Debounced search (waits 400ms before firing a new search)
/// - Pull-to-refresh
/// - Toggling favourites
/// - Error handling with retry
///
/// Extends [ChangeNotifier] so Provider can rebuild the UI when state changes.
class CharacterListController extends ChangeNotifier {
  final CharacterRepository _repository;

  CharacterListController(this._repository);

  // --- Public state (read by the UI) ---

  List<Character> characters = [];
  bool isLoadingInitial = false;
  bool isLoadingMore = false;
  Failure? failure;
  String query = '';
  DateTime? lastUpdated;
  bool hasMore = true;

  // --- Private state ---

  int _currentPage = 1;
  Timer? _debounce;
  bool _isFetching = false;

  // Tracks the most recent load() call so retry() can repeat it exactly,
  // including whether it was a replace (page 1) or an append (pagination).
  int _lastRequestedPage = 1;
  bool _lastRequestedReplace = true;

  // --- Lifecycle ---

  /// Called on startup to load the first page.
  Future<void> init() => load(page: 1, replace: true);

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // --- Search ---

  /// Updates the search query immediately, but debounces the API request.
  ///
  /// This means the UI can reflect the current query right away,
  /// while the actual network call only fires 400ms after the user
  /// stops typing. The stale-query guard in [load] discards any
  /// response that no longer matches the current query.
  void onSearchChanged(String value) {
    query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      load(page: 1, replace: true);
    });
  }

  // --- Pagination ---

  /// Loads the next page of characters (called when scrolling near the bottom).
  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore || _isFetching) return;
    await load(page: _currentPage + 1, replace: false);
  }

  // --- Refresh & retry ---

  /// Pull-to-refresh: reloads the first page.
  Future<void> refresh() => load(page: 1, replace: true);

  /// Retries the last request (initial, search, or pagination).
  /// Preserves whether the failed request was a replace or an append,
  /// so the existing list is not thrown away when a load-more fails.
  void retry() => load(
        page: _lastRequestedPage,
        replace: _lastRequestedReplace,
      );

  // --- Core load method ---

  /// Fetches a page of characters from the repository.
  ///
  /// [replace] = true  → replaces the entire list (used for search/refresh)
  /// [replace] = false → appends to the existing list (used for pagination)
  Future<void> load({required int page, bool replace = false}) async {
    // Guard against concurrent fetches.
    if (_isFetching) return;
    _isFetching = true;

    // Remember this request so retry() can repeat it correctly.
    _lastRequestedPage = page;
    _lastRequestedReplace = replace;

    // Capture the current query so we can detect if it changed during the
    // async operation (e.g. the user typed more characters while loading).
    final requestQuery = query;

    _setLoadingState(replace: replace);
    notifyListeners();

    try {
      final name = requestQuery.isEmpty ? null : requestQuery;
      final result = await _repository.getCharacters(page: page, name: name);

      // If the search query changed while we were loading, discard the result.
      if (requestQuery != query) return;

      _handleResult(result, page: page, replace: replace);
    } finally {
      _resetLoadingState();
      _isFetching = false;
      notifyListeners();
    }
  }

  // --- Favourites ---

  /// Toggles the favourite status of a character in the list.
  /// Updates the UI immediately, then persists the change.
  Future<void> toggleFavourite(Character character) async {
    final updated = character.copyWith(isFavourite: !character.isFavourite);
    final index = characters.indexWhere((c) => c.id == character.id);
    if (index != -1) {
      characters[index] = updated;
      notifyListeners();
    }
    await _repository.toggleFavourite(updated);
  }

  // --- Private helpers ---

  /// Sets the appropriate loading flag based on whether this is a
  /// replace (first page) or append (pagination).
  void _setLoadingState({required bool replace}) {
    if (replace) {
      isLoadingInitial = true;
      failure = null;
    } else {
      isLoadingMore = true;
    }
  }

  /// Resets both loading flags to false.
  void _resetLoadingState() {
    isLoadingInitial = false;
    isLoadingMore = false;
  }

  /// Processes the [Result] from the repository and updates state.
  void _handleResult(
    Result<CharacterList> result, {
    required int page,
    required bool replace,
  }) {
    if (result is Success<CharacterList>) {
      final list = result.value;

      if (replace) {
        characters = list.characters;
      } else {
        characters.addAll(list.characters);
      }

      hasMore = list.hasMore;
      _currentPage = page;
      lastUpdated = list.fetchedAt;
      failure = null;
    } else if (result is FailureResult<CharacterList>) {
      failure = result.failure;
    }
  }
}
