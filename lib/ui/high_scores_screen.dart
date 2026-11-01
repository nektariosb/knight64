import 'package:flutter/material.dart';

import '../game/boards.dart';
import '../game/high_scores.dart';

/// The high scores of each board, starting with [board].
class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({
    super.key,
    required this.store,
    required this.board,
    this.highlightRank,
  });

  final HighScoreStore store;
  final Board board;

  /// 1-based rank of a just-saved score on [board] to highlight.
  final int? highlightRank;

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen> {
  late var _board = widget.board;
  late var _highlightRank = widget.highlightRank;
  List<HighScore>? _entries;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final board = _board;
    _entries = null;
    widget.store.load(board.id).then((table) {
      // Ignores the answer if another board was picked meanwhile.
      if (mounted && board == _board) {
        setState(() => _entries = table.entries);
      }
    });
  }

  void _showBoard(Board board) => setState(() {
    _board = board;
    _highlightRank = null;
    _load();
  });

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear the ${_board.name} high scores?'),
        content: Text(
          'This removes every ${_board.name} score on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.store.clear(_board.id);
    if (mounted) setState(() => _entries = []);
  }

  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('High scores'),
        actions: [
          if (entries != null && entries.isNotEmpty)
            IconButton(
              tooltip: 'Clear high scores',
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                // Wraps onto more rows, so every board stays in sight.
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final board in Board.all)
                      ChoiceChip(
                        label: Text(board.name),
                        selected: board == _board,
                        showCheckmark: false,
                        onSelected: (_) => _showBoard(board),
                      ),
                  ],
                ),
              ),
              Expanded(child: _list(entries, theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(List<HighScore>? entries, ThemeData theme) => switch (entries) {
    null => const Center(child: CircularProgressIndicator()),
    [] => const Center(child: Text('No scores yet. Go play!')),
    _ => ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        final undos = e.undosUsed == 1 ? '1 undo' : '${e.undosUsed} undos';
        return ListTile(
          selected: i + 1 == _highlightRank,
          selectedTileColor: theme.colorScheme.primaryContainer.withValues(
            alpha: 0.4,
          ),
          leading: CircleAvatar(child: Text('${i + 1}')),
          title: Text(e.name),
          subtitle: Text('${_formatDate(e.date)} · $undos'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (e.closed)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Tooltip(
                    message: 'Closed tour',
                    child: Icon(Icons.all_inclusive),
                  ),
                ),
              Text(
                '${e.squares} / ${_board.total}',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        );
      },
    ),
  };
}
