import 'package:flutter/material.dart';

import '../game/options.dart';

/// Bottom sheet with the player options. Saves each change and calls
/// [onChanged] so the game can update right away.
class OptionsSheet extends StatefulWidget {
  const OptionsSheet({
    super.key,
    required this.options,
    required this.onChanged,
  });

  final Options options;
  final VoidCallback onChanged;

  @override
  State<OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<OptionsSheet> {
  void _update(void Function(Options) change) {
    setState(() => change(widget.options));
    widget.options.save();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        // Scrolls if the options don't fit, e.g. on a phone held sideways.
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('Options', style: theme.textTheme.titleLarge),
          ),
          SwitchListTile(
            title: const Text('Show the path at the end'),
            subtitle: const Text(
              "Draws the knight's route when the game ends.",
            ),
            value: options.pathAtEnd,
            onChanged: (v) => _update((o) => o.pathAtEnd = v),
          ),
          SwitchListTile(
            title: const Text('Show the path while playing'),
            subtitle: const Text("Draws the knight's route after every move."),
            value: options.pathWhilePlaying,
            onChanged: (v) => _update((o) => o.pathWhilePlaying = v),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: const Text('Help'),
            subtitle: const Text(
              'Only games played without help can enter the high scores.',
            ),
            titleTextStyle: theme.textTheme.titleMedium,
          ),
          SwitchListTile(
            title: const Text('Highlight possible moves'),
            subtitle: const Text('Marks the squares the knight can jump to.'),
            value: options.highlightMoves,
            onChanged: (v) => _update((o) => o.highlightMoves = v),
          ),
          SwitchListTile(
            title: const Text('Count the exits'),
            subtitle: const Text(
              "Each square you can jump to shows how many jumps you'd have "
              'from there.',
            ),
            value: options.countExits,
            onChanged: (v) => _update((o) => o.countExits = v),
          ),
          SwitchListTile(
            title: const Text('Warn about unreachable squares'),
            subtitle: const Text(
              "Marks squares the knight can't reach anymore, so you know the "
              "board can't be filled.",
            ),
            value: options.markDead,
            onChanged: (v) => _update((o) => o.markDead = v),
          ),
          SwitchListTile(
            title: const Text('Check if the board can be filled'),
            subtitle: const Text(
              'After every move, tells you if you can still visit every '
              'square.',
            ),
            value: options.checkFillable,
            onChanged: (v) => _update((o) => o.checkFillable = v),
          ),
        ],
      ),
    );
  }
}
