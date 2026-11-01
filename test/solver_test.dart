import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:knight64/game/knight_tour.dart';
import 'package:knight64/game/solver.dart';

int sq(int row, int col) => row * 8 + col;

Fillable check(KnightTour game, {int maxSteps = 1000000}) => canFill((
  size: game.size,
  visited: [for (var i = 0; i < game.squareCount; i++) game.numberAt(i) > 0],
  current: game.current!,
  maxSteps: maxSteps,
));

/// Plain depth-first search with no shortcuts, to check the solver against.
bool bruteForce(KnightTour game) {
  final size = game.size;
  final visited = [
    for (var i = 0; i < game.squareCount; i++) game.numberAt(i) > 0,
  ];
  bool search(int pos, int remaining) {
    if (remaining == 0) return true;
    final row = pos ~/ size, col = pos % size;
    for (final (dr, dc) in const [
      (-2, -1),
      (-2, 1),
      (-1, -2),
      (-1, 2),
      (1, -2),
      (1, 2),
      (2, -1),
      (2, 1),
    ]) {
      final r = row + dr, c = col + dc;
      if (r < 0 || r >= size || c < 0 || c >= size) continue;
      final next = r * size + c;
      if (visited[next]) continue;
      visited[next] = true;
      if (search(next, remaining - 1)) return true;
      visited[next] = false;
    }
    return false;
  }

  return search(game.current!, visited.where((v) => !v).length);
}

void main() {
  test('every step of a full tour can still be filled', () {
    final game = KnightTour();
    var index = sq(0, 0);
    game.tryMove(index);
    while (!game.isOver) {
      expect(check(game), Fillable.yes, reason: 'move ${game.moveCount}');
      final moves = game.legalMovesFrom(index)
        ..sort(
          (a, b) => game
              .legalMovesFrom(a)
              .length
              .compareTo(game.legalMovesFrom(b).length),
        );
      index = moves.first;
      game.tryMove(index);
    }
  });

  test('an unreachable corner means the board cannot be filled', () {
    final game = KnightTour();
    for (final s in [sq(1, 2), sq(3, 3), sq(2, 1), sq(4, 2)]) {
      game.tryMove(s);
    }
    expect(check(game), Fillable.no);
  });

  test('two dead ends mean the board cannot be filled', () {
    // Both corners (0,0) and (7,7) are left with a single way in.
    final game = KnightTour();
    for (final s in [
      sq(1, 2),
      sq(3, 3),
      sq(5, 4),
      sq(7, 3),
      sq(6, 5),
      sq(4, 4),
    ]) {
      expect(game.tryMove(s), isTrue);
    }
    expect(check(game), Fillable.no);
  });

  test('gives up instead of searching forever', () {
    final game = KnightTour()..tryMove(sq(0, 0));
    expect(check(game, maxSteps: 3), Fillable.unknown);
  });

  test('agrees with brute force on small boards', () {
    final rng = Random(1);
    var yes = 0, no = 0;
    for (var round = 0; round < 600; round++) {
      // 5x5 from early on; 6x6 once brute force is quick enough.
      final size = round.isEven ? 5 : 6;
      final game = KnightTour(size: size)..tryMove(rng.nextInt(size * size));
      final moves = size == 5 ? 1 + rng.nextInt(12) : 12 + rng.nextInt(15);
      while (game.moveCount < moves && !game.isOver) {
        final options = game.legalMovesFrom(game.current!);
        game.tryMove(options[rng.nextInt(options.length)]);
      }
      if (game.isOver) continue;
      final expected = bruteForce(game);
      expected ? yes++ : no++;
      expect(
        check(game),
        expected ? Fillable.yes : Fillable.no,
        reason: 'path ${game.path}',
      );
    }
    // Make sure both answers were actually tested.
    expect(yes, greaterThan(10));
    expect(no, greaterThan(10));
  });
}
