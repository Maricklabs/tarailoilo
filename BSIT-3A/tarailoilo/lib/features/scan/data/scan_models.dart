import 'dart:typed_data';

import '../screens/scan_camera_screen.dart' show ScanMode;

/// One AI guess for what is in the photo.
class ScanGuess {
  const ScanGuess({
    this.id,
    required this.name,
    required this.confidence,
    required this.mode,
    this.subtitle,
  });

  /// Dish id (-> S10) or landmark id (-> S15). Null when the AI recognized it
  /// but we have no entry for it in the app.
  final String? id;

  bool get hasDetails => id != null;
  final String name;

  /// 0.0 - 1.0, as reported by the model. Treat as a hint, not a fact.
  final double confidence;
  final ScanMode mode;
  final String? subtitle;

  /// Expects `{id, name, confidence, type?, subtitle?}`.
  /// TODO: align with the real `scan-identify` response.
  factory ScanGuess.fromJson(Map<String, dynamic> json, ScanMode fallbackMode) {
    final raw = json['confidence'];
    final c = raw is num ? raw.toDouble() : 0.0;
    final rawId = json['id']?.toString();
    return ScanGuess(
      id: (rawId == null || rawId.isEmpty) ? null : rawId,
      name: (json['name'] ?? '').toString(),
      confidence: c.clamp(0.0, 1.0),
      mode: json['type'] == null
          ? fallbackMode
          : ScanMode.fromName(json['type'].toString()),
      subtitle: json['subtitle'] as String?,
    );
  }
}

/// Everything S13 needs, passed from S12 via `extra`.
class ScanOutcome {
  const ScanOutcome({
    required this.mode,
    required this.imageBytes,
    required this.guesses,
  });

  final ScanMode mode;
  /// The captured photo, kept in memory so it works on web and mobile.
  final Uint8List imageBytes;
  final List<ScanGuess> guesses;
}
