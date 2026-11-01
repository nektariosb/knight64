# TODO

Open issues and ideas for Knight's Tour.

## Builds

- [ ] **Windows**: release build (`flutter build windows`). Needs Visual Studio 2022 with the "Desktop development with C++" workload, and Developer Mode on.
- [ ] **Linux**: release build (`flutter build linux`). Has to be built on Linux (or WSL), with the GStreamer packages for sound.
- [ ] **Android**: release build (`flutter build apk` / `flutter build appbundle`).
  - [ ] Change the package name from `com.example.knight64` before any store release.
  - [ ] Set up a signing key (kept out of the repo).
- [ ] **Web**: release build (`flutter build web`) and choose where to host it (e.g. GitHub Pages).
- [ ] App icon for each platform (still Flutter's default). The name "Knight's Tour" is set everywhere.
- [ ] GitHub Actions: run tests and build on every push, and attach builds to releases.

## Gameplay

- [x] Closed-tour bonus: if square 64 is a knight's move from square 1, celebrate and mark the score as "closed".
- [ ] Closed-tour sound?
- [ ] Decide what else happens when you fill all 64 squares (celebration, ...).
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
- [ ] Blocked squares on bigger boards: some squares are holes; visit all the others. Holes already work (boards have a set of holes, and the solver treats them as visited); what's missing is layouts (shapes? random?) and a way to pick them.
- [ ] More boards? 7×7 (no closed tours), non-square boards like 3×4.
- [ ] Puzzle mode: some squares come pre-numbered; find a tour that matches them. Needs the solver.
- [ ] Daily challenge: same start square (and holes) for everyone, picked from the date.
- [ ] Timer?

## Info

- [x] "About the Knight's Tour" screen: how to play, open vs. closed tours, a short history, facts and numbers. Check every fact against a source before adding it.
- [ ] Show a random fact somewhere (game over screen?).

## Graphics

- [ ] Visited squares: keep the faint checker pattern showing through, or use one solid color?
- [ ] Knight icon on the current square?
- [ ] Animations (move, game over).

## Project

- [ ] Choose a license (currently TBD in the README).
