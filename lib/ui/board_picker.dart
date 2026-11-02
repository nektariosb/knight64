import 'package:flutter/material.dart';

import '../game/boards.dart';
import 'board_view.dart';
import 'theme.dart';

/// Bottom sheet listing the boards. Pops with the chosen one.
class BoardPicker extends StatelessWidget {
  const BoardPicker({super.key, this.current});

  /// Null while playing a puzzle.
  final Board? current;

  static String _subtitle(Board board) => [
    '${board.total} squares.',
    board.description,
    if (!board.canClose) 'No closed tours.',
  ].join(' ');

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
            child: Text('Board', style: theme.textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              'A new board starts a new game.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          for (final (title, boards) in [
            ('Sizes', Board.sizes),
            ('Shapes', Board.shapes),
          ]) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            for (final board in boards) _tile(context, board),
          ],
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, Board board) => ListTile(
    leading: BoardPreview(board: board, width: 44),
    title: Text(board.name),
    subtitle: Text(_subtitle(board)),
    selected: board.id == current?.id,
    trailing: board.id == current?.id ? const Icon(Icons.check) : null,
    onTap: () => Navigator.pop(context, board),
  );
}

/// Small drawing of a board, with its holes.
class BoardPreview extends StatelessWidget {
  const BoardPreview({
    super.key,
    required this.board,
    required this.width,
    this.start,
  });

  final Board board;
  final double width;

  /// A square to mark as the place to start, drawn like the knight's square.
  final int? start;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BoardColors>()!;
    final size = board.size;
    return Container(
      width: width,
      height: width,
      decoration: BoxDecoration(border: Border.all(color: colors.border)),
      child: Column(
        children: [
          for (var row = 0; row < size; row++)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var col = 0; col < size; col++)
                    Expanded(
                      child: board.holes.contains(row * size + col)
                          ? const Hole()
                          : ColoredBox(
                              color: row * size + col == start
                                  ? colors.current
                                  : (row + col).isEven
                                  ? colors.lightSquare
                                  : colors.darkSquare,
                            ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
