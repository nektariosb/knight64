import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knight64/main.dart';
import 'package:knight64/ui/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('starts with an empty board and the start prompt', (
    tester,
  ) async {
    await tester.pumpWidget(Knight64App(themeController: ThemeController()));
    expect(find.text('Tap any square to start'), findsOneWidget);
    expect(find.text('Undo (3)'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('theme button switches between dark and light', (tester) async {
    final controller = ThemeController();
    await tester.pumpWidget(Knight64App(themeController: controller));
    expect(controller.value, ThemeMode.dark);

    await tester.tap(find.byTooltip('Light mode'));
    await tester.pumpAndSettle();
    expect(controller.value, ThemeMode.light);
    expect(find.byTooltip('Dark mode'), findsOneWidget);
  });

  testWidgets('sound button turns sound off and remembers it', (tester) async {
    await tester.pumpWidget(Knight64App(themeController: ThemeController()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Sound off'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Sound on'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('sound_on'), false);
  });
}
