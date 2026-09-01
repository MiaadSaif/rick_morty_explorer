import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_morty_explorer/app.dart';
import 'package:rick_morty_explorer/tools/network_info.dart';
import 'package:rick_morty_explorer/models/character_model.dart';
import 'package:rick_morty_explorer/modules/character_detail/character_detail_page.dart';

import 'fakes/fake_character_repository.dart';

/// Widget test: verifies that tapping a character in the list
/// navigates to the character detail screen.
void main() {
  testWidgets('Tapping a character opens the detail screen', (tester) async {
    // Set up a fake repository with one character.
    final repository = FakeCharacterRepository(
      characters: [
        const Character(
          id: 1,
          name: 'Rick Sanchez',
          status: 'Alive',
          species: 'Human',
          gender: 'Male',
          image: '', // Empty image to avoid network requests in tests.
          location: 'Earth',
          origin: 'Earth',
        ),
      ],
    );
    final networkInfo = NetworkInfoImpl(Connectivity());

    // Launch the app with the fake repository injected.
    await tester.pumpWidget(MyApp(
      repository: repository,
      networkInfo: networkInfo,
    ));
    await tester.pumpAndSettle();

    // The character name should appear in the list.
    expect(find.text('Rick Sanchez'), findsOneWidget);

    // Tap the character to open the detail screen.
    await tester.tap(find.text('Rick Sanchez'));
    await tester.pumpAndSettle();

    // Verify the detail screen is now showing.
    expect(find.byType(CharacterDetailScreen), findsOneWidget);
    expect(find.text('Rick Sanchez'), findsWidgets);
  });
}
