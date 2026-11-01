import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knight64/game/knight_tour.dart';
import 'package:knight64/game/puzzle_list.dart';
import 'package:knight64/game/puzzles.dart';
import 'package:knight64/main.dart';
import 'package:knight64/ui/board_view.dart';
import 'package:knight64/ui/celebration.dart';
import 'package:knight64/ui/info_screen.dart';
import 'package:knight64/ui/options_sheet.dart';
import 'package:knight64/ui/puzzle_picker.dart';
import 'package:knight64/ui/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Starts the app on a phone-sized screen, so the Options sheet fits.
Future<void> startApp(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(KnightsTourApp(themeController: ThemeController()));
  await tester.pumpAndSettle();
}

/// Taps the square at [row], [col] on a board of [size] x [size].
Future<void> tapSquare(
  WidgetTester tester,
  int row,
  int col, {
  int size = 8,
}) async {
  final board = tester.getRect(find.byType(BoardView)).deflate(4);
  final cell = board.width / size;
  await tester.tapAt(board.topLeft + Offset(col + 0.5, row + 0.5) * cell);
  await tester.pump();
}

/// Plays 4 moves that end in the corner after both its exits are used up.
Future<void> playIntoCorner(WidgetTester tester) async {
  for (final (row, col) in [(1, 2), (3, 3), (2, 1), (0, 0)]) {
    await tapSquare(tester, row, col);
  }
}

