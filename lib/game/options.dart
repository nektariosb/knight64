import 'package:shared_preferences/shared_preferences.dart';

import 'boards.dart';

/// Player options, saved on the device.
class Options {
  static const _pathAtEndKey = 'path_at_end';
  static const _pathWhilePlayingKey = 'path_while_playing';
  static const _highlightMovesKey = 'highlight_moves';
  static const _countExitsKey = 'count_exits';
  static const _markDeadKey = 'mark_dead';
  static const _checkFillableKey = 'check_fillable';
  static const _boardKey = 'board';
  static const _puzzleKey = 'puzzle';
  static const _dailyKey = 'daily';

  /// Id of the board to play on.
  String board = Board.standard.id;

  /// Id of the puzzle being played, or null when playing a plain board.
  String? puzzle;

  /// Playing the daily challenge: the app opens on today's.
  bool daily = false;

  /// Draw the knight's path when a game ends. Not a help: the game is over.
  bool pathAtEnd = true;

  /// Draw the knight's path during the game. Not a help: the numbers on the
  /// squares already show the route.
  bool pathWhilePlaying = false;

  /// Mark the squares the knight can jump to. A help.
  bool highlightMoves = false;

  /// On each square the knight can jump to, show how many jumps it would
  /// have from there. A help.
  bool countExits = false;

  /// Mark squares the knight can never reach again. A help.
  bool markDead = false;

  /// After every move, say whether the board can still be filled. A help.
  bool checkFillable = false;

  /// Whether any option that helps the player is on. Games played with help
  /// can't enter the high scores.
  bool get anyHelp => highlightMoves || countExits || markDead || checkFillable;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    pathAtEnd = prefs.getBool(_pathAtEndKey) ?? true;
    pathWhilePlaying = prefs.getBool(_pathWhilePlayingKey) ?? false;
    highlightMoves = prefs.getBool(_highlightMovesKey) ?? false;
    countExits = prefs.getBool(_countExitsKey) ?? false;
    markDead = prefs.getBool(_markDeadKey) ?? false;
    checkFillable = prefs.getBool(_checkFillableKey) ?? false;
    board = Board.byId(prefs.getString(_boardKey)).id;
    puzzle = prefs.getString(_puzzleKey);
    daily = prefs.getBool(_dailyKey) ?? false;
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pathAtEndKey, pathAtEnd);
    await prefs.setBool(_pathWhilePlayingKey, pathWhilePlaying);
    await prefs.setBool(_highlightMovesKey, highlightMoves);
    await prefs.setBool(_countExitsKey, countExits);
    await prefs.setBool(_markDeadKey, markDead);
    await prefs.setBool(_checkFillableKey, checkFillable);
    await prefs.setString(_boardKey, board);
    await prefs.setBool(_dailyKey, daily);
    if (puzzle case final id?) {
      await prefs.setString(_puzzleKey, id);
    } else {
      await prefs.remove(_puzzleKey);
    }
  }
}
