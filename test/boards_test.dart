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
      {for (final b in Board.all) b.id: b.canClose},
      {'3x3': true, '5x5': false, '6x6': true, '8x8': true, '10x10': true},
    );
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
