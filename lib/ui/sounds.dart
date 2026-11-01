import 'package:audioplayers/audioplayers.dart';

/// Plays the game's sound effects.
class Sounds {
  final _reject = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  Future<void> reject() async {
    // Restart from the beginning if the sound is still playing.
    await _reject.stop();
    await _reject.play(AssetSource('sounds/reject.wav'));
  }

  void dispose() => _reject.dispose();
}
