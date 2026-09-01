import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

export 'app.dart';

/// Entry point of the app.
///
/// Initializes Hive (local storage) and opens three boxes:
/// - 'listCache' — cached character list responses
/// - 'characterCache' — cached individual characters
/// - 'favourites' — favourite characters
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('listCache');
  await Hive.openBox<String>('characterCache');
  await Hive.openBox<String>('favourites');
  runApp(const MyApp());
}
