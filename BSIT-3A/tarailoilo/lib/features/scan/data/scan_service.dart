import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

import '../../../data/remote/supabase_service.dart';
import '../screens/scan_camera_screen.dart' show ScanMode;
import 'scan_models.dart';

class ScanException implements Exception {
  const ScanException(this.message, {this.offline = false, this.timedOut = false});

  final String message;
  final bool offline;
  final bool timedOut;

  @override
  String toString() => message;
}

/// GPS + compass heading sent along with the photo. All best-effort.
class ScanContext {
  const ScanContext({this.latitude, this.longitude, this.heading});

  final double? latitude;
  final double? longitude;
  final double? heading;
}

Future<ScanContext> readScanContext() async {
  double? lat, lng, heading;
  try {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );
      lat = pos.latitude;
      lng = pos.longitude;
    }
  } catch (_) {/* location is optional */}
  try {
    final event = await FlutterCompass.events?.first.timeout(const Duration(seconds: 1));
    heading = event?.heading;
  } catch (_) {/* compass is optional */}
  return ScanContext(latitude: lat, longitude: lng, heading: heading);
}

abstract class ScanService {
  Future<List<ScanGuess>> identify({
    required Uint8List imageBytes,
    required ScanMode mode,
    required ScanContext context,
  });
}

/// Calls the `scan-identify` Edge Function (Gemini vision).
/// 15 s timeout per attempt, one retry on timeout / 5xx.
class SupabaseScanService implements ScanService {
  const SupabaseScanService();

  static const _timeout = Duration(seconds: 15);
  static const _attempts = 2;

  @override
  Future<List<ScanGuess>> identify({
    required Uint8List imageBytes,
    required ScanMode mode,
    required ScanContext context,
  }) async {
    // TODO: align body/response with the real Edge Function contract.
    if (!SupabaseService.isReady) {
      throw const ScanException(
          'Scan is not set up on this build (Supabase is not configured).');
    }
    final body = {
      'mode': mode.name,
      'image': base64Encode(imageBytes),
      'lat': context.latitude,
      'lng': context.longitude,
      'heading': context.heading,
    };

    ScanException? last;
    for (var attempt = 1; attempt <= _attempts; attempt++) {
      try {
        final res = await SupabaseService.client.functions
            .invoke('scan-identify', body: body)
            .timeout(_timeout);
        final data = res.data;
        if (data is! Map || data['guesses'] is! List) {
          throw const ScanException('Unexpected response from the scanner.');
        }
        final guesses = (data['guesses'] as List)
            .whereType<Map>()
            .map((m) => ScanGuess.fromJson(Map<String, dynamic>.from(m), mode))
            .toList()
          ..sort((a, b) => b.confidence.compareTo(a.confidence));
        return guesses.take(3).toList();
      } on TimeoutException {
        last = const ScanException('The scan took too long.', timedOut: true);
      } on SocketException {
        throw const ScanException('Scan needs internet.', offline: true);
      } on FunctionException catch (e) {
        if (e.status >= 500) {
          last = ScanException('The scanner is having trouble (${e.status}): ${e.details}');
        } else {
          throw ScanException('The scanner could not read that photo (${e.status}): ${e.details}');
        }
      }
    }
    throw last ?? const ScanException('Scan failed.');
  }
}