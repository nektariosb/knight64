import 'package:flutter_test/flutter_test.dart';
import 'package:knight64/game/options.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults: path at the end on, no help', () async {
    final options = Options();
    await options.load();
    expect(options.pathAtEnd, isTrue);
    expect(options.pathWhilePlaying, isFalse);
    expect(options.anyHelp, isFalse);
    expect(options.board, '8x8');
  });

  test('a board that no longer exists falls back to 8x8', () async {
    SharedPreferences.setMockInitialValues({'board': '4x4'});
    final options = Options();
    await options.load();
    expect(options.board, '8x8');
  });

  test('saves and loads every option', () async {
    final options = Options()
      ..board = '6x6'
      ..pathAtEnd = false
      ..pathWhilePlaying = true
      ..highlightMoves = true
      ..countExits = true
      ..markDead = true
      ..checkFillable = true;
    await options.save();

    final loaded = Options();
    await loaded.load();
    expect(loaded.board, '6x6');
    expect(loaded.pathAtEnd, isFalse);
    expect(loaded.pathWhilePlaying, isTrue);
    expect(loaded.highlightMoves, isTrue);
    expect(loaded.countExits, isTrue);
    expect(loaded.markDead, isTrue);
    expect(loaded.checkFillable, isTrue);
  });

  test('only the help options count as help', () {
    final options = Options()
      ..pathAtEnd = true
      ..pathWhilePlaying = true;
    expect(options.anyHelp, isFalse);
    expect((Options()..highlightMoves = true).anyHelp, isTrue);
    expect((Options()..countExits = true).anyHelp, isTrue);
    expect((Options()..markDead = true).anyHelp, isTrue);
    expect((Options()..checkFillable = true).anyHelp, isTrue);
  });
}
