import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:knight64/game/fact_list.dart';
import 'package:knight64/game/facts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const small = [Fact('a', 'A'), Fact('b', 'B'), Fact('c', 'C')];

  /// The facts handed out over [games] finished games, nulls left out.
  List<String> play(FactDeck deck, int games) => [
    for (var i = 0; i < games; i++) ?deck.gameFinished()?.id,
  ];

  test('a fact comes with every third game', () {
    final deck = FactDeck(facts: small);
    expect(
      [for (var i = 0; i < 6; i++) deck.gameFinished() != null],
      [false, false, true, false, false, true],
    );
  });

  test('no repeats until every fact was shown, then it starts over', () {
    final deck = FactDeck(facts: small, random: Random(1));
    final first = play(deck, 9);
    expect(first.toSet(), {'a', 'b', 'c'});
    final second = play(deck, 9);
    expect(second.toSet(), {'a', 'b', 'c'});
  });

  test('the count and the facts seen survive a restart', () async {
    final deck = FactDeck(facts: small);
    final shown = play(deck, 5);
    await Future<void>.delayed(Duration.zero);

    final loaded = FactDeck(facts: small);
    await loaded.load();
    expect(loaded.games, 2);
    expect(loaded.seen, shown.toSet());
    expect(loaded.gameFinished(), isNotNull);
  });

  test('a dropped fact in the saved list does no harm', () async {
    SharedPreferences.setMockInitialValues({
      'facts_seen': ['a', 'b', 'gone'],
      'fact_games': 2,
    });
    final deck = FactDeck(facts: small);
    await deck.load();
    expect(deck.gameFinished()?.id, 'c');
    // All shown now, so the next one starts over.
    expect(play(deck, 3), hasLength(1));
  });

  test('the list: unique ids, short enough for a dialog', () {
    expect(facts.map((f) => f.id).toSet(), hasLength(facts.length));
    for (final fact in facts) {
      expect(fact.text.trim(), fact.text, reason: fact.id);
      expect(fact.text.length, inInclusiveRange(30, 230), reason: fact.id);
      expect(fact.text, isNot(contains('  ')), reason: fact.id);
    }
  });
}
