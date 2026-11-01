import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'boards.dart';

/// One finished game on the high score list.
class HighScore {
  const HighScore({
    required this.name,
    required this.squares,
    required this.closed,
    required this.undosUsed,
    required this.date,
  });

  factory HighScore.fromJson(Map<String, dynamic> json) => HighScore(
    name: json['name'] as String,
    squares: json['squares'] as int,
    closed: json['closed'] as bool,
    undosUsed: json['undosUsed'] as int,
    date: DateTime.parse(json['date'] as String),
  );

  final String name;

  /// Squares filled (the score).
  final int squares;

  /// Complete tour whose last square is a knight move from the first.
  final bool closed;

  final int undosUsed;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'name': name,
    'squares': squares,
    'closed': closed,
    'undosUsed': undosUsed,
    'date': date.toIso8601String(),
  };

  /// Better scores sort first: more squares, then closed tours, then fewer
  /// undos, then whoever got there first.
  static int compare(HighScore a, HighScore b) {
    if (a.squares != b.squares) return b.squares.compareTo(a.squares);
    if (a.closed != b.closed) return a.closed ? -1 : 1;
    if (a.undosUsed != b.undosUsed) return a.undosUsed.compareTo(b.undosUsed);
    return a.date.compareTo(b.date);
  }
}

/// Ranking rules for a list of at most [maxEntries] scores, kept sorted.
class HighScoreTable {
  HighScoreTable(List<HighScore> entries, {this.maxEntries = 10})
    : entries = [...entries]..sort(HighScore.compare);

  final int maxEntries;
  final List<HighScore> entries;

  /// Whether [score] would make it onto the list.
  bool qualifies(HighScore score) =>
      entries.length < maxEntries || HighScore.compare(score, entries.last) < 0;

  /// Adds [score] and returns its 1-based rank, or null if it didn't qualify.
  int? add(HighScore score) {
    if (!qualifies(score)) return null;
    entries
      ..add(score)
      ..sort(HighScore.compare);
    if (entries.length > maxEntries) entries.removeLast();
    return entries.indexOf(score) + 1;
  }
}

/// Saves a high score table per board, and the last entered name, on the
/// device. Boards are given by their id.
class HighScoreStore {
  static const _lastNameKey = 'last_name';

  /// 8x8 keeps the key from before there were other boards.
  static String _scoresKey(String board) =>
      board == Board.standard.id ? 'high_scores' : 'high_scores_$board';

  Future<HighScoreTable> load(String board) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scoresKey(board));
    if (raw == null) return HighScoreTable([]);
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => HighScore.fromJson(e as Map<String, dynamic>))
          .toList();
      return HighScoreTable(list);
    } on FormatException {
      return HighScoreTable([]);
    }
  }

  Future<void> save(String board, HighScoreTable table) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _scoresKey(board),
      jsonEncode([for (final e in table.entries) e.toJson()]),
    );
  }

  Future<void> clear(String board) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scoresKey(board));
  }

  Future<String> lastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastNameKey) ?? '';
  }

  Future<void> setLastName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastNameKey, name);
  }
}
