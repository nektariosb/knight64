import 'package:flutter_test/flutter_test.dart';
import 'package:knight64/game/knight_tour.dart';

int sq(int row, int col) => row * 8 + col;

void main() {
  late KnightTour game;
  setUp(() => game = KnightTour());

  test('first tap can be any square and is numbered 1', () {
    expect(game.tryMove(sq(3, 4)), isTrue);
    expect(game.numberAt(sq(3, 4)), 1);
    expect(game.current, sq(3, 4));
  });

  test('accepts knight moves and numbers them in order', () {
    game.tryMove(sq(0, 0));
    expect(game.tryMove(sq(2, 1)), isTrue);
    expect(game.tryMove(sq(4, 2)), isTrue);
    expect(game.numberAt(sq(4, 2)), 3);
  });

  test('rejects non-knight moves', () {
    game.tryMove(sq(0, 0));
    expect(game.tryMove(sq(1, 1)), isFalse);
    expect(game.tryMove(sq(0, 2)), isFalse);
    expect(game.moveCount, 1);
  });

  test('rejects visited squares, including the current one', () {
    game.tryMove(sq(0, 0));
    game.tryMove(sq(2, 1));
    expect(game.tryMove(sq(2, 1)), isFalse);
    expect(game.tryMove(sq(0, 0)), isFalse);
  });

  test('path lists the visited squares in order and follows undo', () {
    game.tryMove(sq(0, 0));
    game.tryMove(sq(2, 1));
    game.tryMove(sq(4, 2));
    expect(game.path, [sq(0, 0), sq(2, 1), sq(4, 2)]);
    game.undo();
    expect(game.path, [sq(0, 0), sq(2, 1)]);
  });

  test('undo clears the last square and cannot be chained', () {
    game.tryMove(sq(0, 0));
    game.tryMove(sq(2, 1));
    expect(game.undo(), isTrue);
    expect(game.numberAt(sq(2, 1)), 0);
    expect(game.undosLeft, 2);
    expect(game.canUndo, isFalse);
    expect(game.undo(), isFalse);

    game.tryMove(sq(1, 2));
    expect(game.canUndo, isTrue);
  });

  test('undo is limited per game and restart refills it', () {
    game.tryMove(sq(0, 0));
    for (var i = 0; i < 3; i++) {
      game.tryMove(sq(2, 1));
      game.undo();
    }
    game.tryMove(sq(2, 1));
    expect(game.undosLeft, 0);
    expect(game.canUndo, isFalse);

    game.restart();
    expect(game.moveCount, 0);
    expect(game.undosLeft, 3);
  });

  test('undoing move 1 empties the board', () {
    game.tryMove(sq(4, 4));
    game.undo();
    expect(game.moveCount, 0);
    expect(game.tryMove(sq(7, 7)), isTrue);
  });

  test('a full Warnsdorff tour completes the board', () {
    var index = sq(0, 0);
    game.tryMove(index);
    while (!game.isOver) {
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
    expect(game.isComplete, isTrue);
    expect(game.numberAt(index), 64);
  });

  test('a square is dead once all its neighbours are used up', () {
    expect(game.deadSquares, isEmpty);
    // The corner's only two neighbours are (1,2) and (2,1).
    game.tryMove(sq(1, 2));
    game.tryMove(sq(3, 3));
    game.tryMove(sq(2, 1));
    // The knight can still jump into the corner from here.
    expect(game.deadSquares, isEmpty);
    game.tryMove(sq(4, 2));
    expect(game.deadSquares, {sq(0, 0)});
    game.undo();
    expect(game.deadSquares, isEmpty);
  });

  test('holes are not part of the board', () {
    final holed = KnightTour(holes: {sq(2, 1)});
    expect(holed.total, 63);
    expect(holed.tryMove(sq(2, 1)), isFalse);
    holed.tryMove(sq(0, 0));
    expect(holed.legalMovesFrom(sq(0, 0)), [sq(1, 2)]);
  });

  test('a hole is never a dead square', () {
    // On 3x3 the knight can never reach the centre.
    final plain = KnightTour(size: 3)..tryMove(0);
    expect(plain.deadSquares, {4});
    final ring = KnightTour(size: 3, holes: {4})..tryMove(0);
    expect(ring.deadSquares, isEmpty);
  });

  test('stuck when no unvisited knight moves remain', () {
    // 3x3 board: the centre square has no knight moves at all.
    final small = KnightTour(size: 3);
    small.tryMove(4);
    expect(small.isStuck, isTrue);
    expect(small.tryMove(0), isFalse);
  });

  group('puzzle clues', () {
    // 3x3 ring: 0 5 6 1 8 3 2 7 one way round, 0 7 2 3 8 1 6 5 the other.
    KnightTour ring(Map<int, int> clues) =>
        KnightTour(size: 3, holes: {4}, clues: clues, maxUndos: null);

    test('move 1 must start on square 1 when it is given', () {
      final game = ring({0: 1});
      expect(game.tryMove(2), isFalse);
      expect(game.tryMove(0), isTrue);
    });

    test('a given square only takes its own move number', () {
      final game = ring({0: 1, 5: 8})..tryMove(0);
      // 5 is a knight move away, but it's saved for move 8.
      expect(game.legalMovesFrom(0), [7]);
      expect(game.tryMove(5), isFalse);
      expect(game.tryMove(7), isTrue);
    });

    test('when the next number is given, only that square is allowed', () {
      final game = ring({0: 1, 7: 2});
      game.tryMove(0);
      expect(game.legalMovesFrom(0), [7]);
      expect(game.tryMove(5), isFalse);
      expect(game.tryMove(7), isTrue);
    });

    test('a given square can leave the knight stuck', () {
      // From 5, the only free square is 6, but 6 is saved for move 4.
      final game = ring({0: 1, 6: 4})..tryMove(0);
      game.tryMove(5);
      expect(game.legalMovesFrom(5), isEmpty);
      expect(game.isStuck, isTrue);
    });

    test('legal moves can be asked for a later move number', () {
      final game = ring({0: 1, 6: 3})..tryMove(0);
      expect(game.legalMovesFrom(5, 3), [6]);
      expect(game.legalMovesFrom(5, 4), isEmpty);
    });

    test('clues ahead count jumps from the knight', () {
      final game = ring({0: 1, 6: 3, 7: 8})..tryMove(0);
      expect(game.cluesAhead, {2: 6, 7: 7});
      game.tryMove(5);
      expect(game.cluesAhead, {1: 6, 6: 7});
    });

    test('unlimited undo can be chained', () {
      final game = ring({0: 1})
        ..tryMove(0)
        ..tryMove(5)
        ..tryMove(6);
      expect(game.undosLeft, isNull);
      for (var i = 0; i < 3; i++) {
        expect(game.undo(), isTrue);
      }
      expect(game.moveCount, 0);
      expect(game.canUndo, isFalse);
    });
  });
}
