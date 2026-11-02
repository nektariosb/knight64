import 'package:flutter/material.dart';

import '../game/facts.dart';

/// "Did you know?" box at the bottom of a game-over dialog.
class FactBox extends StatelessWidget {
  const FactBox(this.fact, {super.key});

  final Fact fact;

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
          Icon(Icons.auto_stories_outlined, size: 20, color: color),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Did you know? ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: fact.text),
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
