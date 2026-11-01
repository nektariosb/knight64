import 'package:shared_preferences/shared_preferences.dart';

import 'boards.dart';

/// A puzzle: a board where some squares already show their move number.
/// The player must find the tour that fits them; there is exactly one (see
/// test/puzzles_test.dart). The list is in puzzle_list.dart.
class Puzzle {
  /// A puzzle drawn as rows of text, one word per square: a number is a
  /// given square, `#` an empty square and `.` a hole of the board.
  Puzzle.drawn({
    required this.id,
    required String board,
    required List<String> rows,
  }) : board = Board.byId(board),
       clues = {
         for (var r = 0; r < rows.length; r++)
           for (final (c, word) in rows[r].trim().split(RegExp(r'\s+')).indexed)
             r * rows.length + c: ?int.tryParse(word),
       };

  /// Saved with the solved puzzles, so it must never change.
  final String id;
  final Board board;

  /// Square -> move number, flat indexes as in `KnightTour`.
  final Map<int, int> clues;
}

/// Which puzzles have been solved, saved on the device.
class PuzzleProgress {
  static const _key = 'puzzles_solved';

  Set<String> solved = {};

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    solved = (prefs.getStringList(_key) ?? []).toSet();
  }

  Future<void> markSolved(Puzzle puzzle) async {
    solved.add(puzzle.id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, solved.toList()..sort());
  }
}
