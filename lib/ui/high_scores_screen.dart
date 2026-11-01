import 'package:flutter/material.dart';

import '../game/high_scores.dart';

class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({
    super.key,
    required this.store,
    required this.total,
    this.highlightRank,
  });

  final HighScoreStore store;

  /// Squares on the board, shown as "23 / 64".
  final int total;

  /// 1-based rank of a just-saved score to highlight.
  final int? highlightRank;

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen> {
  List<HighScore>? _entries;

  @override
  void initState() {
    super.initState();
    widget.store.load().then((table) {
      if (mounted) setState(() => _entries = table.entries);
    });
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear high scores?'),
        content: const Text('This removes every score on this device.'),
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
    await widget.store.clear();
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
      body: switch (entries) {
        null => const Center(child: CircularProgressIndicator()),
        [] => const Center(child: Text('No scores yet. Go play!')),
        _ => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final e = entries[i];
                final undos = e.undosUsed == 1
                    ? '1 undo'
                    : '${e.undosUsed} undos';
                return ListTile(
                  selected: i + 1 == widget.highlightRank,
                  selectedTileColor: theme.colorScheme.primaryContainer
                      .withValues(alpha: 0.4),
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
                        '${e.squares} / ${widget.total}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      },
    );
  }
}
