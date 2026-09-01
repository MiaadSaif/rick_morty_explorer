import '../models/dto/character_list_response_dto.dart';

/// Wraps a cached character list response along with the search query
/// that produced it and the time it was fetched. Used for offline support.
class ListCache {
  final String? query;
  final CharacterListResponseDto response;
  final DateTime fetchedAt;

  const ListCache({
    required this.query,
    required this.response,
    required this.fetchedAt,
  });

  factory ListCache.fromJson(Map<String, dynamic> json) {
    return ListCache(
      query: json['query'] as String?,
      response: CharacterListResponseDto.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'query': query,
        'response': response.toJson(),
        'fetchedAt': fetchedAt.toIso8601String(),
      };
}
