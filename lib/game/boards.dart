/// A board to play on: a square grid, maybe with holes the knight can't land
/// on and doesn't need to visit.
class Board {
  const Board({
    required this.id,
    required this.name,
    required this.description,
    required this.size,
    this.holes = const {},
  });

  /// A board drawn as rows of text, one character per square: `#` is a
  /// square to visit, `.` is a hole. There must be as many rows as columns.
  Board.drawn({
    required this.id,
    required this.name,
    required this.description,
    required List<String> rows,
  }) : assert(rows.every((row) => row.length == rows.length)),
       size = rows.length,
       holes = {
         for (var r = 0; r < rows.length; r++)
           for (var c = 0; c < rows.length; c++)
             if (rows[r][c] == '.') r * rows.length + c,
       };

  /// Saved with the options and the high scores, so it must never change.
  final String id;
  final String name;
  final String description;
  final int size;

  /// Flat indexes, as in `KnightTour`.
  final Set<int> holes;

  /// Squares to visit.
  int get total => size * size - holes.length;

  /// A knight always lands on the other colour, so a closed tour needs as
  /// many light squares as dark ones. For the boards here, that's enough.
  bool get canClose {
    var light = 0;
    for (var i = 0; i < size * size; i++) {
      if (!holes.contains(i) && (i ~/ size + i % size).isEven) light++;
    }
    return light * 2 == total;
  }

  static const standard = Board(
    id: '8x8',
    name: '8×8',
    description: 'The real chessboard.',
    size: 8,
  );

  static const sizes = [
    Board(
      id: '3x3',
      name: '3×3',
      description: "A ring around a hole: the knight can't reach the middle.",
      size: 3,
      holes: {4},
    ),
    Board(
      id: '5x5',
      name: '5×5',
      description: "Tricky: start on the wrong colour and you can't finish!",
      size: 5,
    ),
    Board(id: '6x6', name: '6×6', description: 'A good warm-up.', size: 6),
    standard,
    Board(id: '10x10', name: '10×10', description: 'A long trip!', size: 10),
  ];

  /// Every shape has a tour from every square, and a closed tour (see
  /// test/boards_test.dart).
  static final shapes = [
    Board.drawn(
      id: 'cross',
      name: 'Cross',
      description: 'An 8×8 with its corners cut off.',
      rows: [
        '..####..',
        '..####..',
        '########',
        '########',
        '########',
        '########',
        '..####..',
        '..####..',
      ],
    ),
    Board.drawn(
      id: 'donut',
      name: 'Donut',
      description: 'An 8×8 with a hole in the middle.',
      rows: [
        '########',
        '########',
        '########',
        '###..###',
        '###..###',
        '########',
        '########',
        '########',
      ],
    ),
    Board.drawn(
      id: 'frame',
      name: 'Frame',
      description: 'A 10×10 with a big hole in the middle: a long way round.',
      rows: [
        '##########',
        '##########',
        '##########',
        '###....###',
        '###....###',
        '###....###',
        '###....###',
        '##########',
        '##########',
        '##########',
      ],
    ),
    Board.drawn(
      id: 'heart',
      name: 'Heart',
      description: 'With love, from the knight.',
      rows: [
        '..........',
        '.###..###.',
        '##########',
        '##########',
        '##########',
        '.########.',
        '..######..',
        '...####...',
        '....##....',
        '..........',
      ],
    ),
    Board.drawn(
      id: 'diamond',
      name: 'Diamond',
      description: 'Pointy at all four ends.',
      rows: [
        '....##....',
        '...####...',
        '..######..',
        '.########.',
        '##########',
        '##########',
        '.########.',
        '..######..',
        '...####...',
        '....##....',
      ],
    ),
    Board.drawn(
      id: 'smiley',
      name: 'Smiley',
      description: "Don't jump in the eyes!",
      rows: [
        '..######..',
        '.########.',
        '##########',
        '###.##.###',
        '##########',
        '##.####.##',
        '###....###',
        '##########',
        '.########.',
        '..######..',
      ],
    ),
    Board.drawn(
      id: 'house',
      name: 'House',
      description: 'A roof and a door.',
      rows: [
        '....##....',
        '...####...',
        '..######..',
        '.########.',
        '##########',
        '.########.',
        '.########.',
        '.########.',
        '.###..###.',
        '.###..###.',
      ],
    ),
    Board.drawn(
      id: 'tree',
      name: 'Tree',
      description: 'A fir tree on its trunk.',
      rows: [
        '....##....',
        '...####...',
        '..######..',
        '...####...',
        '..######..',
        '.########.',
        '..######..',
        '.########.',
        '.########.',
        '....##....',
      ],
    ),
  ];

  static final all = [...sizes, ...shapes];

  /// The board with [id], or the standard board if there is none.
  static Board byId(String? id) =>
      all.firstWhere((b) => b.id == id, orElse: () => standard);
}
