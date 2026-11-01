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

  static const all = [
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

  /// The board with [id], or the standard board if there is none.
  static Board byId(String? id) =>
      all.firstWhere((b) => b.id == id, orElse: () => standard);
}
