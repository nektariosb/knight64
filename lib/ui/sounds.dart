import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Plays the game's sound effects, unless the player turned sound off.
class Sounds {
  final _move = _player();
  final _reject = _player();
  final _fanfare = _player();

  static const _key = 'sound_on';

  /// Whether sounds play. Saved on the device.
  bool enabled = true;

  static AudioPlayer _player() => AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop)
    ..setPlayerMode(PlayerMode.lowLatency);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    enabled = prefs.getBool(_key) ?? true;
  }

  Future<void> toggle() async {
    enabled = !enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }

  Future<void> move() => _play(_move, 'sounds/move.wav');

  Future<void> reject() => _play(_reject, 'sounds/reject.wav');

  /// Played when the board is full; a bigger one for a closed tour.
  Future<void> fanfare({required bool closed}) =>
      _play(_fanfare, closed ? 'sounds/closed.wav' : 'sounds/complete.wav');

  Future<void> _play(AudioPlayer player, String asset) async {
    if (!enabled) return;
    // Restart from the beginning if the sound is still playing.
    await player.stop();
    await player.play(AssetSource(asset));
  }

  void dispose() {
    _move.dispose();
    _reject.dispose();
    _fanfare.dispose();
  }
}
