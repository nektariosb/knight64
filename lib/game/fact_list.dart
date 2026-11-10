import 'facts.dart';

/// The facts shown after a game, each checked against a source (Wikipedia,
/// George Jelliss's Knight's Tour Notes, OEIS, MathWorld, Dudeney's
/// "Amusements in Mathematics", chess.com and others).
///
/// Ids are saved with the facts already seen, so never reuse one for a
/// different fact. Dropping a fact is fine.
const facts = [
  // The knight's tour.
  Fact(
    'A1',
    'Around the 1300s, the Indian poet Vedanta Desika wrote two verses of 32 '
        'letters each. Read the first verse in knight\'s-tour order on a 4×8 '
        'board, and you get the second!',
  ),
  Fact(
    'A2',
    'About 400 years ago, the Indian scholar Bhat Nilakantha wrote down '
        'closed tours that look the same when you turn the board. That was '
        'long before Euler.',
  ),
  Fact(
    'A3',
    'A tour by the mathematician Abraham de Moivre, printed in 1725, runs '
        'around the edges first and fills the middle last. Try it: edge '
        'squares are the hardest to reach later!',
  ),
  Fact(
    'A4',
    "The first book to draw knight's tours as lines, instead of numbering "
        'the squares, was printed in Bologna, Italy, in 1766.',
  ),
  Fact(
    'A5',
    "In 1771, the mathematician Vandermonde made a knight's tour in 3D, "
        'through all 64 cells of a 4×4×4 cube.',
  ),
  Fact(
    'A6',
    'Euler joined four copies of a 5×5 tour into one tour of a 10×10 board, '
        'with the same pattern in all four quarters.',
  ),
  Fact(
    'A7',
    "Peter Mark Roget, who made the famous word book Roget's Thesaurus, "
        "also wrote about knight's tours. In 1840 he published a quick way to "
        'make one.',
  ),
  Fact(
    'A8',
    "The first knight's tour whose rows and columns all add up to the same "
        'number was made by William Beverley in 1847.',
  ),
  Fact(
    'A9',
    'The oldest known tour like that on a board bigger than 8×8 is a 12×12 '
        'tour. It is credited to the Rajah (king) of Mysore in India, in the '
        '1800s.',
  ),
  Fact(
    'A10',
    'A tour where the rows, the columns and both long diagonals all add up '
        "to the same number can't be done on 8×8. The first ones were found "
        'in 1962, on boards 16×16 and bigger.',
  ),
  Fact(
    'A11',
    'In 2003, Awani Kumar from India found the first 12×12 tours where rows, '
        'columns and both diagonals all add up to the same number.',
  ),
  Fact(
    'A12',
    'In 1917, puzzle writer Henry Dudeney asked for an 8×8 tour where every '
        'row, column and both diagonals add up to 260. He thought it '
        "couldn't be done. Computers proved him right in 2003.",
  ),
  Fact(
    'A13',
    'One of the oldest chess puzzles, from 1512, uses a 3×3 board: two white '
        'and two black knights in the corners must swap places. It takes at '
        'least 16 moves.',
  ),
  Fact(
    'A14',
    'On a 3×3 board, a knight can never reach the middle square. The other '
        '8 squares make one big loop, which is why our 3×3 board has a hole '
        'in the middle.',
  ),
  Fact(
    'A15',
    "The 4×4 board has no knight's tour, but the smaller 3×4 board does. "
        'There are 16 of them, counting each direction.',
  ),
  Fact(
    'A16',
    'Henry Dudeney put a chessboard on each of the 6 faces of a cube. A '
        'knight can tour all 384 squares and land back where it began.',
  ),
  Fact(
    'A17',
    "The 5×5 board has 1,728 knight's tours, counting each direction.",
  ),
  Fact(
    'A18',
    "The 6×6 board has 6,637,920 knight's tours. The 7×7 board has "
        '165,575,218,320!',
  ),
  Fact(
    'A19',
    'The 6×6 board has 9,862 closed tours. They were first counted in 1964.',
  ),
  Fact(
    'A20',
    'In 1991, Allen Schwenk found exactly which rectangle boards have a '
        'closed tour. For example, 3×4, 3×6 and 3×8 have none, but 3×10 '
        'does!',
  ),
  Fact(
    'A21',
    'A knight\'s tour is a famous example of a "Hamiltonian path": a route '
        'that visits every point exactly once. It is named after the Irish '
        'mathematician William Rowan Hamilton.',
  ),
  Fact(
    'A22',
    "Warnsdorff's trick finds a tour on most boards, but it can get stuck "
        'on boards bigger than 76×76.',
  ),
  Fact(
    'A23',
    'Computers can find knight\'s tours with a "neural network", a program '
        'loosely modeled on the brain.',
  ),
  Fact(
    'A24',
    'For a giant board, a computer can cut it into small pieces, find a '
        'tour on each, and join them together. This is called "divide and '
        'conquer".',
  ),
  Fact(
    'A25',
    'The French writer Georges Perec pictured a Paris apartment building as '
        "a 10×10 grid. A knight's tour chose the order of the chapters of his "
        '1978 novel.',
  ),
  Fact(
    'A26',
    "Chess master George Koltanowski did knight's tours on stage without "
        'looking. The audience wrote words in the squares, and he called out '
        'each one as the knight landed there. At 80, he did 192 squares at '
        'once!',
  ),
  Fact(
    'A27',
    'Over 100 years ago, the English chess master Blackburne often ended his '
        "blindfold chess shows with a knight's tour.",
  ),
  Fact(
    'A28',
    'In a 2010 World Championship game, Viswanathan Anand made 13 knight '
        "moves in a row. Fans joked that he was trying to do a knight's tour.",
  ),
  Fact(
    'A29',
    "Mathematicians even study knight's tours on boards with 4, 5 or more "
        'dimensions, which nobody can draw!',
  ),

  // The knight.
  Fact(
    'B1',
    'The knight is the only chess piece that can jump over other pieces.',
  ),
  Fact(
    'B2',
    'At the very start of a game, only knights and pawns can move. Every '
        'other piece is boxed in!',
  ),
  Fact(
    'B3',
    'White has 20 possible first moves: 16 pawn moves and 4 knight moves.',
  ),
  Fact(
    'B4',
    'Knight to f3 is the third most played first move in chess, after the '
        'pawn moves e4 and d4.',
  ),
  Fact(
    'B5',
    'In chess notation the knight is written N, because K was already taken '
        'by the king. Old books wrote Kt.',
  ),
  Fact(
    'B6',
    'In German the knight is called Springer, which means "jumper". That\'s '
        'why chess puzzle makers often write it as S.',
  ),
  Fact(
    'B7',
    'In Greek the knight is called ίππος (horse), and many people just say '
        'άλογο. Its letter is Ι, and its move has the shape of the letter Γ.',
  ),
  Fact(
    'B8',
    'In many languages the knight is simply a horse: caballo in Spanish, '
        "cavallo in Italian, kon' in Russian, at in Turkish.",
  ),
  Fact(
    'B9',
    'In Hungarian the knight can be called a huszár, a horse soldier. In '
        "Sicilian slang it's a donkey!",
  ),
  Fact(
    'B10',
    'A knight in the middle of the board can jump to 8 squares, but a '
        'knight in a corner has only 2.',
  ),
  Fact(
    'B11',
    'Chess players say "A knight on the rim is dim", because a knight on '
        'the edge reaches fewer squares. Nobody knows who first said it.',
  ),
  Fact(
    'B12',
    'The French say "Cavalier au bord, cavalier mort": a knight on the edge '
        'is a dead knight.',
  ),
  Fact(
    'B13',
    'On an empty 8×8 board, a knight can reach any square in at most 6 '
        'moves. Only corner to opposite corner needs all 6.',
  ),
  Fact(
    'B14',
    'A knight in the corner needs 4 moves to reach the square diagonally '
        'next to it!',
  ),
  Fact('B15', 'A knight is worth about 3 pawns, the same as a bishop.'),
  Fact(
    'B16',
    'Knights are strong in crowded positions, because they can hop over the '
        'jam while other pieces get stuck.',
  ),
  Fact(
    'B17',
    "When a knight attacks two pieces at once, it's called a fork. A fork "
        'of the king and queen together is called a "family fork" or "royal '
        'fork".',
  ),
  Fact(
    'B18',
    'A knight can attack a queen without being attacked back, because the '
        "queen can't move like a knight.",
  ),
  Fact(
    'B19',
    'In a "smothered mate", the king is boxed in by its own pieces and a '
        'knight jumps in to checkmate it. It was already in a chess book from '
        '1497.',
  ),
  Fact(
    'B20',
    'In the Légal Trap, from Paris in the 1700s, White gives away the queen '
        'on purpose and checkmates on move 7.',
  ),
  Fact(
    'B21',
    "A king and two knights can't force checkmate against a lone king. The "
        'other player has to make a mistake.',
  ),
  Fact(
    'B22',
    'King, bishop and knight can checkmate a lone king, but it can take 33 '
        "moves and it's tricky. Even grandmasters have failed to do it in real "
        'games!',
  ),
  Fact(
    'B23',
    "A pawn that reaches the other side doesn't have to become a queen. In "
        'the Lasker Trap, Black wins by turning a pawn into a knight on move '
        '7!',
  ),
  Fact(
    'B24',
    "The knight's move is the oldest in chess. It has stayed the same for "
        'about 1,500 years, while other pieces changed.',
  ),
  Fact(
    'B25',
    'In Chinese chess the horse moves almost like our knight, but it can\'t '
        'jump. A piece right next to it blocks it, which is called "hobbling '
        'the horse\'s leg".',
  ),
  Fact(
    'B26',
    'In Japanese chess (shogi) the knight can only jump forward, so it has '
        'just 2 possible moves.',
  ),
  Fact(
    'B27',
    'The knight is thought to be the hardest chess piece to make. In Thai '
        "chess sets, it's the biggest piece and is carved by hand.",
  ),
  Fact(
    'B28',
    'The horse-head knight in most chess sets comes from the Staunton design '
        'of 1849. It is thought to be copied from the horses of the Parthenon '
        'in Athens.',
  ),
  Fact(
    'B29',
    'World champion Emanuel Lasker gave beginners a rule: bring your knights '
        'out before both of your bishops.',
  ),
  Fact(
    'B30',
    'A knight planted deep in enemy land, protected by a pawn, can be worth '
        'about as much as a rook!',
  ),
  Fact(
    'B31',
    'World champion Capablanca played a bigger chess with two extra pieces: '
        'the archbishop (bishop + knight) and the chancellor (rook + knight).',
  ),

  // Chess history.
  Fact(
    'C1',
    'Chess grew out of an Indian game called chaturanga, first clearly '
        'mentioned in the 6th century.',
  ),
  Fact(
    'C2',
    'Chaturanga means "four parts", after the four parts of an old army: '
        'elephants, chariots, horsemen and foot soldiers. The knight comes '
        'from the horsemen.',
  ),
  Fact(
    'C3',
    'The first chessboards in India had 64 squares, all of one color. The '
        'checkered pattern came later, in Europe.',
  ),
  Fact(
    'C4',
    '"Checkmate" comes from the Persian "shāh māt", often translated as '
        '"the king is helpless".',
  ),
  Fact(
    'C5',
    'The rook\'s name comes from the Persian word "rukh", which means '
        'chariot.',
  ),
  Fact(
    'C6',
    'Long ago the queen was weak: she could move only one square '
        'diagonally. Around 1500 in Spain she got her powerful move, and '
        'people called the new game "Mad Queen Chess".',
  ),
  Fact(
    'C7',
    'The bishop used to be an elephant! In Arabic the piece is still called '
        '"fil", which means elephant.',
  ),
  Fact(
    'C8',
    'Castling is the only move in chess where two pieces move at once. '
        "Today's rule was settled in France in 1620.",
  ),
  Fact(
    'C9',
    "Pawns couldn't always move two squares on their first move. That rule "
        'was added later to speed games up.',
  ),
  Fact(
    'C10',
    '"En passant" is French for "in passing". "J\'adoube" means "I adjust": '
        'you say it before you straighten a piece, so nobody thinks you have '
        'to move it.',
  ),
  Fact(
    'C11',
    'Touch-move rule: if you touch one of your pieces on purpose, you must '
        'move it if you can.',
  ),
  Fact(
    'C12',
    'In 1831, 78 chess pieces about 850 years old were found on the Isle of '
        "Lewis in Scotland. They're carved from walrus ivory, and some rooks "
        'are warriors biting their shields!',
  ),
  Fact(
    'C13',
    'The board always has a light square in each player\'s right-hand '
        'corner. Remember: "light on the right".',
  ),
  Fact(
    'C14',
    "White hasn't always moved first! In the 1800s players could pick. One "
        'of the first written rules that White starts is from 1880.',
  ),
  Fact(
    'C15',
    'Moving first is a small advantage: White scores about 52 to 56 '
        'percent.',
  ),
  Fact(
    'C16',
    'Stalemate is a draw. Long ago, some places counted it as a win for the '
        'player who caused it!',
  ),
  Fact(
    'C17',
    'After 50 moves with no capture and no pawn move, a player can claim a '
        'draw. This rule first appeared in a book by Ruy López in 1561.',
  ),
  Fact(
    'C18',
    'The longest tournament game ever was played in Belgrade in 1989: 269 '
        'moves, more than 20 hours, and a draw!',
  ),
  Fact(
    'C19',
    'The quickest possible checkmate takes just two moves each. It\'s called '
        '"Fool\'s Mate".',
  ),
  Fact(
    'C20',
    'After just one move each, there are already 400 possible positions. '
        'There are more possible chess games than atoms in the universe!',
  ),
  Fact(
    'C21',
    'The first international chess tournament was in London in 1851. Adolf '
        'Anderssen of Germany won it.',
  ),
  Fact(
    'C22',
    'Chess clocks were first used at a London tournament in 1883. When time '
        'runs out, a little "flag" on the clock falls.',
  ),
  Fact(
    'C23',
    'Bobby Fischer invented a chess clock that adds a little time after '
        'every move. Most tournaments use his idea today.',
  ),
  Fact(
    'C24',
    'Wilhelm Steinitz became the first official World Chess Champion in '
        '1886. Emanuel Lasker held the title longest: 27 years!',
  ),
  Fact(
    'C25',
    'In 2024, Gukesh Dommaraju of India became the youngest undisputed '
        'world champion ever, at 18.',
  ),
  Fact(
    'C26',
    "Vera Menchik was the first Women's World Chess Champion, from 1927 to "
        '1944. Strong men she beat were jokingly called the "Vera Menchik '
        'Club".',
  ),
  Fact(
    'C27',
    'The Grandmaster title was first given in 1950, to 27 players. Today '
        'there are about 2,000 grandmasters.',
  ),
  Fact(
    'C28',
    'The youngest grandmaster ever is Abhimanyu Mishra of the USA, at 12 '
        'years old in 2021.',
  ),
  Fact(
    'C29',
    'In 2024, 8-year-old Ashwath Kaushik beat a grandmaster in a tournament '
        'game. The oldest known player to do it was 82!',
  ),
  Fact(
    'C30',
    'Judit Polgár of Hungary is seen as the strongest female player of all '
        'time. At 15 she became the youngest grandmaster up to then, beating '
        "Bobby Fischer's record.",
  ),
  Fact(
    'C31',
    'Magnus Carlsen became a grandmaster at 13. His rating of 2,882 in 2014 '
        'is the highest ever.',
  ),
  Fact(
    'C32',
    "At the 1988 Chess Olympiad, Hungary's teenage team won the women's "
        'event with all three Polgár sisters. Judit was only 12!',
  ),
  Fact(
    'C33',
    'The Chess Olympiad is a team event for countries, held every two '
        'years. Greece has played in it since 1950.',
  ),
  Fact(
    'C34',
    'The Greek word σκάκι comes from the Italian "scacchi". That word goes '
        'back to the Persian "shāh", meaning king.',
  ),
  Fact(
    'C35',
    'In Greek, the bishop is αξιωματικός (officer) and the rook is πύργος '
        '(tower).',
  ),
  Fact(
    'C36',
    'In the Middle Ages, Greek speakers played an older form of chess called '
        'ζατρίκιον (zatrikion).',
  ),
  Fact(
    'C37',
    'FIDE, the World Chess Federation, was founded in Paris on July 20, '
        "1924. That's why World Chess Day is July 20. Its motto \"Gens una "
        'sumus" means "We are one family".',
  ),
  Fact(
    'C38',
    'In 1770 a "chess robot" called the Turk amazed Europe and played '
        'Napoleon and Benjamin Franklin. A person was hidden inside!',
  ),
  Fact(
    'C39',
    'In 1948, Alan Turing helped write one of the first chess programs. No '
        'computer could run it yet, so he worked out its moves by hand, up to '
        '30 minutes per move.',
  ),
  Fact(
    'C40',
    "In 1997, IBM's computer Deep Blue beat world champion Garry Kasparov in "
        'a match, 3½ to 2½.',
  ),
  Fact(
    'C41',
    'In 2017, a program called AlphaZero learned chess only from the rules, '
        'by playing against itself. After four hours it was stronger than the '
        'best chess programs.',
  ),
];
