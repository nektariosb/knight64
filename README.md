# Knight64

A Flutter puzzle game based on the classic **Knight's Tour** problem: move a chess knight around an 8×8 board so that it visits every square exactly once.

> Status: early development.

## How to play

1. The board starts empty.
2. Tap any square to place the knight there. That square is marked **1**.
3. Tap a square that is a legal knight move (an "L" shape: two squares one way, one square the other) from your last square. It is marked with the next number, with a wood-chop sound.
4. If you tap a square that is not a knight move from your last square, or a square you have already visited, you hear a reject sound and nothing changes.
5. The goal is to fill all 64 squares, numbered 1 to 64.
6. If the knight has no legal moves left before the board is full, the game is over.

### High scores

When a game ends, you can save your score under your name. The top 10 scores are kept on the device, so friends can take turns on the same phone or PC. Tap the trophy to see the list.

Scores are ranked by squares filled. Ties are broken by: closed tour beats open tour, then fewer undos used, then whoever got there first. Once a score is saved, undo is locked for that game.

### Controls

| Button  | What it does |
|---------|--------------|
| Undo    | Clears the last square. Meant for fixing misclicks: you get 3 undos per game, and you can't undo twice in a row. |
| Restart | Clears the board so you can start a new tour. |
| ☀ / ☾   | Switches between dark and light mode (top left). Your choice is remembered. |
| 🔊 / 🔇 | Turns sound on or off (top left). Your choice is remembered. |
| 🏆      | Opens the high scores (top right). |

## Platforms

Windows, Linux, Android and web.

## Getting started

### Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) (stable channel, 3.x)
- Dart 3.x (comes with Flutter)

### Run

```bash
git clone https://github.com/nektariosb/knight64.git
cd knight64
flutter pub get
flutter run
```

To pick a platform, pass a device, for example `flutter run -d windows`, `flutter run -d linux`, `flutter run -d chrome` or `flutter run -d android`.

On Windows, building needs **Developer Mode** turned on (Settings > System > For developers), because Flutter plugins use symlinks.

On Linux, sound needs GStreamer:

```bash
sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-good
```

### Test

```bash
flutter test
```

## Project structure

```
lib/
  main.dart              App entry point
  game/knight_tour.dart  Game rules and state (board, moves, undo); no Flutter code
  game/high_scores.dart  High score ranking and saving
  ui/game_screen.dart    Main screen: status, board, buttons
  ui/board_view.dart     The chessboard and its squares
  ui/save_score_dialog.dart   Name entry when a game ends
  ui/high_scores_screen.dart  High score list
  ui/sounds.dart         Sound effects
assets/
  sounds/                Sound files
tool/
  make_sounds.py         Generates the sound effects
test/                    Unit and widget tests
```

## About the Knight's Tour

The Knight's Tour is a centuries-old chess puzzle. On an 8×8 board there are millions of possible complete tours. A tour is **closed** if the knight's last square is one knight move away from its first square, so it could loop back to the start. Otherwise it is **open**.

A popular strategy for solving it by hand is **Warnsdorff's rule**: always move to the square that has the fewest onward moves left.

## License

TBD
