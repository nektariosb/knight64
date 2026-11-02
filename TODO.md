# TODO

Open issues and ideas for Knight's Tour.

## Builds

- [ ] **Windows**: release build (`flutter build windows`). Needs Visual Studio 2022 with the "Desktop development with C++" workload, and Developer Mode on.
- [ ] **Linux**: release build (`flutter build linux`). Has to be built on Linux (or WSL), with the GStreamer packages for sound.
- [ ] **Android**: release build (`flutter build apk` / `flutter build appbundle`).
  - [ ] Change the package name from `com.example.knight64` before any store release.
  - [ ] Set up a signing key (kept out of the repo).
- [ ] **Web**: release build (`flutter build web`) and choose where to host it (e.g. GitHub Pages).
- [x] App icon for each platform: a knight drawn as one olive line on mist (made with Claude Design; master drawing in `tool/knight-icon.svg`). Android has an adaptive vector icon with a monochrome layer for themed icons. The name "Knight's Tour" is set everywhere.
  - [ ] Linux: the window has no icon yet (the Flutter Linux runner doesn't set one).
- [ ] GitHub Actions: run tests and build on every push, and attach builds to releases.

## Gameplay

- [x] Closed-tour bonus: if square 64 is a knight's move from square 1, celebrate and mark the score as "closed".
- [x] Full board: fanfare, confetti and a "Tour complete!" banner. Closed tour: a bigger fanfare, confetti fired from both bottom corners, and a gold "Closed tour!" banner that explains the loop. No vibration.
- [ ] Decide whether the undo rules (3 per game, no chained undos) are right after playtesting.
- [ ] Test the "Check if the board can be filled" option on a real phone: is it fast enough? (Up to about 3 s per move on a PC for the hardest positions, 200,000 search steps; 30,000 on the web.)
- [ ] Solver: could it answer more of the ~2% "Hard to tell" positions? They're early positions (moves 5–25), mostly ones that turn out lost a few moves later.
- [x] Options menu (help options off by default):
  - [x] Highlight available moves.
  - [x] Path lines while playing. Not a help: the numbers already show the route.
  - [x] Dead-square warning: mark unvisited squares that can no longer be reached.
  - [x] "Still solvable?" check, using a solver (Warnsdorff + backtracking). Gives up on about 2% of positions (shows "Hard to tell").
  - [x] Onward-move counts: each available square shows how many moves you'd have from there.
  - [x] Path lines at the end of a game (win or lose). On by default. Doesn't count as an assist.
  - [x] A game counts as "assisted" if any assist option was turned on at any point during it, even if it was turned off again. Assisted games don't go on the high-score list.
  - [x] Kid-friendly wording for this, e.g. "Only games played without help can enter the high scores."

## Modes

- [x] Board sizes: 3×3 ring (centre is a hole), 5×5, 6×6, 8×8, 10×10, each with its own high score list. On 5×5 a tour only exists from the 13 squares of the corners' colour, and there are no closed tours.
- [x] Shaped boards (holes): Cross, Donut, Frame, Heart, Diamond, Smiley, House, Tree. Each has a tour from every square and a closed tour (checked in the tests). Random holes were dropped: they'd look like a mistake and often can't be filled.
- [ ] More shapes? Ideas: star, boat, letters. Check new ones with the solver (every square needs at least 2 knight moves).
- [ ] More boards? 7×7 (no closed tours), non-square boards like 3×4.
- [x] Puzzle mode: 30 numbered puzzles (3×3 up to 10×10 and shapes) where some squares come pre-numbered; play move by move, and the knight must land on each given square at its number. Each has exactly one solution (checked in the tests). Unlimited undo, no scores, solved ones get a tick. Made by `dart run tool/make_puzzles.dart`.
  - [x] Order playtested: puzzles 10–11 (6×6, fewest numbers) are really hard, but kept where they are on purpose, so not everything is solved in half an hour.
  - [ ] More puzzles? The tool can make as many as we like.
- [ ] Daily challenge: same start square (and holes) for everyone, picked from the date. Offline only, no sharing.
- [ ] Personal bests and near misses after a game ("61! Your best is 63.", "New personal best!").
- [ ] Discovery tips: after a few lost games, a gentle hint that leads towards Warnsdorff's rule ("The corners get trapped easily. Visit them early.").
- [x] Timer: dropped.
- [x] Stats (games played, wins, losses): dropped.

## Info

- [x] "About the Knight's Tour" screen: how to play, open vs. closed tours, a short history, facts and numbers. Check every fact against a source before adding it.
- [x] "Did you know?" fact on every 3rd game-over dialog (also when a puzzle is solved), no repeats until all are seen. 101 facts in `lib/game/fact_list.dart` (knight's tour, the knight piece, chess history), each checked against a source.
  - [ ] Review the list: drop or reword facts (`facts_review.md`, same ids as in the code). Some are records that may be broken one day (C18, C25, C27–C29, C31).

## Graphics

- [x] Visited squares: keep the faint checker pattern showing through.
- [ ] Knight icon on the current square?
- [ ] Animations (move, game over). On hold: if we do them, get the art from Claude Design.

## Project

- [x] License: MIT.
