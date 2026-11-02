import 'package:flutter_test/flutter_test.dart';
import 'package:knight64/game/boards.dart';
import 'package:knight64/game/daily.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Every day of two years, from a Monday.
  final days = [for (var i = 0; i < 730; i++) DateTime(2026, 11, 2 + i)];

  test('the same day gives the same challenge, whatever the time', () {
    final morning = DailyChallenge.on(DateTime(2026, 11, 2, 0, 1));
    final night = DailyChallenge.on(DateTime(2026, 11, 2, 23, 59));
    expect(night.id, '2026-11-02');
    expect(night.board, morning.board);
    expect(night.start, morning.start);
  });

  // If this breaks, every day's challenge has changed: on the web too, or
  // only on some devices? It should never happen by accident.
  test('pinned week', () {
    expect(
      [
        for (final day in days.take(7))
          '${DailyChallenge.on(day).board.id} ${DailyChallenge.on(day).start}',
      ],
      [
        '6x6 30',
        '6x6 1',
        '8x8 55',
        '8x8 4',
        'cross 58',
        'frame 22',
        'diamond 37',
      ],
    );
  });

  test('small boards early in the week, big ones at the weekend', () {
    for (final day in days) {
      final challenge = DailyChallenge.on(day);
      final size = challenge.board.size;
      final expected = switch (day.weekday) {
        DateTime.monday || DateTime.tuesday => [5, 6],
        DateTime.wednesday || DateTime.thursday || DateTime.friday => [8],
        _ => [10],
      };
      expect(expected, contains(size), reason: challenge.id);
      // Wednesday and Thursday play the plain 8x8, Friday a shape.
      if (size == 8) {
        expect(
          challenge.board.holes.isNotEmpty,
          day.weekday == DateTime.friday,
          reason: challenge.id,
        );
      }
    }
  });

  test('a tour can start on the start square, and every board comes up', () {
    final seen = <String>{};
    for (final day in days) {
      final challenge = DailyChallenge.on(day);
      expect(challenge.board.canStartAt(challenge.start), isTrue);
      seen.add(challenge.board.id);
    }
    final used = {
      for (var weekday = 1; weekday <= 7; weekday++)
        for (final board in DailyChallenge.boardsOn(weekday)) board.id,
    };
    expect(seen, used);
    expect(used, isNot(contains('3x3')));
    expect(used, contains(Board.standard.id));
  });

  test('start squares are spread over the board', () {
    final starts = {
      for (final day in days)
        if (day.weekday == DateTime.wednesday ||
            day.weekday == DateTime.thursday)
          DailyChallenge.on(day).start,
    };
    // 208 days on 8x8: most of the 64 squares should come up.
    expect(starts.length, greaterThan(50));
  });

  test('keeps the best game of each day', () async {
    final results = DailyResults();
    final monday = DailyChallenge.on(DateTime(2026, 11, 2));
    final total = monday.board.total;
    expect(results.record(monday, 10), isNull);
    expect(results.record(monday, 7)?.squares, 10);
    expect(results.record(monday, 12)?.squares, 10);
    expect(results.best[monday.id]?.squares, 12);
    expect(results.best[monday.id]?.filled, isFalse);
    expect(results.record(monday, total)?.squares, 12);
    expect(results.best[monday.id]?.filled, isTrue);
    await Future<void>.delayed(Duration.zero);

    final loaded = DailyResults();
    await loaded.load();
    expect(loaded.best.keys, [monday.id]);
    expect(loaded.best[monday.id]?.squares, total);
    expect(loaded.best[monday.id]?.total, total);
  });
}
