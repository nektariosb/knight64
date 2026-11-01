# TODO

Open issues and ideas for Knight64.

## Builds

- [ ] **Windows**: release build (`flutter build windows`). Needs Visual Studio 2022 with the "Desktop development with C++" workload, and Developer Mode on.
- [ ] **Linux**: release build (`flutter build linux`). Has to be built on Linux (or WSL), with the GStreamer packages for sound.
- [ ] **Android**: release build (`flutter build apk` / `flutter build appbundle`).
  - [ ] Change the package name from `com.example.knight64` before any store release.
  - [ ] Set up a signing key (kept out of the repo).
- [ ] **Web**: release build (`flutter build web`) and choose where to host it (e.g. GitHub Pages).
- [ ] App icon and name for each platform.
- [ ] GitHub Actions: run tests and build on every push, and attach builds to releases.

## Gameplay

- [ ] Decide what happens when you fill all 64 squares (celebration, closed-tour bonus, ...).
- [ ] Decide whether the undo rules (3 per game, no chained undos) are right after playtesting.
- [ ] Possible extra modes: smaller boards (5×5, 6×6) or a timer.

## Graphics

- [ ] Visited squares: keep the faint checker pattern showing through, or use one solid color?
- [ ] Knight icon on the current square?
- [ ] Animations (move, game over).

## Project

- [ ] Choose a license (currently TBD in the README).
