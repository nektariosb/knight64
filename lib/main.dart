import 'package:flutter/material.dart';

import 'ui/game_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = await ThemeController.load();
  runApp(KnightsTourApp(themeController: themeController));
}

class KnightsTourApp extends StatelessWidget {
  const KnightsTourApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeController,
      builder: (context, mode, _) => MaterialApp(
        title: "Knight's Tour",
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: mode,
        home: GameScreen(themeController: themeController),
      ),
    );
  }
}