/// Opens Options, flips the switch called [label] [times] times, and closes
/// the sheet again.
Future<void> toggleOption(
  WidgetTester tester,
  String label, {
  int times = 1,
}) async {
  await tester.tap(find.byTooltip('Options'));
  await tester.pumpAndSettle();
  for (var i = 0; i < times; i++) {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }
  Navigator.of(tester.element(find.byType(OptionsSheet))).pop();
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('starts with an empty board and the start prompt', (
    tester,
  ) async {
    await tester.pumpWidget(KnightsTourApp(themeController: ThemeController()));
    expect(find.text('Tap any square to start'), findsOneWidget);
    expect(find.text('Undo (3)'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('theme button switches between dark and light', (tester) async {
    final controller = ThemeController();
    await tester.pumpWidget(KnightsTourApp(themeController: controller));
    expect(controller.value, ThemeMode.dark);

    await tester.tap(find.byTooltip('Light mode'));
    await tester.pumpAndSettle();
    expect(controller.value, ThemeMode.light);
    expect(find.byTooltip('Dark mode'), findsOneWidget);
  });

  testWidgets('game over draws the path, then offers to save', (tester) async {
    await startApp(tester);

    expect(find.byKey(const ValueKey('path')), findsNothing);
    await playIntoCorner(tester);

    expect(find.text('No moves left: 4 / 64'), findsOneWidget);
    expect(find.byKey(const ValueKey('path')), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Your name'), findsOneWidget);
  });

  testWidgets('with the path option off, the dialog comes right away', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'path_at_end': false});
    await startApp(tester);

    await playIntoCorner(tester);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('path')), findsNothing);
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('highlight marks the possible moves and counts as help', (
    tester,
  ) async {
    await startApp(tester);

    await toggleOption(tester, 'Highlight possible moves');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('highlight_moves'), true);

    await tapSquare(tester, 0, 0);
    expect(find.text('Playing with help'), findsOneWidget);
    // A corner square has two knight moves.
    expect(find.byType(FractionallySizedBox), findsNWidgets(2));
  });

  testWidgets('help turned on and off mid-game still counts', (tester) async {
    await startApp(tester);

    await tapSquare(tester, 1, 2);
    expect(find.text('Playing with help'), findsNothing);
    await toggleOption(tester, 'Highlight possible moves', times: 2);
    expect(find.text('Playing with help'), findsOneWidget);
    expect(find.byType(FractionallySizedBox), findsNothing);

    for (final (row, col) in [(3, 3), (2, 1), (0, 0)]) {
      await tapSquare(tester, row, col);
    }
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.textContaining('You played with help'), findsOneWidget);
    expect(find.text('Your name'), findsNothing);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsNothing);

    await tester.tap(find.text('Restart'));
    await tester.pumpAndSettle();
    expect(find.text('Playing with help'), findsNothing);
  });

  testWidgets('exit counts show on the possible moves', (tester) async {
    await startApp(tester);

    await toggleOption(tester, 'Count the exits');
    await tapSquare(tester, 0, 0);
    // From the corner the knight can go to (1,2) or (2,1); each has 5 exits.
    expect(find.text('5'), findsNWidgets(2));
    expect(find.byType(FractionallySizedBox), findsNothing);
    expect(find.text('Playing with help'), findsOneWidget);
  });

  testWidgets('unreachable squares are marked', (tester) async {
    await startApp(tester);

    await toggleOption(tester, 'Warn about unreachable squares');
    final dead = BoardColors.dark.dead;
    bool cornerMarked() => tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .any((c) => (c.decoration as BoxDecoration?)?.color == dead);

    for (final (row, col) in [(1, 2), (3, 3), (2, 1)]) {
      await tapSquare(tester, row, col);
    }
    await tester.pumpAndSettle();
    expect(cornerMarked(), isFalse);

    await tapSquare(tester, 4, 2);
    await tester.pumpAndSettle();
    expect(cornerMarked(), isTrue);
    expect(find.text('Playing with help'), findsOneWidget);
  });

  testWidgets('fill check says whether the board can still be filled', (
    tester,
  ) async {
    await startApp(tester);
    await toggleOption(tester, 'Check if the board can be filled');

    /// Lets the background check finish, then shows its answer.
    Future<void> waitFor(String text) async {
      for (var i = 0; i < 100 && find.text(text).evaluate().isEmpty; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }
      expect(find.text(text), findsOneWidget);
    }

    await tapSquare(tester, 1, 2);
    expect(find.text('Playing with help'), findsOneWidget);
    await waitFor('Can still be filled');

    // Trap the corner: its only two neighbours get used up.
    for (final (row, col) in [(3, 3), (2, 1), (4, 2)]) {
      await tapSquare(tester, row, col);
    }
    await waitFor("Can't be filled anymore");
  });

  testWidgets('path while playing is not a help', (tester) async {
    await startApp(tester);

    await toggleOption(tester, 'Show the path while playing');
    await tapSquare(tester, 0, 0);
    expect(find.byKey(const ValueKey('path')), findsOneWidget);
    expect(find.text('Playing with help'), findsNothing);
  });

  testWidgets('info button opens the knight\'s tour page', (tester) async {
    await startApp(tester);

    await tester.tap(find.byTooltip("About the Knight's Tour"));
    await tester.pumpAndSettle();
    expect(find.text('How to play'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Amazing facts'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(InfoScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Amazing facts'), findsOneWidget);
  });

  testWidgets('restart asks first mid-game, but not after it', (tester) async {
    SharedPreferences.setMockInitialValues({'path_at_end': false});
    await startApp(tester);
    await tapSquare(tester, 1, 2);

    await tester.tap(find.text('Restart'));
    await tester.pumpAndSettle();
    expect(find.text('Start over?'), findsOneWidget);
    await tester.tap(find.text('Keep playing'));
    await tester.pumpAndSettle();
    expect(find.text('Move 1 / 64'), findsOneWidget);

    await tester.tap(find.text('Restart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start over'));
    await tester.pumpAndSettle();
    expect(find.text('Tap any square to start'), findsOneWidget);

    // Game over: no question.
    await playIntoCorner(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restart'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Tap any square to start'), findsOneWidget);
  });

  testWidgets('picking a board mid-game asks first', (tester) async {
    await startApp(tester);
    await tapSquare(tester, 0, 0);

    Future<void> pick(String name) async {
      await tester.tap(find.byTooltip('Board: 8×8'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
    }

    // The board already in play: nothing happens.
    await pick('8×8');
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Move 1 / 64'), findsOneWidget);

    await pick('6×6');
    expect(find.text('Switch to 6×6?'), findsOneWidget);
    await tester.tap(find.text('Keep playing'));
    await tester.pumpAndSettle();
    expect(find.text('Move 1 / 64'), findsOneWidget);

    await pick('6×6');
    await tester.tap(find.text('New game'));
    await tester.pumpAndSettle();
    expect(find.text('Tap any square to start'), findsOneWidget);
    expect(find.byTooltip('Board: 6×6'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('board'), '6x6');

    await tapSquare(tester, 0, 0, size: 6);
    expect(find.text('Move 1 / 36'), findsOneWidget);
  });

  testWidgets('3x3 ring: the hole does nothing, scores go on its own list', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'board': '3x3'});
    await startApp(tester);

    await tapSquare(tester, 1, 1, size: 3);
    expect(find.text('Tap any square to start'), findsOneWidget);

    for (final i in [0, 5, 6, 1, 8, 3, 2, 7]) {
      await tapSquare(tester, i ~/ 3, i % 3, size: 3);
    }
    expect(find.text('Closed tour! All 8 squares'), findsOneWidget);
    // The path draws, then the celebration, then the save dialog.
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(Celebration), findsOneWidget);
    expect(find.textContaining('A full loop!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    await tester.pump(Celebration.bannerTime);
    await tester.pumpAndSettle();
    expect(find.byType(Celebration), findsNothing);
    await tester.enterText(find.byType(TextField), 'Ana');
    // Lets the Save button see the name.
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Save'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('High scores'), findsOneWidget);
    expect(find.text('8 / 8'), findsOneWidget);
    await tester.tap(find.text('8×8'));
    await tester.pumpAndSettle();
    expect(find.text('No scores yet. Go play!'), findsOneWidget);
  });

  testWidgets('a full open tour celebrates; restart stops it', (tester) async {
    SharedPreferences.setMockInitialValues({'board': '5x5'});
    await startApp(tester);

    for (final i in [
      0,
      7,
      4,
      13,
      24,
      17,
      20,
      11,
      18,
      9,
      2,
      5,
      16,
      23,
      14,
      3,
      6,
      15,
      22,
      19,
      8,
      1,
      12,
      21,
      10,
    ]) {
      await tapSquare(tester, i ~/ 5, i % 5, size: 5);
    }
    expect(find.text('Tour complete! All 25 squares'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('You filled all 25 squares!'), findsOneWidget);
    expect(find.textContaining('A full loop!'), findsNothing);

    // The confetti doesn't block the buttons.
    await tester.tap(find.text('Restart'));
    await tester.pump();
    expect(find.byType(Celebration), findsNothing);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  group('puzzles', () {
    /// The solution of [puzzle], by plain backtracking (for small boards).
    List<int> solve(Puzzle puzzle) {
      final board = puzzle.board;
      final game = KnightTour(
        size: board.size,
        holes: board.holes,
        clues: puzzle.clues,
        maxUndos: null,
      );
      bool search() {
        if (game.isComplete) return true;
        final moves = game.current == null
            ? [
                for (final e in puzzle.clues.entries)
                  if (e.value == 1) e.key,
              ]
            : game.legalMovesFrom(game.current!);
        for (final move in moves) {
          game.tryMove(move);
          if (search()) return true;
          game.undo();
        }
        return false;
      }

      expect(search(), isTrue);
      return game.path;
    }

    Future<void> pickPuzzle(WidgetTester tester, int number) async {
      await tester.tap(find.byTooltip('Puzzles'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Puzzle $number'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(PuzzlePicker),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Puzzle $number'));
      await tester.pumpAndSettle();
    }

    testWidgets('solving a puzzle ticks it and offers the next one', (
      tester,
    ) async {
      await startApp(tester);
      await pickPuzzle(tester, 1);
      expect(find.text('Puzzle 1'), findsOneWidget);
      expect(find.text('Tap square 1 to start'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      final puzzle = puzzles.first;
      final size = puzzle.board.size;
      for (final i in solve(puzzle)) {
        await tapSquare(tester, i ~/ size, i % size, size: size);
      }
      expect(find.text('Puzzle solved!'), findsWidgets);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(Celebration.bannerTime);
      await tester.pumpAndSettle();
      expect(find.text('Puzzle 1 solved!'), findsOneWidget);
      expect(find.text('Your name'), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('puzzles_solved'), [puzzle.id]);

      await tester.tap(find.text('Next puzzle'));
      await tester.pumpAndSettle();
      expect(find.text('Puzzle 2'), findsOneWidget);
      expect(prefs.getString('puzzle'), puzzles[1].id);
    });

    testWidgets('a given square refuses the wrong move number', (tester) async {
      await startApp(tester);
      await pickPuzzle(tester, 2);
      final puzzle = puzzles[1];
      final size = puzzle.board.size;
      // Any given square other than 1 can't be the first move.
      final other = puzzle.clues.entries.firstWhere((e) => e.value != 1).key;
      await tapSquare(tester, other ~/ size, other % size, size: size);
      expect(find.text('Tap square 1 to start'), findsOneWidget);
      final start = puzzle.clues.entries.firstWhere((e) => e.value == 1).key;
      await tapSquare(tester, start ~/ size, start % size, size: size);
      expect(find.text('Move 1 / ${puzzle.board.total}'), findsOneWidget);
    });

    testWidgets('the app comes back to the puzzle, a board leaves it', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'puzzle': puzzles[2].id});
      await startApp(tester);
      expect(find.text('Puzzle 3'), findsOneWidget);

      // Picking the puzzle's own board still leaves the puzzle.
      await tester.tap(find.byTooltip('Board: ${puzzles[2].board.name}'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(puzzles[2].board.name).last);
      await tester.pumpAndSettle();
      expect(find.text("Knight's Tour"), findsOneWidget);
      expect(find.text('Undo (3)'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('puzzle'), isNull);
    });
  });

  testWidgets('sound button turns sound off and remembers it', (tester) async {
    await startApp(tester);

    await tester.tap(find.byTooltip('Sound off'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Sound on'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('sound_on'), false);
  });
}
