import 'character_dto.dart';
import 'info_dto.dart';

/// Wraps the full API response for a character list request.
/// Contains pagination [info] and the list of [results] (character DTOs).
class CharacterListResponseDto {
  final InfoDto info;
  final List<CharacterDto> results;

  const CharacterListResponseDto({
    required this.info,
    required this.results,
  });

  factory CharacterListResponseDto.fromJson(Map<String, dynamic> json) {
    final infoJson = json['info'] as Map<String, dynamic>?;
    final resultsJson = json['results'] as List<dynamic>?;

    return CharacterListResponseDto(
      info: infoJson == null
          ? const InfoDto(count: 0, pages: 0)
          : InfoDto.fromJson(infoJson),
      results: resultsJson
              ?.map((e) => CharacterDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'info': info.toJson(),
        'results': results.map((e) => e.toJson()).toList(),
      };
}
