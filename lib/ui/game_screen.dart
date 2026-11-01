import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/high_scores.dart';
import '../game/knight_tour.dart';
import 'board_view.dart';
import 'high_scores_screen.dart';
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
  int? _rejectedIndex;
  Timer? _flashTimer;

  /// Once saved, the game is locked so the same game can't be saved twice.
  bool _scoreSaved = false;

  /// The save dialog pops up once per game over; after that the player uses
  /// the "Save score" button.
  bool _gameOverShown = false;

  bool get _canUndo => _game.canUndo && !_scoreSaved;

  @override
  void initState() {
    super.initState();
    _sounds.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    _sounds.dispose();
    super.dispose();
  }

  void _onSquareTap(int index) {
    if (_game.tryMove(index)) {
      _sounds.move();
      setState(() {});
      if (_game.isOver && !_gameOverShown) {
        _gameOverShown = true;
        _offerSave();
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
    _game.undo();
    _gameOverShown = false;
  });

  void _restart() => setState(() {
    _game.restart();
    _scoreSaved = false;
    _gameOverShown = false;
  });

  HighScore _score(String name) => HighScore(
    name: name,
    squares: _game.moveCount,
    closed: _game.isClosed,
    undosUsed: _game.undosUsed,
    date: DateTime.now(),
  );

  Future<void> _offerSave() async {
    final table = await _store.load();
    final lastName = await _store.lastName();
    if (!mounted) return;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => SaveScoreDialog(
        squares: _game.moveCount,
        total: _game.squareCount,
        closed: _game.isClosed,
        qualifies: table.qualifies(_score('')),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knight64'),
        leadingWidth: 104,
        leading: Row(
          children: [
            IconButton(
              tooltip: widget.themeController.isDark
                  ? 'Light mode'
                  : 'Dark mode',
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
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'High scores',
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: _openHighScores,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _status,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: _game.isOver ? theme.colorScheme.primary : null,
                      fontWeight: _game.isOver ? FontWeight.bold : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: BoardView(
                        game: _game,
                        rejectedIndex: _rejectedIndex,
                        onTap: _onSquareTap,
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
                      if (_game.isOver && !_scoreSaved)
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
