import 'package:flutter/material.dart';

import '../game/puzzle_list.dart';
import '../game/puzzles.dart';
import 'board_picker.dart';

/// Bottom sheet listing the puzzles, with a tick on the solved ones. Pops
/// with the chosen one.
class PuzzlePicker extends StatelessWidget {
  const PuzzlePicker({super.key, required this.progress, this.current});

  final PuzzleProgress progress;
  final Puzzle? current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text('Puzzles', style: theme.textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              'Some squares already show their number: the knight must land '
              'there on exactly that move. Each puzzle has only one '
              'solution. Solved: ${progress.solved.length} / '
              '${puzzles.length}.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          for (final (i, puzzle) in puzzles.indexed) _tile(context, i, puzzle),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, int i, Puzzle puzzle) {
    final solved = progress.solved.contains(puzzle.id);
    return ListTile(
      leading: BoardPreview(board: puzzle.board, width: 44),
      title: Text('Puzzle ${i + 1}'),
      subtitle: Text(
        '${puzzle.board.name}, ${puzzle.clues.length} of '
        '${puzzle.board.total} numbers given',
      ),
      selected: puzzle.id == current?.id,
      trailing: solved
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () => Navigator.pop(context, puzzle),
    );
  }
}
