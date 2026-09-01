import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../tools/failures.dart';
import '../tools/result.dart';
import '../models/dto/character_dto.dart';
import '../models/dto/character_list_response_dto.dart';
import '../models/dto/info_dto.dart';

/// Remote data source that talks to the Rick & Morty REST API.
/// Returns [Result] objects so callers don't need to worry about exceptions.
class CharacterRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  CharacterRemoteDataSource({
    required this.client,
    this.baseUrl = 'https://rickandmortyapi.com/api',
  });

  /// Fetches a page of characters, optionally filtered by [name].
  Future<Result<CharacterListResponseDto>> getCharacters({
    required int page,
    String? name,
  }) async {
    try {
      final uri = _buildCharacterListUri(page: page, name: name);
      final response = await client.get(uri);
      return _parseCharacterListResponse(response);
    } on SocketException catch (_) {
      return const FailureResult(NetworkFailure());
    } on FormatException catch (_) {
      return const FailureResult(ParsingFailure());
    } on Exception catch (e) {
      return FailureResult(NetworkFailure(e.toString()));
    }
  }

  /// Fetches a single character by [id].
  Future<Result<CharacterDto>> getCharacter(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/character/$id');
      final response = await client.get(uri);
      return _parseSingleCharacterResponse(response);
    } on SocketException catch (_) {
      return const FailureResult(NetworkFailure());
    } on FormatException catch (_) {
      return const FailureResult(ParsingFailure());
    } on Exception catch (e) {
      return FailureResult(NetworkFailure(e.toString()));
    }
  }

  // --- Private helpers ---

  /// Builds the request URI for the character list endpoint with query params.
  Uri _buildCharacterListUri({required int page, String? name}) {
    final queryParams = <String, String>{'page': '$page'};
    if (name != null && name.isNotEmpty) {
      queryParams['name'] = name;
    }
    return Uri.parse('$baseUrl/character').replace(queryParameters: queryParams);
  }

  /// Parses the HTTP response for a character list request.
  Result<CharacterListResponseDto> _parseCharacterListResponse(
    http.Response response,
  ) {
    // A 404 means no characters matched the search — return an empty list.
    if (response.statusCode == 404) {
      return const Success(
        CharacterListResponseDto(
          info: InfoDto(count: 0, pages: 0),
          results: <CharacterDto>[],
        ),
      );
    }

    if (_isErrorStatus(response.statusCode)) {
      return FailureResult(
        ServerFailure('Request failed with status ${response.statusCode}'),
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return Success(CharacterListResponseDto.fromJson(json));
  }

  /// Parses the HTTP response for a single character request.
  Result<CharacterDto> _parseSingleCharacterResponse(
    http.Response response,
  ) {
    if (response.statusCode == 404) {
      return const FailureResult(NotFoundFailure('Character not found.'));
    }

    if (_isErrorStatus(response.statusCode)) {
      return FailureResult(
        ServerFailure('Request failed with status ${response.statusCode}'),
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return Success(CharacterDto.fromJson(json));
  }

  /// Returns true if the status code is outside the 2xx success range.
  bool _isErrorStatus(int statusCode) {
    return statusCode < 200 || statusCode >= 300;
  }
}
