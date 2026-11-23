import 'package:flutter/material.dart';

/// S19 "Show to the other person" mode.
///
/// Full screen (no bottom bar), very large Hiligaynon text so a tourist can
/// show it to a local.
///
/// TODO(language owner): load the phrase from drift and keep the screen
/// awake with wakelock_plus while this page is open.
class PhraseShowModeScreen extends StatelessWidget {
  const PhraseShowModeScreen({super.key, required this.phraseId});

  /// ID taken from the route path.
  final String phraseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Hiligaynon phrase\n($phraseId)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ),
      ),
    );
  }
}
