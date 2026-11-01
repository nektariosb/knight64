import 'package:flutter_test/flutter_test.dart';
import 'package:knight64/game/boards.dart';
import 'package:knight64/game/knight_tour.dart';
import 'package:knight64/game/solver.dart';

/// Whether a tour on [board] can start from [start].
Fillable fromStart(Board board, int start) => canFill((
  size: board.size,
  visited: [
    for (var i = 0; i < board.size * board.size; i++)
      i == start || board.holes.contains(i),
  ],
  current: start,
  maxSteps: 200000,
));

void main() {
  test('ids are unique and byId falls back to 8x8', () {
    expect(Board.all.map((b) => b.id).toSet(), hasLength(Board.all.length));
    expect(Board.byId('6x6').size, 6);
    expect(Board.byId('nope'), Board.standard);
    expect(Board.byId(null), Board.standard);
  });

  test('a tour can start from every square, except on 5x5', () {
    for (final board in Board.all) {
      for (var i = 0; i < board.size * board.size; i++) {
        if (board.holes.contains(i)) continue;
        // On 5x5 the corners' colour has 13 squares, the other colour 12.
        final expected = board.size == 5 && (i ~/ 5 + i % 5).isOdd
            ? Fillable.no
            : Fillable.yes;
        expect(fromStart(board, i), expected, reason: '${board.name}, $i');
      }
    }
  });

  test('closed tours need as many light squares as dark ones', () {
    expect(
      [
        for (final b in Board.all)
          if (!b.canClose) b.id,
      ],
      ['5x5'],
    );
  });

  test('the shaped boards have closed tours', () {
    // Found by a search; any one is enough. Squares in order, as indexes.
    const tours = {
      'cross':
          '2 12 22 39 45 60 50 40 25 10 16 33 18 24 41 58 43 53 59 42 32 17 '
          '27 44 61 51 34 28 38 23 13 3 20 5 11 26 36 30 47 37 52 35 29 46 '
          '31 21 4 19',
      'donut':
          '0 17 32 49 59 42 48 58 52 62 47 53 63 46 61 55 38 23 6 21 15 5 11 '
          '1 16 33 43 60 45 30 13 7 22 39 54 37 31 14 4 19 29 44 50 56 41 26 '
          '9 24 34 51 57 40 25 8 2 12 18 3 20 10',
      'frame':
          '0 12 20 1 13 5 24 32 11 3 15 7 19 27 8 29 48 69 88 96 84 92 80 72 '
          '51 30 22 41 60 81 93 85 73 94 75 67 59 38 17 9 28 16 4 25 6 14 26 '
          '18 37 49 57 78 99 87 79 58 39 47 68 76 97 89 77 98 86 74 95 83 91 '
          '70 62 50 71 90 82 61 42 23 2 10 31 52 40 21',
      'heart':
          '11 30 22 41 20 12 31 23 42 21 40 52 73 85 64 76 84 65 57 49 28 16 '
          '24 36 17 29 48 27 39 18 37 58 66 47 26 38 46 67 75 56 35 54 62 74 '
          '53 45 33 25 13 34 55 43 51 63 44 32',
      'diamond':
          '4 16 24 5 13 32 40 61 73 94 86 67 59 38 26 14 22 41 33 25 37 49 '
          '68 47 66 58 77 85 64 52 31 50 62 83 95 74 53 45 57 76 84 72 51 43 '
          '55 63 75 56 48 36 44 65 46 54 35 27 15 34 42 23',
      'smiley':
          '2 21 40 61 82 70 51 30 11 3 22 14 6 18 39 27 15 7 28 49 68 87 79 '
          '58 77 69 88 96 84 92 71 50 31 12 20 41 60 72 93 85 97 78 59 38 17 '
          '29 48 67 86 94 73 81 62 83 75 56 44 32 13 5 24 43 55 76 95 74 53 '
          '45 37 25 4 16 35 47 26 34 46 54 42 23',
      'house':
          '4 16 37 49 68 87 66 58 77 98 86 78 97 76 88 96 75 67 48 27 15 23 '
          '31 52 40 61 82 74 93 81 73 92 71 83 91 72 64 56 35 47 55 36 57 38 '
          '46 65 44 63 42 54 62 43 51 32 24 5 13 34 53 45 26 14 22 41 33 25',
      'tree':
          '4 16 24 5 13 25 33 14 22 43 51 72 84 76 88 67 86 78 57 36 15 27 '
          '46 58 77 65 53 34 26 45 64 85 73 81 62 83 95 87 66 74 82 94 75 56 '
          '44 52 71 63 55 47 35 54 42 23',
    };
    expect(tours.keys, Board.shapes.map((b) => b.id));
    tours.forEach((id, tour) {
      final board = Board.byId(id);
      final game = KnightTour(size: board.size, holes: board.holes);
      for (final i in tour.split(' ').map(int.parse)) {
        expect(game.tryMove(i), isTrue, reason: '$id, $i');
      }
      expect(game.isClosed, isTrue, reason: id);
    });
  });

  test('the 3x3 ring is one closed tour around the hole', () {
    final board = Board.byId('3x3');
    final game = KnightTour(size: 3, holes: board.holes);
    expect(game.total, 8);
    expect(game.tryMove(4), isFalse);
    // From a corner there are two ways round the ring; take one.
    for (final i in [0, 5, 6, 1, 8, 3, 2, 7]) {
      expect(game.tryMove(i), isTrue, reason: '$i');
    }
    expect(game.isComplete, isTrue);
    expect(game.isClosed, isTrue);
  });
}
