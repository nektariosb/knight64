import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:knight64/game/high_scores.dart';
import 'package:shared_preferences/shared_preferences.dart';

var _clock = DateTime(2026, 1, 1);

HighScore score(
  int squares, {
  String name = 'A',
  bool closed = false,
  int undos = 0,
}) {
  _clock = _clock.add(const Duration(minutes: 1));
  return HighScore(
    name: name,
    squares: squares,
    closed: closed,
    undosUsed: undos,
    date: _clock,
  );
}

void main() {
  test('ranks by squares, then closed, then fewer undos, then earlier', () {
    final early = score(64, name: 'early', undos: 1);
    final late = score(64, name: 'late', undos: 1);
    final table = HighScoreTable([
      score(30, name: 'short'),
      late,
      score(64, name: 'clean'),
      score(64, name: 'closed', closed: true, undos: 3),
      early,
    ]);
    expect(table.entries.map((e) => e.name), [
      'closed',
      'clean',
      'early',
      'late',
      'short',
    ]);
  });

  test('keeps only the best entries and reports the rank', () {
    final table = HighScoreTable([for (var i = 0; i < 10; i++) score(20 + i)]);
    expect(table.qualifies(score(20)), isFalse);
    expect(table.add(score(10)), isNull);

    expect(table.add(score(25, name: 'new')), 6);
    expect(table.entries, hasLength(10));
    expect(table.entries.last.squares, 21);
  });

  test('store round-trips scores and the last name', () async {
    SharedPreferences.setMockInitialValues({});
    final store = HighScoreStore();

    final table = await store.load('8x8');
    expect(table.entries, isEmpty);
    table.add(score(42, name: 'Ana', closed: false, undos: 2));
    await store.save('8x8', table);
    await store.setLastName('Ana');

    final loaded = await store.load('8x8');
    expect(loaded.entries.single.name, 'Ana');
    expect(loaded.entries.single.squares, 42);
    expect(loaded.entries.single.undosUsed, 2);
    expect(await store.lastName(), 'Ana');

    await store.clear('8x8');
    expect((await store.load('8x8')).entries, isEmpty);
  });

  test('each board has its own list; 8x8 keeps the old one', () async {
    final old = jsonEncode([score(50, name: 'Old').toJson()]);
    SharedPreferences.setMockInitialValues({'high_scores': old});
    final store = HighScoreStore();
    expect((await store.load('8x8')).entries.single.name, 'Old');
    expect((await store.load('6x6')).entries, isEmpty);

    await store.save('6x6', HighScoreTable([score(36, name: 'Six')]));
    expect((await store.load('6x6')).entries.single.name, 'Six');
    await store.clear('6x6');
    expect((await store.load('8x8')).entries.single.name, 'Old');
  });
}
