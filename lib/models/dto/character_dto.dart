/// Data Transfer Object that mirrors the raw JSON shape from the Rick & Morty API.
/// This is separate from the [Character] entity used in the UI — the mapper
/// converts between them. Keeping them separate means API changes don't
/// directly affect the rest of the app.
class CharacterDto {
  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String image;
  final String originName;
  final String locationName;

  const CharacterDto({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.image,
    required this.originName,
    required this.locationName,
  });

  /// Parses a JSON map (from the API response) into a [CharacterDto].
  /// The API nests `origin` and `location` as objects with a `name` field,
  /// so we extract just the name string.
  factory CharacterDto.fromJson(Map<String, dynamic> json) {
    final origin = json['origin'] as Map<String, dynamic>?;
    final location = json['location'] as Map<String, dynamic>?;

    return CharacterDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      species: (json['species'] as String?) ?? '',
      gender: (json['gender'] as String?) ?? '',
      image: (json['image'] as String?) ?? '',
      originName: (origin?['name'] as String?) ?? '',
      locationName: (location?['name'] as String?) ?? '',
    );
  }

  /// Converts this DTO back to JSON (used when saving to Hive cache).
  /// Reconstructs the nested `origin` and `location` objects.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'species': species,
        'gender': gender,
        'image': image,
        'origin': {'name': originName},
        'location': {'name': locationName},
      };
}
