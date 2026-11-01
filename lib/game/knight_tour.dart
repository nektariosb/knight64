/// Rules and state for a single Knight's Tour game.
///
/// Squares are addressed by a flat index: `index = row * size + col`.
/// This class has no Flutter dependencies so it can be unit tested directly.
class KnightTour {
  KnightTour({this.size = 8, this.maxUndos = 3})
    : _board = List.filled(size * size, 0),
      _undosLeft = maxUndos;

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

  /// Total undos allowed per game.
  final int maxUndos;

  /// 0 = not visited, otherwise the move number (1-based).
  final List<int> _board;

  /// Visited squares in order.
  final List<int> _path = [];

  int _undosLeft;

  /// True right after an undo: undos can't be chained, so you can only take
  /// back a misclick, not walk backwards through the tour.
  bool _justUndid = false;

  int get squareCount => size * size;
  int get moveCount => _path.length;
  int get undosLeft => _undosLeft;
  int get undosUsed => maxUndos - _undosLeft;
  int? get current => _path.isEmpty ? null : _path.last;
  int? get start => _path.isEmpty ? null : _path.first;

  /// Move number on [index], or 0 if not visited yet.
  int numberAt(int index) => _board[index];

  bool get isComplete => moveCount == squareCount;

  /// The knight has moved but has nowhere left to go before filling the board.
  bool get isStuck =>
      current != null && !isComplete && legalMovesFrom(current!).isEmpty;

  bool get isOver => isComplete || isStuck;

  /// A complete tour is closed if the last square is a knight move from the first.
  bool get isClosed => isComplete && _isKnightMove(current!, start!);

  /// Still allowed when stuck, so a misclick into a dead end can be fixed.
  bool get canUndo =>
      _path.isNotEmpty && !isComplete && _undosLeft > 0 && !_justUndid;

  /// Unvisited squares reachable from [index] with one knight move.
  List<int> legalMovesFrom(int index) {
    final row = index ~/ size, col = index % size;
    return [
      for (final (dr, dc) in _jumps)
        if (_onBoard(row + dr, col + dc) &&
            _board[(row + dr) * size + col + dc] == 0)
          (row + dr) * size + col + dc,
    ];
  }

  /// Tries to visit [index]. Returns false (and changes nothing) if the move is
  /// not allowed.
  bool tryMove(int index) {
    if (isOver || _board[index] != 0) return false;
    if (current != null && !_isKnightMove(current!, index)) return false;
    _path.add(index);
    _board[index] = _path.length;
    _justUndid = false;
    return true;
  }

  /// Clears the last visited square. Returns false if undo isn't available.
  bool undo() {
    if (!canUndo) return false;
    _board[_path.removeLast()] = 0;
    _undosLeft--;
    _justUndid = true;
    return true;
  }

  void restart() {
    _board.fillRange(0, _board.length, 0);
    _path.clear();
    _undosLeft = maxUndos;
    _justUndid = false;
  }

  bool _onBoard(int row, int col) =>
      row >= 0 && row < size && col >= 0 && col < size;

  bool _isKnightMove(int from, int to) {
    final dr = (from ~/ size - to ~/ size).abs();
    final dc = (from % size - to % size).abs();
    return (dr == 1 && dc == 2) || (dr == 2 && dc == 1);
  }
}
