import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:knight64/game/knight_tour.dart';
import 'package:knight64/game/solver.dart';

int sq(int row, int col) => row * 8 + col;

List<bool> visitedOf(KnightTour game) => [
  for (var i = 0; i < game.squareCount; i++) game.numberAt(i) > 0,
];

Fillable check(KnightTour game, {int maxSteps = 1000000}) => canFill((
  size: game.size,
  visited: visitedOf(game),
  current: game.current!,
  clues: game.cluesAhead,
  maxSteps: maxSteps,
));

int? count(KnightTour game, {int limit = 1000000}) => countTours((
  size: game.size,
  visited: visitedOf(game),
  current: game.current!,
  clues: game.cluesAhead,
  limit: limit,
  maxSteps: 10000000,
));

/// Plain depth-first search with no shortcuts, to check the solver against.
/// Counts the ways to finish, keeping to the game's clues.
int bruteForceCount(KnightTour game) {
  final size = game.size;
  final visited = visitedOf(game);
  final clues = game.cluesAhead;
  final clueSquares = clues.values.toSet();
  int search(int pos, int remaining, int jumps) {
    if (remaining == 0) return 1;
    var ways = 0;
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
      final clue = clues[jumps + 1];
      if (clue != null ? next != clue : clueSquares.contains(next)) continue;
      visited[next] = true;
      ways += search(next, remaining - 1, jumps + 1);
      visited[next] = false;
    }
    return ways;
  }

  return search(game.current!, visited.where((v) => !v).length, 0);
}

/// Plain depth-first search with no shortcuts, to check the solver against.
bool bruteForce(KnightTour game) {
  final size = game.size;
  final visited = visitedOf(game);
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

  test('counts tours like brute force, with and without clues', () {
    final rng = Random(2);
    var withClues = 0, none = 0, many = 0;
    for (var round = 0; round < 300; round++) {
      final size = round.isEven ? 5 : 6;
      // A random full tour to take clues from, so some puzzles have one.
      final tour = randomTour(size, rng);
      if (tour == null) continue;
      final clues = <int, int>{
        for (var n = 1; n <= tour.length; n++)
          if (n == 1 || rng.nextInt(size == 5 ? 4 : 3) == 0) tour[n - 1]: n,
      };
      // Sometimes move a clue, which often leaves no solution at all.
      if (rng.nextBool()) {
        final square = clues.keys.elementAt(rng.nextInt(clues.length));
        final number = clues.remove(square)!;
        final free = [
          for (var i = 0; i < size * size; i++)
            if (!clues.containsKey(i)) i,
        ];
        clues[free[rng.nextInt(free.length)]] = number;
      }
      final game = KnightTour(size: size, clues: clues);
      if (!game.tryMove(tour.first)) continue;
      // Play a few moves first, sticking to the tour.
      final moves = rng.nextInt(size == 5 ? 6 : 12);
      for (var i = 1; i <= moves && game.tryMove(tour[i]); i++) {}
      final expected = bruteForceCount(game);
      withClues++;
      if (expected == 0) none++;
      if (expected > 1) many++;
      expect(count(game), expected, reason: 'clues $clues, ${game.path}');
      expect(count(game, limit: 2), min(expected, 2));
      expect(
        check(game),
        expected > 0 ? Fillable.yes : Fillable.no,
        reason: 'clues $clues, ${game.path}',
      );
    }
    expect(withClues, greaterThan(100));
    expect(none, greaterThan(10));
    expect(many, greaterThan(10));
  });
}

/// A random knight's tour on an empty [size] x [size] board, by Warnsdorff's
/// rule with random tie-breaks, or null if it got stuck.
List<int>? randomTour(int size, Random rng) {
  final game = KnightTour(size: size)..tryMove(rng.nextInt(size * size));
  while (!game.isOver) {
    final moves = game.legalMovesFrom(game.current!)..shuffle(rng);
    moves.sort(
      (a, b) => game
          .legalMovesFrom(a, game.moveCount + 2)
          .length
          .compareTo(game.legalMovesFrom(b, game.moveCount + 2).length),
    );
    game.tryMove(moves.first);
  }
  return game.isComplete ? game.path : null;
}
