import 'package:flutter/material.dart';

import '../game/facts.dart';
import 'fact_box.dart';

/// Shown when a game ends. Pops with the entered name, or null if skipped.
class SaveScoreDialog extends StatefulWidget {
  const SaveScoreDialog({
    super.key,
    required this.squares,
    required this.total,
    required this.closed,
    required this.helped,
    required this.qualifies,
    required this.canUndo,
    required this.initialName,
    this.fact,
  });

  final int squares;
  final int total;
  final bool closed;

  /// A help option was used, so the score can't be saved.
  final bool helped;

  /// Whether the score is good enough for the high score list.
  final bool qualifies;

  /// Whether the player could still undo a misclick instead of saving.
  final bool canUndo;

  final String initialName;

  /// Shown at the bottom, every few games.
  final Fact? fact;

  @override
  State<SaveScoreDialog> createState() => _SaveScoreDialogState();
}

class _SaveScoreDialogState extends State<SaveScoreDialog> {
  late final _name = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String get _title {
    if (widget.squares < widget.total) return 'No moves left';
    return widget.closed ? 'Closed tour!' : 'Tour complete!';
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isNotEmpty) Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${widget.squares} / ${widget.total}',
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.closed) ...[
          const SizedBox(height: 8),
          const Text(
            'Your last square is one knight jump from square 1, '
            'so your tour makes a full loop.',
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    final fact = [
      if (widget.fact case final fact?) ...[
        const SizedBox(height: 16),
        FactBox(fact),
      ],
    ];

    if (!widget.qualifies) {
      return AlertDialog(
        title: Text(_title),
        // A fact can make it taller than a small screen.
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            score,
            const SizedBox(height: 12),
            Text(
              widget.helped
                  ? "You played with help, so this game can't enter the "
                        'high scores. Turn help off in Options to go for a '
                        'high score!'
                  : 'Not enough for the high scores this time.',
              textAlign: TextAlign.center,
            ),
            ...fact,
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text(_title),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          score,
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            autofocus: true,
            maxLength: 16,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Your name',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _save(),
          ),
          if (widget.canUndo)
            Text(
              'Misclick? Choose "Not now" and use Undo.',
              style: theme.textTheme.bodySmall,
            ),
          ...fact,
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Not now'),
        ),
        ListenableBuilder(
          listenable: _name,
          builder: (context, _) => FilledButton(
            onPressed: _name.text.trim().isEmpty ? null : _save,
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}
