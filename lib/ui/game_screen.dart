import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/high_scores.dart';
import '../game/knight_tour.dart';
import '../game/options.dart';
import '../game/solver.dart';
import 'board_view.dart';
import 'high_scores_screen.dart';
import 'info_screen.dart';
import 'options_sheet.dart';
import 'save_score_dialog.dart';
import 'sounds.dart';
import 'theme.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _game = KnightTour();
  final _sounds = Sounds();
  final _store = HighScoreStore();
  final _options = Options();
  int? _rejectedIndex;
  Timer? _flashTimer;

  /// Opens the save dialog once the path has finished drawing.
  Timer? _saveTimer;

  /// Once saved, the game is locked so the same game can't be saved twice.
  bool _scoreSaved = false;

  /// The save dialog pops up once per game over; after that the player uses
  /// the "Save score" button.
  bool _gameOverShown = false;

  /// A help option was on during this game, even if it was turned off again.
  /// Such games can't enter the high scores.
  bool _helped = false;

  /// Answer of the "can the board still be filled" check, or null while it
  /// runs or when it's off.
  Fillable? _fillable;

  /// Only one check runs at a time. If the board changes meanwhile, it runs
  /// again for the new board when done.
  bool _checking = false, _recheck = false;

  bool get _canUndo => _game.canUndo && !_scoreSaved;

  bool get _showFillable =>
      _options.checkFillable && _game.moveCount > 0 && !_game.isOver;

  /// Starts the fill check in the background, if it's on. Call it whenever
  /// the board or the options change.
  void _checkFillable() {
    _fillable = null;
    if (_checking) {
      _recheck = true;
      return;
    }
    if (!_showFillable) return;
    _checking = true;
    _recheck = false;
    compute(canFill, (
      size: _game.size,
      visited: [
        for (var i = 0; i < _game.squareCount; i++) _game.numberAt(i) > 0,
      ],
      current: _game.current!,
      // The web has no background threads, so keep the check short there.
      maxSteps: kIsWeb ? 30000 : 200000,
    )).then((result) {
      _checking = false;
      if (!mounted) return;
      setState(() {
        if (_recheck) {
          _checkFillable();
        } else {
          _fillable = result;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _sounds.load().then((_) {
      if (mounted) setState(() {});
    });
    _options.load().then((_) {
      if (mounted) setState(_checkFillable);
    });
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    _saveTimer?.cancel();
    _sounds.dispose();
    super.dispose();
  }

  void _onSquareTap(int index) {
    if (_game.tryMove(index)) {
      _sounds.move();
      setState(() {
        _helped |= _options.anyHelp;
        _checkFillable();
      });
      if (_game.isOver && !_gameOverShown) {
        _gameOverShown = true;
        // Waits for the path to draw, unless it was already on the board.
        _saveTimer = Timer(
          _options.pathAtEnd && !_options.pathWhilePlaying
              ? BoardView.pathDrawTime(_game.moveCount) +
                    const Duration(milliseconds: 500)
              : Duration.zero,
          _offerSave,
        );
      }
      return;
    }
    _sounds.reject();
    HapticFeedback.heavyImpact();
    _flashTimer?.cancel();
    setState(() => _rejectedIndex = index);
    _flashTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _rejectedIndex = null);
    });
  }

  void _undo() => setState(() {
    _saveTimer?.cancel();
    _game.undo();
    _gameOverShown = false;
    _checkFillable();
  });

  void _restart() => setState(() {
    _saveTimer?.cancel();
    _game.restart();
    _scoreSaved = false;
    _gameOverShown = false;
    _helped = false;
    _checkFillable();
  });

  void _openOptions() {
    showModalBottomSheet<void>(
      context: context,
      // Lets the sheet grow past half the screen to fit every option.
      isScrollControlled: true,
      builder: (_) => OptionsSheet(
        options: _options,
        onChanged: () => setState(() {
          // Turning help on mid-game counts, even without making a move.
          if (_options.anyHelp && _game.moveCount > 0 && !_game.isOver) {
            _helped = true;
          }
          _checkFillable();
        }),
      ),
    );
  }

  HighScore _score(String name) => HighScore(
    name: name,
    squares: _game.moveCount,
    closed: _game.isClosed,
    undosUsed: _game.undosUsed,
    date: DateTime.now(),
  );

  Future<void> _offerSave() async {
    _saveTimer?.cancel();
    final table = await _store.load();
    final lastName = await _store.lastName();
    if (!mounted) return;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => SaveScoreDialog(
        squares: _game.moveCount,
        total: _game.squareCount,
        closed: _game.isClosed,
        helped: _helped,
        qualifies: !_helped && table.qualifies(_score('')),
        canUndo: _canUndo,
        initialName: lastName,
      ),
    );
    if (name == null) return;
    final rank = table.add(_score(name));
    await _store.save(table);
    await _store.setLastName(name);
    if (!mounted) return;
    setState(() => _scoreSaved = true);
    _openHighScores(highlightRank: rank);
  }

  void _openHighScores({int? highlightRank}) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => HighScoresScreen(
          store: _store,
          total: _game.squareCount,
          highlightRank: highlightRank,
        ),
      ),
    );
  }

  /// Button label that shrinks instead of overflowing on narrow screens.
  static Widget _fit(String text) =>
      FittedBox(fit: BoxFit.scaleDown, child: Text(text, maxLines: 1));

  String get _status {
    if (_game.isComplete) {
      return _game.isClosed
          ? 'Closed tour! All ${_game.squareCount} squares'
          : 'Tour complete! All ${_game.squareCount} squares';
    }
    if (_game.isStuck) {
      return 'No moves left: ${_game.moveCount} / ${_game.squareCount}';
    }
    if (_game.moveCount == 0) return 'Tap any square to start';
    return 'Move ${_game.moveCount} / ${_game.squareCount}';
  }

  /// Small icon and text for the line under the status.
  static List<Widget> _note(
    ThemeData theme,
    IconData icon,
    String text, [
    Color? color,
  ]) {
    color ??= theme.colorScheme.outline;
    return [
      Icon(icon, size: 16, color: color),
      Text(text, style: theme.textTheme.bodySmall?.copyWith(color: color)),
    ];
  }

  List<Widget> _fillableNote(ThemeData theme) => switch (_fillable) {
    null => _note(theme, Icons.hourglass_empty, 'Checking…'),
    Fillable.yes => _note(
      theme,
      Icons.check_circle_outline,
      'Can still be filled',
      theme.colorScheme.primary,
    ),
    Fillable.no => _note(
      theme,
      Icons.cancel_outlined,
      "Can't be filled anymore",
      theme.colorScheme.error,
    ),
    Fillable.unknown => _note(theme, Icons.help_outline, 'Hard to tell'),
  };

  /// "Playing with help", plus the fill check's answer when that's on.
  Widget? _helpNote(ThemeData theme) {
    if (!_helped) return null;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        spacing: 4,
        children: [
          ..._note(theme, Icons.lightbulb_outline, 'Playing with help'),
          if (_showFillable) ...[
            const SizedBox(width: 4),
            ..._fillableNote(theme),
          ],
        ],
      ),
    );
  }

  /// The icon buttons under the board, spread evenly.
  Widget _toolbar() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      IconButton(
        tooltip: widget.themeController.isDark ? 'Light mode' : 'Dark mode',
        icon: Icon(
          widget.themeController.isDark
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
        ),
        onPressed: widget.themeController.toggle,
      ),
      IconButton(
        tooltip: _sounds.enabled ? 'Sound off' : 'Sound on',
        icon: Icon(
          _sounds.enabled
              ? Icons.volume_up_outlined
              : Icons.volume_off_outlined,
        ),
        onPressed: () async {
          await _sounds.toggle();
          if (mounted) setState(() {});
        },
      ),
      IconButton(
        tooltip: "About the Knight's Tour",
        icon: const Icon(Icons.info_outline),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const InfoScreen()),
        ),
      ),
      IconButton(
        tooltip: 'Options',
        icon: const Icon(Icons.tune),
        onPressed: _openOptions,
      ),
      IconButton(
        tooltip: 'High scores',
        icon: const Icon(Icons.emoji_events_outlined),
        onPressed: _openHighScores,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Knight's Tour")),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // The board sits in the middle of the free space, with the
                  // status just above it and the buttons just below.
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Space is kept even when empty, so the board
                          // doesn't jump. Above the status, so the status
                          // stays close to the board.
                          SizedBox(height: 22, child: _helpNote(theme)),
                          Text(
                            _status,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: _game.isOver
                                  ? theme.colorScheme.primary
                                  : null,
                              fontWeight: _game.isOver ? FontWeight.bold : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: BoardView(
                              game: _game,
                              rejectedIndex: _rejectedIndex,
                              showPath:
                                  _options.pathWhilePlaying ||
                                  (_options.pathAtEnd && _game.isOver),
                              highlightMoves: _options.highlightMoves,
                              countExits: _options.countExits,
                              markDead: _options.markDead,
                              onTap: _onSquareTap,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _toolbar(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _canUndo ? _undo : null,
                          icon: const Icon(Icons.undo),
                          label: _fit('Undo (${_game.undosLeft})'),
                        ),
                      ),
                      if (_game.isOver && !_scoreSaved && !_helped)
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: _offerSave,
                            icon: const Icon(Icons.emoji_events),
                            label: _fit('Save'),
                          ),
                        ),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _restart,
                          icon: const Icon(Icons.refresh),
                          label: _fit('Restart'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
