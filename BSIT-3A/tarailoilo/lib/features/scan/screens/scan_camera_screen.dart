import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// What the scanner is trying to recognize.
enum ScanMode {
  dish,
  landmark;

  /// Reads `?mode=` from the URL. Unknown or missing values mean [dish].
  static ScanMode fromName(String? name) =>
      ScanMode.values.firstWhere((m) => m.name == name, orElse: () => ScanMode.dish);
}

/// S12 Scan Camera (core feature, AI).
///
/// Final version: camera preview with a Dish/Landmark toggle. Sends the
/// photo + GPS + compass heading to the `scan-identify` Edge Function
/// (Gemini vision). Offline it shows "Scan needs internet" and offers manual
/// search.
///
/// TODO(scan owner): add the camera, the Edge Function call (15 s timeout,
/// retry) and the offline fallback.
class ScanCameraScreen extends StatefulWidget {
  const ScanCameraScreen({super.key, required this.initialMode});

  final ScanMode initialMode;

  @override
  State<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends State<ScanCameraScreen> {
  late ScanMode _mode = widget.initialMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      body: FeaturePlaceholder(
        code: 'S12',
        description:
            'Camera preview, Dish/Landmark toggle, and AI identification via '
            'scan-identify. Offline: "Scan needs internet" + manual search.',
        extra: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<ScanMode>(
              segments: const [
                ButtonSegment(value: ScanMode.dish, label: Text('Dish'), icon: Icon(Icons.restaurant)),
                ButtonSegment(value: ScanMode.landmark, label: Text('Landmark'), icon: Icon(Icons.account_balance)),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.scanResult),
              icon: const Icon(Icons.camera),
              label: Text('Take photo (${_mode.name})'),
            ),
          ],
        ),
      ),
    );
  }
}
