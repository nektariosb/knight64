import 'package:flutter_test/flutter_test.dart';
import 'package:knight64/game/knight_tour.dart';
import 'package:knight64/game/puzzle_list.dart';
import 'package:knight64/game/puzzles.dart';
import 'package:knight64/game/solver.dart';

void main() {
  test('a drawn puzzle reads its numbers row by row', () {
    final puzzle = Puzzle.drawn(
      id: 'test',
      board: '3x3',
      rows: [' 1  #  #', ' #  .  8', ' #  #  #'],
    );
    expect(puzzle.board.id, '3x3');
    expect(puzzle.clues, {0: 1, 5: 8});
  });

  test('ids are unique', () {
    expect(puzzles.map((p) => p.id).toSet(), hasLength(puzzles.length));
  });

  for (final (i, puzzle) in puzzles.indexed) {
    test('puzzle ${i + 1} (${puzzle.board.name}) has exactly one solution', () {
      final board = puzzle.board;
      final numbers = puzzle.clues.values.toList();
      expect(numbers.toSet(), hasLength(numbers.length));
      expect(numbers, contains(1));
      expect(numbers.every((n) => n >= 1 && n <= board.total), isTrue);
      expect(puzzle.clues.keys.any(board.holes.contains), isFalse);

      final start = puzzle.clues.entries.firstWhere((e) => e.value == 1).key;
      final game = KnightTour(
        size: board.size,
        holes: board.holes,
        clues: puzzle.clues,
      )..tryMove(start);
      final solutions = countTours((
        size: board.size,
        visited: [
          for (var s = 0; s < board.size * board.size; s++)
            s == start || board.holes.contains(s),
        ],
        current: start,
        clues: game.cluesAhead,
        limit: 2,
        maxSteps: 2000000,
      ));
      expect(solutions, 1);
    });
  }
}
