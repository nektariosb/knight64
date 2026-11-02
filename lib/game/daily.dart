import 'package:shared_preferences/shared_preferences.dart';

import 'boards.dart';

/// The challenge of one day: a board and the square to start on, picked
/// from the date, so every device gets the same one. Small boards early in
/// the week, big ones at the weekend.
class DailyChallenge {
  DailyChallenge._(this.date, this.board, this.start);

  /// The challenge of the day [date] falls on. Its time is ignored.
  factory DailyChallenge.on(DateTime date) {
    final day = DateTime.utc(date.year, date.month, date.day);
    final days = day.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
    final boards = boardsOn(day.weekday);
    final pick = _mix(days);
    final board = boards[pick % boards.length];
    final starts = [
      for (var i = 0; i < board.size * board.size; i++)
        if (board.canStartAt(i)) i,
    ];
    return DailyChallenge._(day, board, starts[_mix(pick) % starts.length]);
  }

  factory DailyChallenge.today() => DailyChallenge.on(DateTime.now());

  /// The day, as midnight UTC.
  final DateTime date;
  final Board board;

  /// Flat index of the square to start on.
  final int start;

  /// Saved with the results, so it must never change.
  String get id => dayId(date);

  /// '2026-11-02' for any time on that day.
  static String dayId(DateTime date) =>
      '${date.year}-${_two(date.month)}-${_two(date.day)}';

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// The boards a challenge may use on [weekday]. Changing this changes the
  /// challenge of past days too; the results keep their own total, so the
  /// calendar stays right.
  static List<Board> boardsOn(int weekday) => switch (weekday) {
    DateTime.monday || DateTime.tuesday => [
      for (final b in Board.sizes)
        if (b.size == 5 || b.size == 6) b,
    ],
    DateTime.wednesday || DateTime.thursday => [Board.standard],
    DateTime.friday => [
      for (final b in Board.shapes)
        if (b.size == 8) b,
    ],
    _ => [
      for (final b in Board.all)
        if (b.size == 10) b,
    ],
  };

  /// Scrambles [x] into a number from 0 to 2^32 - 1 (MurmurHash3's final
  /// mix). Every step stays within 32 bits or exact doubles, so the web gets
  /// the same numbers as phones.
  static int _mix(int x) {
    var h = x & 0xFFFFFFFF;
    h ^= h >>> 16;
    h = _times(h, 0x85EBCA6B);
    h ^= h >>> 13;
    h = _times(h, 0xC2B2AE35);
    h ^= h >>> 16;
    return h;
  }

  /// [a] * [b], keeping the lowest 32 bits, in two halves so no product
  /// goes past 2^48.
  static int _times(int a, int b) {
    final low = (a & 0xFFFF) * b;
    final high = (((a >>> 16) * b) & 0xFFFF) << 16;
    return (low + high) & 0xFFFFFFFF;
  }
}

/// How far the best game of a day got.
class DayResult {
  const DayResult(this.squares, this.total);

  final int squares;
  final int total;

  bool get filled => squares == total;
}

/// The best game of each day's challenge, saved on the device. Games played
/// with help don't count.
class DailyResults {
  static const _key = 'daily_best';

  /// Day id (see [DailyChallenge.id]) -> best result that day.
  Map<String, DayResult> best = {};

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    best = {
      for (final entry in prefs.getStringList(_key) ?? <String>[])
        if (entry.split(' ') case [final day, final squares, final total])
          day: DayResult(int.parse(squares), int.parse(total)),
    };
  }

  /// Counts a game of [challenge] that got to [squares]. Returns the best
  /// result of that day before this game, or null if it's the first.
  DayResult? record(DailyChallenge challenge, int squares) {
    final before = best[challenge.id];
    if (before == null || squares > before.squares) {
      best[challenge.id] = DayResult(squares, challenge.board.total);
      _save();
    }
    return before;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      [
        for (final MapEntry(key: day, value: result) in best.entries)
          '$day ${result.squares} ${result.total}',
      ]..sort(),
    );
  }
}
