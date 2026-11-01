import 'package:flutter/material.dart';

/// Shown when a game ends. Pops with the entered name, or null if skipped.
class SaveScoreDialog extends StatefulWidget {
  const SaveScoreDialog({
    super.key,
    required this.squares,
    required this.total,
    required this.closed,
    required this.qualifies,
    required this.canUndo,
    required this.initialName,
  });

  final int squares;
  final int total;
  final bool closed;

  /// Whether the score is good enough for the high score list.
  final bool qualifies;

  /// Whether the player could still undo a misclick instead of saving.
  final bool canUndo;

  final String initialName;

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
    final score = Text(
      '${widget.squares} / ${widget.total}',
      textAlign: TextAlign.center,
      style: theme.textTheme.displaySmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );

    if (!widget.qualifies) {
      return AlertDialog(
        title: Text(_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            score,
            const SizedBox(height: 12),
            const Text('Not enough for the high scores this time.'),
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
