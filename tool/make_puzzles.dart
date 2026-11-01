// Makes the puzzles in lib/game/puzzle_list.dart:
//
//   dart run tool/make_puzzles.dart
//
// For each level: a random tour on the board, with every square numbered.
// Then numbers are taken away in random order, as long as the tour stays the
// only one that fits, until few enough are left. Each level has its own
// seed, so running it again gives the same puzzles.
import 'dart:io';
import 'dart:math';

import 'package:knight64/game/boards.dart';
import 'package:knight64/game/knight_tour.dart';
import 'package:knight64/game/solver.dart';

/// Board, and the share of squares left numbered (0: as few as possible).
const levels = [
  ('3x3', 0.0),
  ('5x5', 0.5),
  ('5x5', 0.4),
  ('5x5', 0.3),
  ('5x5', 0.0),
  ('6x6', 0.5),
  ('6x6', 0.4),
  ('6x6', 0.3),
  ('6x6', 0.25),
  ('6x6', 0.0),
  ('6x6', 0.0),
  ('8x8', 0.5),
  ('cross', 0.45),
  ('8x8', 0.4),
  ('donut', 0.4),
  ('8x8', 0.35),
  ('heart', 0.4),
  ('8x8', 0.3),
  ('diamond', 0.35),
  ('8x8', 0.25),
  ('house', 0.35),
  ('8x8', 0.0),
  ('tree', 0.3),
  ('smiley', 0.3),
  ('8x8', 0.0),
  ('10x10', 0.35),
  ('frame', 0.3),
  ('10x10', 0.25),
  ('heart', 0.0),
  ('10x10', 0.0),
];

/// Steps the solver may take to show a puzzle has one solution. If it needs
/// more, the number stays.
const maxSteps = 200000;

void main(List<String> args) {
  final out = StringBuffer()
    ..writeln('// Made by `dart run tool/make_puzzles.dart`. Change the tool')
    ..writeln('// and run it again rather than editing this by hand.')
    ..writeln()
    ..writeln("import 'puzzles.dart';")
    ..writeln()
    ..writeln('final puzzles = [');
  for (final (i, (boardId, share)) in levels.indexed) {
    final watch = Stopwatch()..start();
    final board = Board.byId(boardId);
    final rng = Random(1000 + i);
    final tour = randomTour(board, rng);
    final clues = {for (final (n, square) in tour.indexed) square: n + 1};
    final target = (share * board.total).round();
    final order = [for (var n = 2; n <= board.total; n++) n]..shuffle(rng);
    for (final number in order) {
      if (clues.length <= target) break;
      final square = tour[number - 1];
      clues.remove(square);
      if (solutions(board, clues) != 1) clues[square] = number;
    }
    final id = 'p${(i + 1).toString().padLeft(2, '0')}';
    stdout.writeln(
      '$id ${board.id}: ${clues.length} / ${board.total} given '
      '(${watch.elapsedMilliseconds} ms)',
    );
    out
      ..writeln('  Puzzle.drawn(')
      ..writeln("    id: '$id',")
      ..writeln("    board: '${board.id}',")
      ..writeln('    rows: [');
    final width = '${board.total}'.length;
    for (var r = 0; r < board.size; r++) {
      final words = [
        for (var c = 0; c < board.size; c++)
          switch (r * board.size + c) {
            final s when board.holes.contains(s) => '.',
            final s when clues.containsKey(s) => '${clues[s]}',
            _ => '#',
          }.padLeft(width),
      ];
      out.writeln("      '${words.join(' ')}',");
    }
    out
      ..writeln('    ],')
      ..writeln('  ),');
  }
  out.writeln('];');
  const path = 'lib/game/puzzle_list.dart';
  File(path).writeAsStringSync(out.toString());
  Process.runSync('dart', ['format', path], runInShell: true);
}

/// How many tours fit [clues] (square -> number), up to 2, or null if the
/// solver gave up.
int? solutions(Board board, Map<int, int> clues) {
  final game = KnightTour(size: board.size, holes: board.holes, clues: clues);
  final start = clues.entries.firstWhere((e) => e.value == 1).key;
  game.tryMove(start);
  return countTours((
    size: board.size,
    visited: [
      for (var i = 0; i < board.size * board.size; i++)
        i == start || board.holes.contains(i),
    ],
    current: start,
    clues: game.cluesAhead,
    limit: 2,
    maxSteps: maxSteps,
  ));
}

/// A random tour on [board], by Warnsdorff's rule with random tie-breaks,
/// trying again until one fills the board.
List<int> randomTour(Board board, Random rng) {
  final squares = [
    for (var i = 0; i < board.size * board.size; i++)
      if (!board.holes.contains(i)) i,
  ];
  while (true) {
    final game = KnightTour(size: board.size, holes: board.holes)
      ..tryMove(squares[rng.nextInt(squares.length)]);
    while (!game.isOver) {
      final moves = game.legalMovesFrom(game.current!)..shuffle(rng);
      moves.sort(
        (a, b) => game
            .legalMovesFrom(a)
            .length
            .compareTo(game.legalMovesFrom(b).length),
      );
      game.tryMove(moves.first);
    }
    if (game.isComplete) return game.path;
  }
}
