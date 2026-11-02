import 'package:flutter/material.dart';

import '../game/facts.dart';

/// "Did you know?" box at the bottom of a game-over dialog.
class FactBox extends StatelessWidget {
  const FactBox(this.fact, {super.key});

  final Fact fact;

  @override
  Widget build(BuildContext context) =>
      _NoteBox(Icons.auto_stories_outlined, 'Did you know?', fact.text);
}

/// "Tip:" box at the bottom of a game-over dialog, after some lost games.
class TipBox extends StatelessWidget {
  const TipBox(this.tip, {super.key});

  final String tip;

  @override
  Widget build(BuildContext context) =>
      _NoteBox(Icons.lightbulb_outline, 'Tip:', tip);
}

class _NoteBox extends StatelessWidget {
  const _NoteBox(this.icon, this.heading, this.text);

  final IconData icon;
  final String heading;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Icon(icon, size: 20, color: color),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$heading ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: text),
                ],
              ),
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
