import 'package:flutter/material.dart';

import 'theme.dart';

/// How to play, open and closed tours, a little history and some facts.
///
/// The facts were checked against Wikipedia's "Knight's tour" article and
/// George Jelliss's knight's tour notes (mayhematics.com).
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const _Heading('How to play'),
              const _Point(
                'Tap any square to put the knight there. '
                'That square gets number 1.',
              ),
              const _Point(
                'The knight jumps in an L: two squares straight, '
                'then one to the side. It can jump over other squares.',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: _KnightJumps()),
              ),
              Text(
                'From the highlighted square in the middle, the knight can '
                'jump to every square with a dot.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              const _Point(
                'Visit every square exactly once. Each new square '
                'gets the next number.',
              ),
              const _Point(
                'Some boards have holes, drawn with stripes. The knight '
                "can't land on a hole, and doesn't need to visit it.",
              ),
              const _Point(
                'When the knight has nowhere left to jump, the game '
                'is over. Can you fill the whole board? On the 8×8 '
                'chessboard, that means reaching 64.',
              ),
              const _Point(
                'Made a mistake? You can undo 3 times per game, '
                'but not twice in a row.',
              ),

              const _Heading('Puzzles'),
              const _Point(
                'Tap the puzzle piece to pick a puzzle. Some squares '
                'already show a number: the knight must land there on '
                'exactly that move, and on no other move.',
              ),
              const _Point(
                'Start on square 1 and fill the board, one jump at a time. '
                'Each puzzle has only one solution.',
              ),
              const _Point(
                'In puzzles you can undo as often as you like. Solved '
                'puzzles get a tick.',
              ),

              const _Heading('Open and closed tours'),
              const _Point(
                'A path that visits every square of the board is called a '
                "knight's tour.",
              ),
              const _Point('In an open tour, the last square can be anywhere.'),
              const _Point(
                'In a closed tour, the last square is one jump away '
                'from square 1. The knight could jump back to the start '
                'and go round again, like a loop. Closed tours are harder, '
                'and rank higher in the high scores.',
              ),

              const _Heading('A little history'),
              const _Point(
                'More than 1,000 years ago, chess players in '
                "Baghdad already wrote down knight's tours. The oldest "
                'known full tour is credited to the chess master al-Adli, '
                'around the year 840.',
              ),
              const _Point(
                'Around the same time in India, the poet Rudrata '
                "hid a knight's tour of half a chessboard in a poem.",
              ),
              const _Point(
                'In 1759, the famous mathematician Leonhard Euler '
                "wrote the first math paper about the knight's tour.",
              ),
              const _Point(
                'In 1823, H. C. von Warnsdorff found a simple trick: '
                'always jump to the square with the fewest exits. It still '
                'works very well today. The "Count the exits" option shows '
                'it.',
              ),
              const _Point(
                'In the 1770s, a chess-playing machine called "the '
                'Turk" amazed people by doing the knight\'s tour on a '
                'chessboard, from any square. The secret: a person was '
                'hidden inside!',
              ),

              const _Heading('Amazing facts'),
              const _Point(
                'On the 8×8 chessboard there are 26,534,728,821,064 '
                'closed tours (about 26.5 trillion), counting each '
                'direction. Computers finished counting them in 1997.',
              ),
              const _Point(
                'With the open tours too, the 8×8 board has '
                '19,591,828,170,979,904 tours (about 19.6 quadrillion). '
                'That count was finished in 2014.',
              ),
              const _Point(
                'On the 8×8 board you can finish a tour from every '
                'square: follow a closed tour, starting wherever you like. '
                'The same goes for every board in this game except 5×5.',
              ),
              const _Point(
                'The knight always lands on the other color: '
                'light, dark, light, dark… So a board with an odd number '
                'of squares, like 5×5, can never have a closed tour.',
              ),
              const _Point(
                'The 5×5 board has 13 squares of the corners\' color and '
                '12 of the other. A tour must start and end on the color '
                'with 13, so starting anywhere else can never work.',
              ),
              const _Point(
                'On a 4×4 board there is no tour at all: the knight always '
                'gets stuck before square 16. The smallest square board '
                'with a tour is 5×5, and the smallest with a closed tour '
                'is 6×6.',
              ),
              const _Point(
                'A puzzle for number lovers: after a full tour on the 8×8 '
                'board, add up the numbers in each row and each column. In '
                '140 different tours, every row and every column adds up '
                'to 260! If the two long diagonals did too, it would be a '
                '"magic square". But a computer search in 2003 showed that '
                'no tour can do that.',
              ),
              const SizedBox(height: 24),
              Text(
                "Sources: Wikipedia, \"Knight's tour\"; George Jelliss, "
                "Knight's Tour Notes (mayhematics.com).",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// One bullet point.
class _Point extends StatelessWidget {
  const _Point(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: style),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}

/// A 5×5 board with the knight in the middle and dots where it can jump,
/// drawn like the game board.
class _KnightJumps extends StatelessWidget {
  const _KnightJumps();

  static const _size = 5;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BoardColors>()!;
    const mid = _size ~/ 2;
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: colors.border, width: 3),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: GridView.count(
        crossAxisCount: _size,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var i = 0; i < _size * _size; i++)
            Builder(
              builder: (context) {
                final dr = (i ~/ _size - mid).abs();
                final dc = (i % _size - mid).abs();
                final isKnight = dr == 0 && dc == 0;
                final isJump = (dr == 1 && dc == 2) || (dr == 2 && dc == 1);
                return ColoredBox(
                  color: isKnight
                      ? colors.current
                      : ((i ~/ _size + i % _size).isEven
                            ? colors.lightSquare
                            : colors.darkSquare),
                  child: isJump
                      ? Center(
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
                        )
                      : null,
                );
              },
            ),
        ],
      ),
    );
  }
}
