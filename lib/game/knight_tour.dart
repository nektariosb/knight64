/// Rules and state for a single Knight's Tour game.
///
/// Squares are addressed by a flat index: `index = row * size + col`.
/// [holes] are squares that aren't part of the board: the knight can't land
/// on them and doesn't need to visit them.
/// In a puzzle, [clues] gives squares their move number up front: the knight
/// must land there on exactly that move.
/// This class has no Flutter dependencies so it can be unit tested directly.
class KnightTour {
  KnightTour({
    this.size = 8,
    this.holes = const {},
    this.clues = const {},
    this.maxUndos = 3,
  }) : _board = List.filled(size * size, 0),
       _clueSquares = {
         for (final MapEntry(key: square, value: number) in clues.entries)
           number: square,
       };

  static const _jumps = [
    (-2, -1),
    (-2, 1),
    (-1, -2),
    (-1, 2),
    (1, -2),
    (1, 2),
    (2, -1),
    (2, 1),
  ];

  final int size;
  final Set<int> holes;

  /// Square -> move number, for the squares given in a puzzle.
  final Map<int, int> clues;

  /// The same, the other way round: move number -> square.
  final Map<int, int> _clueSquares;

  /// Total undos allowed per game, or null for as many as you like (and
  /// then they can be chained).
  final int? maxUndos;

  /// 0 = not visited, otherwise the move number (1-based).
  final List<int> _board;

  /// Visited squares in order.
  final List<int> _path = [];

  int _undosUsed = 0;

  /// True right after an undo: undos can't be chained, so you can only take
  /// back a misclick, not walk backwards through the tour.
  bool _justUndid = false;

  /// Squares on the grid, holes included: the range of flat indexes.
  int get squareCount => size * size;

  /// Squares to visit: every square except the holes.
  int get total => squareCount - holes.length;
  int get moveCount => _path.length;

  /// Null when undos are unlimited.
  int? get undosLeft => maxUndos == null ? null : maxUndos! - _undosUsed;
  int get undosUsed => _undosUsed;
  int? get current => _path.isEmpty ? null : _path.last;
  int? get start => _path.isEmpty ? null : _path.first;

  /// Visited squares in the order they were visited.
  List<int> get path => List.unmodifiable(_path);

  /// Move number on [index], or 0 if not visited yet.
  int numberAt(int index) => _board[index];

  bool isHole(int index) => holes.contains(index);

  /// Move number given on [index] in a puzzle, or null.
  int? clueAt(int index) => clues[index];

  /// The clues still ahead, as the solver takes them: number of jumps from
  /// the knight's square -> square to land on after that many jumps.
  Map<int, int> get cluesAhead => {
    for (final MapEntry(key: number, value: square) in _clueSquares.entries)
      if (number > moveCount) number - moveCount: square,
  };

  /// Whether move [number] may land on [index]: it must land on the square
  /// given that number, and other moves must keep off the given squares.
  bool _fitsClues(int index, int number) {
    final clue = clues[index];
    return clue == number || (clue == null && _clueSquares[number] == null);
  }

  bool get isComplete => moveCount == total;

  /// The knight has moved but has nowhere left to go before filling the board.
  bool get isStuck =>
      current != null && !isComplete && legalMovesFrom(current!).isEmpty;

  bool get isOver => isComplete || isStuck;

  /// A complete tour is closed if the last square is a knight move from the first.
  bool get isClosed => isComplete && _isKnightMove(current!, start!);

  /// Still allowed when stuck, so a misclick into a dead end can be fixed.
  bool get canUndo =>
      _path.isNotEmpty &&
      !isComplete &&
      (maxUndos == null || (undosLeft! > 0 && !_justUndid));

  /// Unvisited squares reachable from [index] with one knight move, as move
  /// [number] (by default the next move; it matters for clues).
  List<int> legalMovesFrom(int index, [int? number]) {
    number ??= moveCount + 1;
    return [
      for (final n in _neighbours(index))
        if (_board[n] == 0 && _fitsClues(n, number)) n,
    ];
  }

  /// Unvisited squares the knight can never reach again: every square a
  /// knight move away is already visited, and none of them is the knight's
  /// square. Once there is one, the board can't be filled.
  Set<int> get deadSquares {
    if (current == null) return {};
    return {
      for (var i = 0; i < squareCount; i++)
        if (_board[i] == 0 &&
            !isHole(i) &&
            !_neighbours(i).any((n) => _board[n] == 0 || n == current))
          i,
    };
  }

  /// Tries to visit [index]. Returns false (and changes nothing) if the move is
  /// not allowed.
  bool tryMove(int index) {
    if (isOver || isHole(index) || _board[index] != 0) return false;
    if (current != null && !_isKnightMove(current!, index)) return false;
    if (!_fitsClues(index, moveCount + 1)) return false;
    _path.add(index);
    _board[index] = _path.length;
    _justUndid = false;
    return true;
  }

  /// Clears the last visited square. Returns false if undo isn't available.
  bool undo() {
    if (!canUndo) return false;
    _board[_path.removeLast()] = 0;
    _undosUsed++;
    _justUndid = true;
    return true;
  }

  void restart() {
    _board.fillRange(0, _board.length, 0);
    _path.clear();
    _undosUsed = 0;
    _justUndid = false;
  }

  /// All squares a knight move away from [index], visited or not.
  Iterable<int> _neighbours(int index) sync* {
    final row = index ~/ size, col = index % size;
    for (final (dr, dc) in _jumps) {
      if (_onBoard(row + dr, col + dc)) {
        final n = (row + dr) * size + col + dc;
        if (!isHole(n)) yield n;
      }
    }
  }

  bool _onBoard(int row, int col) =>
      row >= 0 && row < size && col >= 0 && col < size;

  bool _isKnightMove(int from, int to) {
    final dr = (from ~/ size - to ~/ size).abs();
    final dc = (from % size - to % size).abs();
    return (dr == 1 && dc == 2) || (dr == 2 && dc == 1);
  }
}
