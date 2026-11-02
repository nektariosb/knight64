import 'package:flutter/material.dart';

/// The app bar title of every screen: the app name, with a smaller line
/// under it saying where you are.
class AppTitle extends StatelessWidget {
  const AppTitle(this.subtitle, {super.key});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Knight's Tour"),
        Text(
          subtitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontSize: 15,
            letterSpacing: 0.5,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
