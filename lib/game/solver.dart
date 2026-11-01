import 'dart:math';
import 'dart:typed_data';

/// Answer of [canFill].
enum Fillable { yes, no, unknown }

/// Whether a knight on [current] can still visit every square that is not
/// [visited] on a [size] x [size] board (flat indexes, as in `KnightTour`).
/// In a puzzle, [clues] maps a number of jumps from now to the square the
/// knight must land on after exactly that many jumps (see
/// `KnightTour.cluesAhead`). Other jumps can't land on those squares.
///
/// Searches with Warnsdorff's rule (try squares with the fewest exits first)
/// and backtracking, skipping positions that can be ruled out early. Short
/// searches with shuffled tie-breaks are tried first, since a search that
/// went wrong early is often slower to finish than a fresh one. Gives up with
/// [Fillable.unknown] after [maxSteps] positions in total.
///
/// Takes one record so it can be passed straight to Flutter's `compute`.
Fillable canFill(
  ({
    int size,
    List<bool> visited,
    int current,
    Map<int, int> clues,
    int maxSteps,
  })
  args,
) {
  final search = _Search(args.size, args.visited, args.current, args.clues);
  if (!search.parityOk(args.current)) return Fillable.no;
  var budget = 2000, used = 0;
  while (true) {
    budget = min(budget, args.maxSteps - used);
    try {
      return search.run(args.current, budget) ? Fillable.yes : Fillable.no;
    } on _GaveUp {
      used += budget;
      if (used >= args.maxSteps) return Fillable.unknown;
      budget *= 2;
      search.shuffle();
    }
  }
}

/// How many ways there are to finish the tour, as for [canFill], counting
/// no further than [limit]. Used to check that a puzzle has exactly one
/// solution (limit 2). Null if it gave up after [maxSteps] positions.
int? countTours(
  ({
    int size,
    List<bool> visited,
    int current,
    Map<int, int> clues,
    int limit,
    int maxSteps,
  })
  args,
) {
  final search = _Search(args.size, args.visited, args.current, args.clues);
  if (!search.parityOk(args.current)) return 0;
  try {
    search.run(args.current, args.maxSteps, limit: args.limit);
    return search.found;
  } on _GaveUp {
    return null;
  }
}

class _GaveUp implements Exception {
  const _GaveUp();
}

class _Search {
  _Search(this.size, List<bool> visited, int current, this.clues)
    : visited = List.of(visited),
      neighbours = [
        for (var i = 0; i < size * size; i++) _knightMoves(i, size),
      ],
      clueSquares = Uint8List(size * size) {
    for (var i = 0; i < visited.length; i++) {
      if (visited[i]) _bits[i ~/ 30] ^= 1 << (i % 30);
    }
    for (final square in clues.values) {
      clueSquares[square] = 1;
      _distances[square] = _distancesFrom(square, current);
    }
  }

  final int size;
  final List<bool> visited;
  final List<List<int>> neighbours;

  /// Jumps from the starting square -> square to land on after them.
  final Map<int, int> clues;

  /// 1 on squares in [clues], so other jumps can't land there.
  final Uint8List clueSquares;

  /// Fewest jumps from each clue square to every square, through squares
  /// that were free at the start.
  final _distances = <int, List<int>>{};

  int _steps = 0, _maxSteps = 0;

  /// Jumps the tour still had to make when the search started.
  int _startRemaining = 0;

  /// Finished tours found, and how many to look for.
  int found = 0, _limit = 1;

  /// The visited squares as bits, 30 per word (so it also works on the web,
  /// where ints are smaller). Four words cover boards up to 10x10.
  final _bits = List.filled(4, 0);

  /// Positions (visited squares + knight square) already proven to fail.
  /// The same position is often reached by different move orders.
  final _failed = <(int, int, int, int, int)>{};

  /// Small random amounts that break ties differently on each try.
  late var _noise = List.filled(visited.length, 0.0);
  final _random = Random(64);

  /// The square the tour must end on, if the quick checks found one.
  int? _lastSquare;

  static List<int> _knightMoves(int index, int size) {
    final row = index ~/ size, col = index % size;
    return [
      for (final (dr, dc) in const [
        (-2, -1),
        (-2, 1),
        (-1, -2),
        (-1, 2),
        (1, -2),
        (1, 2),
        (2, -1),
        (2, 1),
      ])
        if (row + dr >= 0 &&
            row + dr < size &&
            col + dc >= 0 &&
            col + dc < size)
          (row + dr) * size + col + dc,
    ];
  }

