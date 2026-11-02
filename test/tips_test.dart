import 'package:flutter_test/flutter_test.dart';
import 'package:knight64/game/tips.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const small = ['A', 'B'];

  test(
    'a tip comes with every third lost game, in order, then starts over',
    () {
      final ladder = TipLadder(tips: small);
      expect(
        [for (var i = 0; i < 9; i++) ladder.gameLost()],
        [null, null, 'A', null, null, 'B', null, null, 'A'],
      );
    },
  );

  test('the count and the next tip survive a restart', () async {
    final ladder = TipLadder(tips: small);
    for (var i = 0; i < 4; i++) {
      ladder.gameLost();
    }
    await Future<void>.delayed(Duration.zero);

    final loaded = TipLadder(tips: small);
    await loaded.load();
    expect(loaded.losses, 1);
    expect(loaded.next, 1);
    loaded.gameLost();
    expect(loaded.gameLost(), 'B');
  });

  test('a saved place past the end of a shorter list starts over', () async {
    SharedPreferences.setMockInitialValues({'tip_next': 4, 'tip_losses': 2});
    final ladder = TipLadder(tips: small);
    await ladder.load();
    expect(ladder.gameLost(), 'A');
  });

  test('the list: short enough for a dialog, ends with the rule', () {
    for (final tip in allTips) {
      expect(tip.trim(), tip);
      expect(tip.length, inInclusiveRange(30, 230), reason: tip);
      expect(tip, isNot(contains('  ')), reason: tip);
    }
    expect(allTips.last, contains('Warnsdorff'));
  });
}
