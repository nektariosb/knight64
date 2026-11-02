import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'fact_list.dart' as list;

/// A "Did you know?" fact, shown after some games. The list is in
/// fact_list.dart.
class Fact {
  const Fact(this.id, this.text);

  /// Saved with the facts already seen, so it must never change.
  final String id;
  final String text;
}

/// Hands out a fact every few finished games, and doesn't repeat one until
/// all have been shown. Saved on the device.
class FactDeck {
  FactDeck({List<Fact>? facts, Random? random})
    : facts = facts ?? list.facts,
      _random = random ?? Random();

  /// A fact comes with every [every]th finished game.
  static const every = 3;

  static const _gamesKey = 'fact_games';
  static const _seenKey = 'facts_seen';

  final List<Fact> facts;
  final Random _random;

  /// Finished games since the last fact.
  int games = 0;

  /// Ids of the facts shown since the deck last started over.
  Set<String> seen = {};

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    games = prefs.getInt(_gamesKey) ?? 0;
    seen = (prefs.getStringList(_seenKey) ?? []).toSet();
  }

  /// Counts a finished game. Returns a fact if it's time for one, else null.
  Fact? gameFinished() {
    games++;
    Fact? fact;
    if (games >= every) {
      games = 0;
      var unseen = facts.where((f) => !seen.contains(f.id)).toList();
      if (unseen.isEmpty) {
        seen.clear();
        unseen = facts;
      }
      fact = unseen[_random.nextInt(unseen.length)];
      seen.add(fact.id);
    }
    _save();
    return fact;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_gamesKey, games);
    await prefs.setStringList(_seenKey, seen.toList()..sort());
  }
}