  /// Breadth-first search from [from] through the free squares (and the
  /// knight's square). Squares it can't reach get a huge distance.
  List<int> _distancesFrom(int from, int current) {
    final distances = List.filled(visited.length, 1 << 20);
    distances[from] = 0;
    final queue = [from];
    for (var i = 0; i < queue.length; i++) {
      final square = queue[i];
      for (final n in neighbours[square]) {
        if ((visited[n] && n != current) || distances[n] <= distances[square]) {
          continue;
        }
        distances[n] = distances[square] + 1;
        queue.add(n);
      }
    }
    return distances;
  }

  int _colour(int index) => (index ~/ size + index % size) % 2;

  int get _remaining => visited.where((v) => !v).length;

  /// A knight always changes colour, so the remaining squares must be split
  /// between the colours the way the jumps alternate.
  bool parityOk(int current) {
    final other = [
      for (var i = 0; i < visited.length; i++)
        if (!visited[i] && _colour(i) != _colour(current)) i,
    ].length;
    return other == (_remaining + 1) ~/ 2;
  }

  void shuffle() {
    _noise = [for (final _ in visited) _random.nextDouble()];
  }

  /// Searches until [limit] tours are found (true) or every way has been
  /// tried (false). [found] says how many were found.
  bool run(int current, int maxSteps, {int limit = 1}) {
    _steps = 0;
    _maxSteps = maxSteps;
    found = 0;
    _limit = limit;
    _startRemaining = _remaining;
    return _search(current, _startRemaining);
  }

  void _setVisited(int index, bool value) {
    visited[index] = value;
    _bits[index ~/ 30] ^= 1 << (index % 30);
  }

  /// Unvisited squares next to [index].
  int _exits(int index) => neighbours[index].where((n) => !visited[n]).length;

  /// Squared distance between two squares.
  int _distance(int a, int b) {
    final dr = a ~/ size - b ~/ size, dc = a % size - b % size;
    return dr * dr + dc * dc;
  }

  /// How far [index] is from where the tour should stay away from for now:
  /// the square it must end on, or else the centre. Further is tried first.
  double _away(int index) {
    final last = _lastSquare;
    if (last != null) return _distance(index, last).toDouble();
    final mid = (size - 1) / 2;
    final dr = index ~/ size - mid, dc = index % size - mid;
    return dr * dr + dc * dc;
  }

  /// Every clue square still ahead must be close enough to reach in time.
  bool _cluesInReach(int pos, int jumps) {
    for (final MapEntry(key: at, value: square) in clues.entries) {
      if (at > jumps && _distances[square]![pos] > at - jumps) return false;
    }
    return true;
  }

  bool _search(int pos, int remaining) {
    if (remaining == 0) return ++found >= _limit;
    if (++_steps > _maxSteps) throw const _GaveUp();
    final jumps = _startRemaining - remaining;
    if (!_cluesInReach(pos, jumps)) return false;
    final key = (_bits[0], _bits[1], _bits[2], _bits[3], pos);
    if (_failed.contains(key)) return false;

    final foundBefore = found;
    final allowed = _allowedMoves(pos, remaining, jumps);
    if (allowed != null) {
      final moves = [
        for (final n in allowed) (square: n, exits: _exits(n), away: _away(n)),
      ];
      moves.sort((a, b) {
        if (a.exits != b.exits) return a.exits.compareTo(b.exits);
        return (b.away + _noise[b.square]).compareTo(a.away + _noise[a.square]);
      });
      for (final move in moves) {
        _setVisited(move.square, true);
        try {
          if (_search(move.square, remaining - 1)) return true;
        } finally {
          _setVisited(move.square, false);
        }
      }
    }
    // Only reached when every move was searched to the end, so it's proven
    // that no tour, or no other tour, goes through here. A tour found here
    // could be found again through another move order, so that's not a fail.
    if (found == foundBefore) _failed.add(key);
    return false;
  }

  /// Quick checks that rule out many positions without searching them.
  /// Returns the knight's moves that are still worth trying, or null if the
  /// position can't be filled. [jumps] were made since the search started.
  List<int>? _allowedMoves(int pos, int remaining, int jumps) {
    final next = neighbours[pos];
    // A square with a single way in or out has to be the last square of the
    // tour, and there is only one last square.
    _lastSquare = null;
    for (var i = 0; i < visited.length; i++) {
      if (visited[i]) continue;
      final exits = _exits(i);
      if (exits == 0) return remaining == 1 && next.contains(i) ? [i] : null;
      if (exits == 1 && !next.contains(i)) {
        if (_lastSquare != null) return null;
        _lastSquare = i;
      }
    }
    // In a puzzle, the last square may be given.
    final lastClue = clues[_startRemaining];
    if (lastClue != null) {
      if (_lastSquare != null && _lastSquare != lastClue) return null;
      _lastSquare = lastClue;
    }
    if (!_forcedLinks.check(pos, remaining)) return null;
    final forcedLast = _forcedLinks.lastSquare;
    if (forcedLast != null &&
        _lastSquare != null &&
        forcedLast != _lastSquare) {
      return null;
    }
    _lastSquare ??= forcedLast;
    if (!_bridges.check(pos, _lastSquare, remaining)) return null;
    final moves = _forcedLinks.movesFrom(pos);
    if (clues.isEmpty) return moves;
    // The next square may be given; otherwise keep off the given squares.
    final clue = clues[jumps + 1];
    if (clue != null) return moves.contains(clue) ? [clue] : null;
    return [
      for (final m in moves)
        if (clueSquares[m] == 0) m,
    ];
  }

