/// The main entity representing a Rick & Morty character.
/// This is the model used throughout the UI and business logic.
/// It is distinct from [CharacterDto] (the raw API shape) — see the mapper.
class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String image;
  final String location;
  final String origin;
  final bool isFavourite;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.image,
    required this.location,
    required this.origin,
    this.isFavourite = false,
  });

  /// Creates a [Character] from a JSON map (used when loading from Hive cache).
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      species: (json['species'] as String?) ?? '',
      gender: (json['gender'] as String?) ?? '',
      image: (json['image'] as String?) ?? '',
      location: (json['location'] as String?) ?? '',
      origin: (json['origin'] as String?) ?? '',
      isFavourite: (json['isFavourite'] as bool?) ?? false,
    );
  }

  /// Converts this character to a JSON map (used when saving to Hive cache).
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'species': species,
        'gender': gender,
        'image': image,
        'location': location,
        'origin': origin,
        'isFavourite': isFavourite,
      };

  /// Returns a copy of this character with the [isFavourite] field updated.
  /// Only [isFavourite] can change — all other fields are immutable.
  Character copyWith({
    bool? isFavourite,
  }) {
    return Character(
      id: id,
      name: name,
      status: status,
      species: species,
      gender: gender,
      image: image,
      location: location,
      origin: origin,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }
}