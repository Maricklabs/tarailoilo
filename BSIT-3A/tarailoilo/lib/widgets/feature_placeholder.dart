import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A button on a placeholder screen that opens another route.
class PlaceholderLink {
  const PlaceholderLink(this.label, this.location, {this.icon = Icons.arrow_forward});

  final String label;
  final String location;
  final IconData icon;
}

/// TEMPORARY body for screens that are not built yet.
///
/// It shows the screen code (for example "S10"), what the screen must do,
/// and buttons for the screen's cross-links so the whole navigation can be
/// tested today. The feature owner replaces this widget with the real UI.
class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    super.key,
    required this.code,
    required this.description,
    this.links = const [],
    this.extra,
  });

  /// Screen code from PROJECT_PROMPT.md, e.g. "S4" or "A2".
  final String code;

  /// Short summary of what the finished screen should contain.
  final String description;

  /// Navigation buttons to the screens this one links to.
  final List<PlaceholderLink> links;

  /// Optional extra widgets (used by stubs that need custom buttons).
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Row(
          children: [
            Chip(label: Text(code)),
            const SizedBox(width: 8),
            Text('Placeholder — not built yet', style: textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: 8),
        Text(description, style: textTheme.bodyLarge),
        if (extra != null) ...[const SizedBox(height: 16), extra!],
        if (links.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Links to', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final link in links)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton.icon(
                onPressed: () => context.push(link.location),
                icon: Icon(link.icon),
                label: Text(link.label),
              ),
            ),
        ],
      ],
    );
  }
}