  // Reused at every position, to save allocating them each time.
  late final _forcedLinks = _ForcedLinks(this);
  late final _bridges = _Bridges(this);
}

/// Works out which jumps the rest of the tour is forced to make.
///
/// Think of the tour as a chain through the knight's square and all the
/// unvisited squares. Every square in the middle of the chain is joined to
/// two others; the knight's square and the last square to just one. To make
/// that uniform, an extra "end" point is joined to the knight's square and
/// to the last square, closing the chain into a loop. Now every point has
/// exactly two links in the loop.
///
/// So a point with only two possible links must use both, and a point that
/// already has two links can't use any other. Each conclusion can force or
/// rule out links elsewhere, so this repeats until nothing changes. The
/// position is lost if a point is left with fewer than two possible links,
/// or forced links close a loop that leaves points out.
class _ForcedLinks {
  _ForcedLinks(this.search)
    : n = search.visited.length,
      links = Uint8List(search.visited.length * search.visited.length),
      endLinks = Uint8List(search.visited.length),
      forced = Uint8List(search.visited.length + 1),
      open = Uint8List(search.visited.length + 1),
      group = Int32List(search.visited.length + 1),
      groupSize = Int32List(search.visited.length + 1);

  final _Search search;
  final int n;

  /// The knight's square.
  var pos = 0;
  final _queue = <int>[];

  /// Index of the extra end point.
  int get end => n;

  // Link states.
  static const _possible = 0, _forced = 1, _ruledOut = 2;

  /// State of the link between two squares, at `[min * n + max]`.
  final Uint8List links;

  /// State of the link between each square and the end point.
  final Uint8List endLinks;

  /// Number of forced and still possible links of each point.
  final Uint8List forced, open;

  /// Groups of points already chained together by forced links.
  final Int32List group, groupSize;

  var _points = 0;

  /// Set once forced links close the full loop.
  var _complete = false;

  bool _inPlay(int i) => i == pos || !search.visited[i];

  int _find(int i) {
    while (group[i] != i) {
      group[i] = group[group[i]];
      i = group[i];
    }
    return i;
  }

  int _index(int v, int w) => v < w ? v * n + w : w * n + v;

  int _state(int v, int w) {
    if (v == end) return endLinks[w];
    if (w == end) return endLinks[v];
    return links[_index(v, w)];
  }

  void _set(int v, int w, int state) {
    if (v == end) {
      endLinks[w] = state;
    } else if (w == end) {
      endLinks[v] = state;
    } else {
      links[_index(v, w)] = state;
    }
  }

  /// Forces or rules out the link v-w if it's still possible. Returns false
  /// if that closes a loop that's too short.
  bool _decide(int v, int w, int decision) {
    if (_state(v, w) != _possible) return true;
    _queue.add(w);
    if (decision == _forced) return _force(v, w);
    _ruleOut(v, w);
    return true;
  }

  /// Marks the link v-w as forced. Returns false on a loop that's too short.
  bool _force(int v, int w) {
    _set(v, w, _forced);
    open[v]--;
    open[w]--;
    forced[v]++;
    forced[w]++;
    final a = _find(v), b = _find(w);
    if (a == b) {
      if (groupSize[a] != _points) return false;
      _complete = true;
      return true;
    }
    group[a] = b;
    groupSize[b] += groupSize[a];
    return true;
  }

  void _ruleOut(int v, int w) {
    _set(v, w, _ruledOut);
    open[v]--;
    open[w]--;
  }

