import 'dart:math';

import 'package:flutter/material.dart';

import 'theme.dart';

/// Confetti and a banner, shown over the screen when the board is full. A
/// closed tour gets a bigger one: confetti also fired from both bottom
/// corners, and a gold banner that says it's a closed tour.
///
/// Calls [onDone] once the last confetti is gone.
class Celebration extends StatefulWidget {
  const Celebration({
    super.key,
    required this.closed,
    required this.total,
    this.onDone,
  });

  final bool closed;

  /// Number of squares filled, for the banner.
  final int total;
  final VoidCallback? onDone;

  /// How long the banner stays up. The save dialog waits for it.
  static const bannerTime = Duration(milliseconds: 2800);

  static const _duration = Duration(milliseconds: 4500);

  @override
  State<Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<Celebration>
    with SingleTickerProviderStateMixin {
  late final _controller =
      AnimationController(vsync: this, duration: Celebration._duration)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onDone?.call();
        })
        ..forward();

  late final _pieces = _Piece.party(closed: widget.closed);

  static double _seconds(Duration d) => d.inMilliseconds / 1000;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * _seconds(Celebration._duration);
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _ConfettiPainter(_pieces, t)),
            Center(child: _banner(context, t)),
          ],
        );
      },
    ),
  );

  /// Pops in with a little bounce, then fades out at [Celebration.bannerTime].
  Widget _banner(BuildContext context, double t) {
    final end = _seconds(Celebration.bannerTime);
    if (t >= end) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final closed = widget.closed;
    final background = closed
        ? celebrationGold
        : theme.colorScheme.primaryContainer;
    final foreground = closed
        ? onCelebrationGold
        : theme.colorScheme.onPrimaryContainer;
    final pop = Curves.elasticOut.transform((t / 0.8).clamp(0, 1));
    final opacity = min(t / 0.15, (end - t) / 0.3).clamp(0.0, 1.0);
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: 0.5 + 0.5 * pop,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(blurRadius: 16, color: Colors.black38)],
          ),
          child: DefaultTextStyle(
            style: theme.textTheme.bodyLarge!.copyWith(color: foreground),
            textAlign: TextAlign.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  closed ? Icons.all_inclusive : Icons.celebration,
                  size: 48,
                  color: foreground,
                ),
                const SizedBox(height: 8),
                Text(
                  closed ? 'Closed tour!' : 'Tour complete!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  closed
                      ? 'You filled all ${widget.total} squares, and the '
                            'knight can jump from the last one back to '
                            'square 1. A full loop!'
                      : 'You filled all ${widget.total} squares!',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One bit of confetti. Positions and speeds are fractions of the screen.
class _Piece {
  _Piece(Random random, {required this.start, required this.velocity})
    : color = confettiColors[random.nextInt(confettiColors.length)],
      size = 8 + random.nextDouble() * 6,
      fall = 0.25 + random.nextDouble() * 0.15,
      spin = (random.nextDouble() - 0.5) * 12,
      flip = 4 + random.nextDouble() * 6,
      phase = random.nextDouble() * 2 * pi;

  final Offset start;
  final Offset velocity;
  final Color color;
  final double size;

  /// Speed it drifts down at once air drag has slowed it.
  final double fall;

  /// Turning speed, and how fast it flutters (turns over), per second.
  final double spin, flip;
  final double phase;

  /// Confetti raining from above the screen; for a closed tour, also two
  /// bursts fired up from the bottom corners.
  static List<_Piece> party({required bool closed}) {
    final random = Random();
    return [
      for (var i = 0; i < (closed ? 60 : 90); i++)
        _Piece(
          random,
          start: Offset(random.nextDouble(), -0.05 - random.nextDouble() * 0.5),
          velocity: Offset.zero,
        ),
      if (closed)
        for (final side in [0.0, 1.0])
          for (var i = 0; i < 80; i++)
            _Piece(
              random,
              start: Offset(side, 1.02),
              velocity: Offset(
                (side == 0 ? 1 : -1) * (0.3 + random.nextDouble() * 0.7),
                -1.6 - random.nextDouble() * 1.2,
              ),
            ),
    ];
  }

  /// Where the piece is after [t] seconds. Drag slows its first push, then
  /// it drifts down, swaying a little.
  Offset at(double t) {
    const drag = 2.0;
    final pushed = (1 - exp(-drag * t)) / drag;
    return Offset(
      start.dx + velocity.dx * pushed + 0.02 * sin(3 * t + phase),
      start.dy + fall * t + (velocity.dy - fall) * pushed,
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);

  final List<_Piece> pieces;

  /// Seconds since the celebration started.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    // Fades out over the last second.
    final end = Celebration._duration.inMilliseconds / 1000;
    final alpha = (end - t).clamp(0.0, 1.0);
    final paint = Paint();
    for (final piece in pieces) {
      final at = piece.at(t);
      paint.color = piece.color.withValues(alpha: alpha);
      canvas
        ..save()
        ..translate(at.dx * size.width, at.dy * size.height)
        ..rotate(piece.spin * t + piece.phase)
        ..scale(cos(piece.flip * t + piece.phase), 1)
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 0.5,
          ),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
