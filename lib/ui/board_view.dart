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
    this.showPath = false,
    this.highlightMoves = false,
    this.countExits = false,
    this.markDead = false,
  });

  final KnightTour game;
  final ValueChanged<int> onTap;

  /// Square to briefly flash red after a rejected tap.
  final int? rejectedIndex;

  /// Draws a line through the visited squares in order. It animates in each
  /// time it appears.
  final bool showPath;

  /// Puts a dot on every square the knight can jump to next.
  final bool highlightMoves;

  /// Shows on every square the knight can jump to how many jumps it would
  /// have from there. Replaces the dot of [highlightMoves].
  final bool countExits;

  /// Tints the squares the knight can never reach again.
  final bool markDead;

  /// How long the path takes to draw for a game of [moves] moves.
  static Duration pathDrawTime(int moves) => Duration(milliseconds: 25 * moves);

  Widget _grid(List<Widget> children) => GridView.count(
    crossAxisCount: game.size,
    physics: const NeverScrollableScrollPhysics(),
    children: children,
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BoardColors>()!;
    final current = game.current;
    final targets = (highlightMoves || countExits) && current != null
        ? game.legalMovesFrom(current).toSet()
        : const <int>{};
    final dead = markDead && !game.isOver ? game.deadSquares : const <int>{};
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colors.border, width: 4),
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _grid([
              for (var i = 0; i < game.squareCount; i++)
                _Square(
                  index: i,
                  game: game,
                  rejected: i == rejectedIndex,
                  hinted: targets.contains(i),
                  exits: countExits && targets.contains(i)
                      ? game.legalMovesFrom(i, game.moveCount + 2).length
                      : null,
                  dead: dead.contains(i),
                  onTap: () => onTap(i),
                ),
            ]),
            if (showPath)
              IgnorePointer(
                key: const ValueKey('path'),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: pathDrawTime(game.moveCount),
                  builder: (context, progress, _) => CustomPaint(
                    painter: _PathPainter(
                      path: game.path,
                      size: game.size,
                      closed: game.isClosed,
                      progress: progress,
                      color: colors.path,
                      closingColor: colors.closingPath,
                    ),
                  ),
                ),
              ),
            IgnorePointer(
              key: const ValueKey('numbers'),
              child: _grid([
                for (var i = 0; i < game.squareCount; i++)
                  _Number(index: i, game: game),
              ]),
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
    required this.hinted,
    required this.exits,
    required this.dead,
    required this.onTap,
  });

  final int index;
  final KnightTour game;
  final bool rejected;

  /// The knight can jump here: shows [exits] if given, otherwise a dot.
  final bool hinted;
  final int? exits;

  /// The knight can never reach this square again.
  final bool dead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final row = index ~/ game.size, col = index % game.size;
    final isLight = (row + col).isEven;
    final colors = Theme.of(context).extension<BoardColors>()!;
    if (game.isHole(index)) return const Hole();

    final Color overlay;
    if (rejected) {
      overlay = colors.reject;
    } else if (index == game.current) {
      overlay = colors.current;
    } else if (game.numberAt(index) > 0) {
      overlay = colors.visited;
    } else if (dead) {
      overlay = colors.dead;
    } else {
      overlay = Colors.transparent;
    }

    Widget? hint;
    if (exits != null) {
      hint = Center(
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              '$exits',
              style: TextStyle(
                color: colors.hint,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      );
    } else if (hinted) {
      hint = Center(
        child: FractionallySizedBox(
          widthFactor: 0.3,
          heightFactor: 0.3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.hint,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTapDown: (_) => onTap(),
      child: ColoredBox(
        color: isLight ? colors.lightSquare : colors.darkSquare,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: overlay,
          child: hint,
        ),
      ),
    );
  }
}

/// A square that isn't part of the board, drawn dark with diagonal stripes
/// so it doesn't look like a square to play.
class Hole extends StatelessWidget {
  const Hole({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BoardColors>()!;
    return CustomPaint(
      painter: _HolePainter(colors.hole, colors.holeStripe),
      child: const SizedBox.expand(),
    );
  }
}

class _HolePainter extends CustomPainter {
  _HolePainter(this.background, this.stripe);

  final Color background;
  final Color stripe;

  @override
  void paint(Canvas canvas, Size size) {
    final square = Offset.zero & size;
    canvas
      ..drawRect(square, Paint()..color = background)
      ..clipRect(square);
    final gap = size.width / 4;
    final paint = Paint()
      ..color = stripe
      ..strokeWidth = gap * 0.35;
    for (var x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HolePainter old) =>
      old.background != background || old.stripe != stripe;
}

/// Move number on a square, drawn above the path so it stays readable. In a
/// puzzle, the given numbers show before the knight gets there.
class _Number extends StatelessWidget {
  const _Number({required this.index, required this.game});

  final int index;
  final KnightTour game;

  @override
  Widget build(BuildContext context) {
    final number = game.numberAt(index);
    final colors = Theme.of(context).extension<BoardColors>()!;
    if (number == 0) {
      final clue = game.clueAt(index);
      if (clue == null) return const SizedBox.shrink();
      return FractionallySizedBox(
        widthFactor: 0.62,
        heightFactor: 0.62,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.clueDisc,
            shape: BoxShape.circle,
          ),
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '$clue',
                style: TextStyle(
                  color: colors.clueText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
    }
    final isCurrent = index == game.current;
    return Center(
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            '$number',
            style: TextStyle(
              color: isCurrent ? colors.currentText : colors.visitedText,
              fontSize: 22,
              fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
              shadows: isCurrent
                  ? null
                  : [
                      for (var i = 0; i < 3; i++)
                        Shadow(color: colors.visitedTextHalo, blurRadius: 3),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Line from square centre to square centre along [path], drawn up to
/// [progress] (0 to 1). A closed tour gets one more line back to the start.
class _PathPainter extends CustomPainter {
  _PathPainter({
    required this.path,
    required this.size,
    required this.closed,
    required this.progress,
    required this.color,
    required this.closingColor,
  });

  final List<int> path;
  final int size;
  final bool closed;
  final double progress;
  final Color color;
  final Color closingColor;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (path.isEmpty) return;
    final cell = canvasSize.width / size;
    Offset centre(int index) =>
        Offset((index % size + 0.5) * cell, (index ~/ size + 0.5) * cell);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = cell * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Dot on square 1, so you can see where the tour started.
    canvas.drawCircle(centre(path.first), cell * 0.12, Paint()..color = color);

    final segments = path.length - 1 + (closed ? 1 : 0);
    if (segments == 0) return;
    final drawn = progress * segments;

    final line = Path()..moveTo(centre(path.first).dx, centre(path.first).dy);
    for (var i = 1; i < path.length && i - 1 < drawn; i++) {
      final from = centre(path[i - 1]), to = centre(path[i]);
      final end = Offset.lerp(from, to, (drawn - (i - 1)).clamp(0, 1))!;
      line.lineTo(end.dx, end.dy);
    }
    canvas.drawPath(line, paint);

    if (closed && drawn > segments - 1) {
      final from = centre(path.last), to = centre(path.first);
      canvas.drawLine(
        from,
        Offset.lerp(from, to, drawn - (segments - 1))!,
        paint
          ..color = closingColor
          ..strokeWidth = cell * 0.12,
      );
    }
  }

  @override
  bool shouldRepaint(_PathPainter old) =>
      old.progress != progress ||
      old.path.length != path.length ||
      old.closed != closed ||
      old.color != color ||
      old.closingColor != closingColor;
}