  bool check(int pos, int remaining) {
    this.pos = pos;
    links.fillRange(0, links.length, _possible);
    endLinks.fillRange(0, n, _possible);
    forced.fillRange(0, n + 1, 0);
    open.fillRange(0, n + 1, 0);
    _complete = false;
    _queue
      ..clear()
      ..add(end);
    for (var i = 0; i <= n; i++) {
      group[i] = i;
      groupSize[i] = 1;
    }
    for (var i = 0; i < n; i++) {
      if (!_inPlay(i)) continue;
      _queue.add(i);
      for (final w in search.neighbours[i]) {
        if (_inPlay(w)) open[i]++;
      }
      // The end point can be linked to any square, the knight's included.
      open[i]++;
      open[end]++;
    }
    _points = remaining + 2;
    // The loop runs from the end point to the knight: that link is certain.
    if (!_force(end, pos)) return false;

    while (_queue.isNotEmpty) {
      final v = _queue.removeLast();
      final have = forced[v], could = open[v];
      if (have > 2 || have + could < 2) return false;
      if (could == 0 || _complete) continue;
      final int decision;
      if (have == 2) {
        decision = _ruledOut;
      } else if (have + could == 2) {
        decision = _forced;
      } else {
        continue;
      }
      if (v == end) {
        for (var w = 0; w < n; w++) {
          if (_inPlay(w) && !_decide(v, w, decision)) return false;
        }
      } else {
        for (final w in search.neighbours[v]) {
          if (_inPlay(w) && !_decide(v, w, decision)) return false;
        }
        if (!_decide(v, end, decision)) return false;
      }
    }
    return true;
  }

  /// The square the tour is forced to end on, if any.
  int? get lastSquare {
    for (var i = 0; i < n; i++) {
      if (i != pos && _inPlay(i) && endLinks[i] == _forced) return i;
    }
    return null;
  }

  /// Unvisited squares the knight can jump to from [from] without breaking
  /// a forced link.
  List<int> movesFrom(int from) {
    final moves = <int>[];
    for (final w in search.neighbours[from]) {
      if (search.visited[w]) continue;
      final state = links[_index(from, w)];
      if (state == _forced) return [w];
      if (state == _possible) moves.add(w);
    }
    return moves;
  }
}

/// Looks for bridge squares among the knight and the unvisited squares: a
/// square whose removal cuts off part of the board. The knight can pass a
/// bridge only once, so the part beyond it is where the tour must end. That
/// rules out two separate cut-off parts, or a forced last square outside one.
///
/// This is a depth-first search that tracks how far back each square's
/// subtree can reach (Tarjan's articulation point algorithm). A subtree that
/// can't reach above its parent is cut off by that parent.
class _Bridges {
  _Bridges(this.search)
    : order = Int32List(search.visited.length),
      low = Int32List(search.visited.length);

  final _Search search;

  /// The knight's square, where the search starts.
  var root = 0;
  int? lastSquare;

  /// Order in which the depth-first search found each square, or -1.
  final Int32List order;

  /// Earliest search order each square's subtree links back to.
  final Int32List low;
  var _count = 0;

  /// Search order range [start, end) of the area the tour must end in. The
  /// cut-off areas found so far must all hold it.
  var _endStart = 0, _endEnd = 0;
  var _ok = true;

  bool _open(int i) => i == root || !search.visited[i];

  bool check(int root, int? lastSquare, int remaining) {
    this.root = root;
    this.lastSquare = lastSquare;
    order.fillRange(0, order.length, -1);
    _count = 0;
    _endStart = 0;
    _endEnd = 1 << 30;
    _ok = true;
    var children = 0;
    order[root] = low[root] = _count++;
    for (final n in search.neighbours[root]) {
      if (_open(n) && order[n] == -1) {
        children++;
        _visit(n);
      }
    }
    // The knight must be able to reach every square, all from one side.
    return _ok && children == 1 && _count == remaining + 1;
  }

  void _visit(int v) {
    order[v] = low[v] = _count++;
    for (final n in search.neighbours[v]) {
      if (!_open(n)) continue;
      if (order[n] == -1) {
        final start = _count;
        _visit(n);
        if (low[n] < low[v]) low[v] = low[n];
        // The subtree of n is cut off by v: the tour must end inside it.
        if (low[n] >= order[v]) _mustEndIn(start, _count);
      } else if (order[n] < low[v]) {
        low[v] = order[n];
      }
    }
  }

  /// The subtree in search order [start, end) is finished, so a square not
  /// found by now (order -1) is outside it.
  void _mustEndIn(int start, int end) {
    // Subtrees are either nested or apart. Keep the innermost one; two apart
    // can't both hold the end.
    if (start >= _endStart && end <= _endEnd) {
      _endStart = start;
      _endEnd = end;
    } else if (start > _endStart || end < _endEnd) {
      _ok = false;
    }
    final last = lastSquare;
    if (last != null && (order[last] < start || order[last] >= end)) {
      _ok = false;
    }
  }
}
