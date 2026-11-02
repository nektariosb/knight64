import 'package:shared_preferences/shared_preferences.dart';

/// Tips shown after some lost games, always in this order: each one is a
/// step closer to Warnsdorff's rule, which the last one names.
const allTips = [
  'Corners are the hardest squares to reach: on a square board, only 2 '
      'jumps lead into each one. Visit them early, before they get cut off.',
  'Squares along the edge have few exits too. Go round the outside first, '
      'and save the middle for later: it has plenty of ways in.',
  'Every square needs a way in and a way out. If an empty square has only 2 '
      "ways left and one is the knight's square, jump there now. Once the "
      'knight leaves, it has just 1 way left, so it can only be your last '
      'square.',
  'Before each jump, count the exits of every square you could jump to: how '
      "many jumps you'd have from there. The one with the fewest is usually "
      "the best pick, because it's the hardest to come back to later.",
  "Warnsdorff's rule, from 1823, sums it all up: always jump to the square "
      'with the fewest exits. It fills most boards! To see the exits, turn on '
      '"Count the exits" in Options (that counts as help).',
];

/// Hands out the next tip every few lost games, starting over after the
/// last one (a new player on the same device gets them again). Saved on the
/// device.
class TipLadder {
  TipLadder({this.tips = allTips});

  /// A tip comes with every [every]th lost game.
  static const every = 3;

  static const _lossesKey = 'tip_losses';
  static const _nextKey = 'tip_next';

  final List<String> tips;

  /// Lost games since the last tip.
  int losses = 0;

  /// Index of the next tip to show.
  int next = 0;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    losses = prefs.getInt(_lossesKey) ?? 0;
    // The list may have got shorter since it was saved.
    next = (prefs.getInt(_nextKey) ?? 0) % tips.length;
  }

  /// Counts a lost game. Returns a tip if it's time for one, else null.
  String? gameLost() {
    losses++;
    String? tip;
    if (losses >= every) {
      losses = 0;
      tip = tips[next];
      next = (next + 1) % tips.length;
    }
    _save();
    return tip;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lossesKey, losses);
    await prefs.setInt(_nextKey, next);
  }
}
