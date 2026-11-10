import 'package:flutter/material.dart';

import '../game/daily.dart';
import 'board_picker.dart';

/// Bottom sheet with today's challenge and a calendar of the days played.
/// Pops with true to play today's challenge.
class DailySheet extends StatefulWidget {
  const DailySheet({super.key, required this.results, required this.playing});

  final DailyResults results;

  /// Today's challenge is the game on the board already.
  final bool playing;

  @override
  State<DailySheet> createState() => _DailySheetState();
}

class _DailySheetState extends State<DailySheet> {
  static const _weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  static const _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final _today = DailyChallenge.today();

  /// First day of the month the calendar shows.
  late var _month = DateTime(_today.date.year, _today.date.month);

  /// The calendar goes back to the first month with a result.
  late final DateTime _firstMonth = () {
    final days = widget.results.best.keys.toList()..sort();
    if (days.isEmpty) return _month;
    final first = DateTime.parse(days.first);
    return DateTime(first.year, first.month);
  }();

  String _todayResult() {
    final result = widget.results.best[_today.id];
    if (result == null) return 'Not played yet.';
    if (result.filled) return 'Board filled!';
    return 'Best today: ${result.squares} / ${result.total}.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = _today.date;
    final filledToday = widget.results.best[_today.id]?.filled ?? false;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          Text('Daily challenge', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'A new board every day: small ones early in the week, big ones '
            'at the weekend. Play as often as you like: your best game of '
            'the day counts.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            spacing: 16,
            children: [
              BoardPreview(board: _today.board, width: 88, start: _today.start),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      '${_dayNames[date.weekday - 1]} ${date.day} '
                      '${_months[date.month - 1]}',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      '${_today.board.name}, ${_today.board.total} squares. '
                      'Start on the marked square.',
                    ),
                    Row(
                      spacing: 4,
                      children: [
                        if (filledToday)
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        Flexible(
                          child: Text(
                            _todayResult(),
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.play_arrow),
            label: Text(
              widget.playing ? 'Keep playing' : "Play today's challenge",
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ConstrainedBox(
              // Narrow enough that a six-week month and its key fit on a
              // 16:9 phone without scrolling (day circles are as tall as
              // they are wide).
              constraints: const BoxConstraints(maxWidth: 320),
              child: _calendar(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendar(ThemeData theme) {
    final thisMonth = DateTime(_today.date.year, _today.date.month);
    final canGoBack = _month.isAfter(_firstMonth);
    final canGoOn = _month.isBefore(thisMonth);
    // Day 0 is the last day of the month before.
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final blanks = _month.weekday - 1;
    final weeks = (blanks + days + 6) ~/ 7;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Month before',
              icon: const Icon(Icons.chevron_left),
              onPressed: canGoBack
                  ? () => setState(
                      () => _month = DateTime(_month.year, _month.month - 1),
                    )
                  : null,
            ),
            Expanded(
              child: Text(
                '${_months[_month.month - 1]} ${_month.year}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall,
              ),
            ),
            IconButton(
              tooltip: 'Month after',
              icon: const Icon(Icons.chevron_right),
              onPressed: canGoOn
                  ? () => setState(
                      () => _month = DateTime(_month.year, _month.month + 1),
                    )
                  : null,
            ),
          ],
        ),
        Row(
          children: [
            for (final name in _weekdays)
              Expanded(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (var week = 0; week < weeks; week++)
          Row(
            children: [
              for (var weekday = 0; weekday < 7; weekday++)
                Expanded(
                  child: switch (week * 7 + weekday - blanks + 1) {
                    final day when day >= 1 && day <= days => _day(
                      theme,
                      DateTime(_month.year, _month.month, day),
                    ),
                    _ => const SizedBox(),
                  },
                ),
            ],
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 6,
          children: [
            _dot(theme.colorScheme.primary),
            Text('Board filled', style: theme.textTheme.bodySmall),
            const SizedBox(width: 10),
            _dot(theme.colorScheme.secondaryContainer),
            Text('Played', style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  /// A day of the calendar: filled in green when its board was filled,
  /// lighter when it was only played, and ringed when it's today.
  Widget _day(ThemeData theme, DateTime day) {
    final scheme = theme.colorScheme;
    final id = DailyChallenge.dayId(day);
    final result = widget.results.best[id];
    final filled = result?.filled ?? false;
    final circle = AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: result == null
              ? null
              : filled
              ? scheme.primary
              : scheme.secondaryContainer,
          border: id == _today.id
              ? Border.all(color: scheme.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: filled ? scheme.onPrimary : null,
              fontWeight: filled ? FontWeight.bold : null,
            ),
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(3),
      child: result == null
          ? circle
          : Tooltip(
              message: '${result.squares} / ${result.total}',
              child: circle,
            ),
    );
  }

  static Widget _dot(Color color) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
