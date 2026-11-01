import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Green/olive palette.
const _forest = Color(0xFF37664A);
const _pine = Color(0xFF26332B);
const _sage = Color(0xFFAFCCBB);
const _mint = Color(0xFFA8FFCB);
const _olive = Color(0xFF7D8F5C);
const _night = Color(0xFF1B231E);
const _mist = Color(0xFFEEF3EA);
const _gold = Color(0xFFE8C14A);

/// Confetti for a full board, the same in light and dark mode.
const confettiColors = [
  _gold,
  _mint,
  Color(0xFFF07C6C),
  Color(0xFF6CB4F0),
  Color(0xFFC79BF2),
  Colors.white,
];

/// The closed-tour banner: gold, with dark text.
const celebrationGold = _gold;
const onCelebrationGold = _pine;

/// Board colors, which depend on light/dark mode.
class BoardColors extends ThemeExtension<BoardColors> {
  const BoardColors({
    required this.lightSquare,
    required this.darkSquare,
    required this.visited,
    required this.visitedText,
    required this.visitedTextHalo,
    required this.current,
    required this.currentText,
    required this.reject,
    required this.border,
    required this.path,
    required this.closingPath,
    required this.hint,
    required this.dead,
    required this.hole,
    required this.holeStripe,
  });

  final Color lightSquare;
  final Color darkSquare;

  /// Semi-transparent overlay on visited squares.
  final Color visited;
  final Color visitedText;

  /// Glow behind visited numbers so they stay readable over the path.
  final Color visitedTextHalo;
  final Color current;
  final Color currentText;
  final Color reject;
  final Color border;

  /// Line through the visited squares, drawn when the game ends.
  final Color path;

  /// Line from the last square back to the first in a closed tour.
  final Color closingPath;

  /// Dot on the squares the knight can jump to, when that help is on.
  final Color hint;

  /// Tint on squares the knight can never reach again, when that help is on.
  final Color dead;

  /// A square that isn't part of the board: dark, with diagonal stripes.
  final Color hole;
  final Color holeStripe;

  static const dark = BoardColors(
    lightSquare: _sage,
    darkSquare: _forest,
    visited: Color(0xB31B231E),
    visitedText: _sage,
    visitedTextHalo: _night,
    current: _mint,
    currentText: _pine,
    reject: Color(0xFFD9645A),
    border: _olive,
    path: Color(0x99A8FFCB),
    closingPath: _gold,
    hint: Color(0x8C1B231E),
    dead: Color(0x99D9645A),
    hole: _night,
    holeStripe: _olive,
  );

  static const light = BoardColors(
    lightSquare: Color(0xFFE2EBDA),
    darkSquare: Color(0xFFA3BB98),
    visited: Color(0xC737664A),
    visitedText: Colors.white,
    visitedTextHalo: _pine,
    current: _pine,
    currentText: _mint,
    reject: Color(0xFFC0392B),
    border: _olive,
    path: Color(0xB326332B),
    closingPath: _gold,
    hint: Color(0x8037664A),
    dead: Color(0x80C0392B),
    hole: Color(0xFF4A5536),
    holeStripe: _olive,
  );

  @override
  BoardColors copyWith() => this;

  @override
  BoardColors lerp(BoardColors? other, double t) {
    if (other == null) return this;
    return BoardColors(
      lightSquare: Color.lerp(lightSquare, other.lightSquare, t)!,
      darkSquare: Color.lerp(darkSquare, other.darkSquare, t)!,
      visited: Color.lerp(visited, other.visited, t)!,
      visitedText: Color.lerp(visitedText, other.visitedText, t)!,
      visitedTextHalo: Color.lerp(visitedTextHalo, other.visitedTextHalo, t)!,
      current: Color.lerp(current, other.current, t)!,
      currentText: Color.lerp(currentText, other.currentText, t)!,
      reject: Color.lerp(reject, other.reject, t)!,
      border: Color.lerp(border, other.border, t)!,
      path: Color.lerp(path, other.path, t)!,
      closingPath: Color.lerp(closingPath, other.closingPath, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
      dead: Color.lerp(dead, other.dead, t)!,
      hole: Color.lerp(hole, other.hole, t)!,
      holeStripe: Color.lerp(holeStripe, other.holeStripe, t)!,
    );
  }
}

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme =
      ColorScheme.fromSeed(seedColor: _forest, brightness: brightness).copyWith(
        primary: dark ? _mint : _forest,
        onPrimary: dark ? _pine : Colors.white,
        primaryContainer: dark ? _forest : _sage,
        onPrimaryContainer: dark ? Colors.white : _pine,
        secondaryContainer: dark ? _pine : const Color(0xFFD5E2CC),
        onSecondaryContainer: dark ? _sage : _pine,
        surface: dark ? _night : _mist,
        onSurface: dark ? const Color(0xFFDDE8E0) : _pine,
        surfaceContainerHigh: dark ? _pine : const Color(0xFFE2EBDA),
        outline: _olive,
      );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      centerTitle: true,
      toolbarHeight: 68,
      titleTextStyle: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: scheme.onSurface,
      ),
    ),
    extensions: [dark ? BoardColors.dark : BoardColors.light],
  );
}

/// Current light/dark mode, saved on the device.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController([super.value = ThemeMode.dark]);

  static const _key = 'theme_mode';

  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final light = prefs.getString(_key) == 'light';
    return ThemeController(light ? ThemeMode.light : ThemeMode.dark);
  }

  bool get isDark => value == ThemeMode.dark;

  Future<void> toggle() async {
    value = isDark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, isDark ? 'dark' : 'light');
  }
}
