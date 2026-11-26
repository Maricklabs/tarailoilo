import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../dining/widgets/dining_widgets.dart';
import '../data/scan_models.dart';
import 'scan_camera_screen.dart' show ScanMode;

/// S13 Scan Result.
///
/// Shows what the AI detected (labeled AI, with confidence). The user taps
/// "Check details" to confirm, or picks another guess, or searches manually.
/// "Check details" only appears when the app has an entry for the guess.
///
/// Receives the outcome from S12 via go_router `extra`:
/// `ScanResultScreen(outcome: state.extra as ScanOutcome?)`.
class ScanResultScreen extends StatefulWidget {
  const ScanResultScreen({super.key, this.outcome});

  final ScanOutcome? outcome;

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  late ScanGuess? _selected = widget.outcome?.guesses.firstOrNull;

  void _checkDetails() {
    final g = _selected;
    final id = g?.id;
    if (g == null || id == null) return;
    // go, not push: dish/landmark pages live inside the tab shell, and the scan
    // screens sit on the root navigator above it. Pushing would add the shell a
    // second time (duplicate page key). go() closes the scan screens instead.
    context.go(g.mode == ScanMode.dish ? AppRoutes.dish(id) : AppRoutes.landmark(id));
  }

  void _searchManually() => context.go(AppRoutes.dining);

  @override
  Widget build(BuildContext context) {
    final outcome = widget.outcome;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const DiningHeader(title: "What's this?"),
          Expanded(
            child: outcome == null || outcome.guesses.isEmpty
                ? DiningMessage(
                    icon: Icons.search_off,
                    text: outcome == null
                        ? 'No scan to show.'
                        : 'We could not tell what that is. Try another angle or search manually.',
                    actionLabel: 'Search manually',
                    onAction: _searchManually,
                  )
                : _buildResult(outcome),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(ScanOutcome outcome) {
    final selected = _selected ?? outcome.guesses.first;
    final others = outcome.guesses.where((g) => g != selected).toList();
    final pct = (selected.confidence * 100).round();
    final noun = selected.mode == ScanMode.dish ? 'dish' : 'place';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(outcome.imageBytes, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DiningColors.chipTint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('DETECTED',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: DiningColors.purple)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: DiningColors.purple, borderRadius: BorderRadius.circular(6)),
                    child: const Text('AI',
                        style: TextStyle(
                            fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                selected.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: DiningColors.purpleDark),
              ),
              const SizedBox(height: 2),
              Text('$pct% confident. AI can be wrong.',
                  style: const TextStyle(fontSize: 11, color: DiningColors.body)),
              const SizedBox(height: 14),
              if (selected.hasDetails)
                FilledButton.icon(
                  onPressed: _checkDetails,
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Check details'),
                  style: FilledButton.styleFrom(
                    backgroundColor: DiningColors.purple,
                    minimumSize: const Size.fromHeight(44),
                  ),
                )
              else
                Text(
                  "We don't have details for this $noun yet.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: DiningColors.body),
                ),
            ],
          ),
        ),
        if (others.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('Not it? Other possible matches',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: DiningColors.purple)),
          const SizedBox(height: 8),
          for (final g in others)
            DiningListTile(
              title: g.name,
              subtitle: '${(g.confidence * 100).round()}% confident',
              icon: g.mode == ScanMode.dish ? Icons.ramen_dining : Icons.account_balance,
              horizontalPadding: 0,
              onTap: () => setState(() => _selected = g),
            ),
        ],
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _searchManually,
            child: const Text('None of these? Search manually'),
          ),
        ),
      ],
    );
  }
}