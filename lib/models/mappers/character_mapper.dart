import '../character_model.dart';
import '../dto/character_dto.dart';

/// Extension on [CharacterDto] that converts it to the [Character] entity.
/// This is the bridge between the data layer (DTO) and the domain layer (entity).
/// The [isFavourite] flag comes from local storage, not the API.
extension CharacterDtoMapper on CharacterDto {
  Character toEntity({bool isFavourite = false}) {
    return Character(
      id: id,
      name: name,
      status: status,
      species: species,
      gender: gender,
      image: image,
      origin: originName,
      location: locationName,
      isFavourite: isFavourite,
    );
  }
}
