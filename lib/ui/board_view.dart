import 'package:flutter/material.dart';

import '../game/knight_tour.dart';
import 'theme.dart';

/// The chessboard. Calls [onTap] with the flat index of the tapped square.
class BoardView extends StatelessWidget {
  const BoardView({
    super.key,
    required this.game,
    required this.onTap,
    this.rejectedIndex,
  });

  final KnightTour game;
  final ValueChanged<int> onTap;

  /// Square to briefly flash red after a rejected tap.
  final int? rejectedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BoardColors>()!;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colors.border, width: 4),
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
        ),
        clipBehavior: Clip.antiAlias,
        child: GridView.count(
          crossAxisCount: game.size,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < game.squareCount; i++)
              _Square(
                index: i,
                game: game,
                rejected: i == rejectedIndex,
                onTap: () => onTap(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _Square extends StatelessWidget {
  const _Square({
    required this.index,
    required this.game,
    required this.rejected,
    required this.onTap,
  });

  final int index;
  final KnightTour game;
  final bool rejected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final row = index ~/ game.size, col = index % game.size;
    final isLight = (row + col).isEven;
    final number = game.numberAt(index);
    final isCurrent = index == game.current;
    final colors = Theme.of(context).extension<BoardColors>()!;

    final Color overlay;
    if (rejected) {
      overlay = colors.reject;
    } else if (isCurrent) {
      overlay = colors.current;
    } else if (number > 0) {
      overlay = colors.visited;
    } else {
      overlay = Colors.transparent;
    }

    return GestureDetector(
      onTapDown: (_) => onTap(),
      child: ColoredBox(
        color: isLight ? colors.lightSquare : colors.darkSquare,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: overlay,
          alignment: Alignment.center,
          child: number == 0
              ? null
              : FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      '$number',
                      style: TextStyle(
                        color: isCurrent
                            ? colors.currentText
                            : colors.visitedText,
                        fontSize: 22,
                        fontWeight: isCurrent
                            ? FontWeight.w900
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
