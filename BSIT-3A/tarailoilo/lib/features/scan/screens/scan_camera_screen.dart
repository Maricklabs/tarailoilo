import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../dining/widgets/dining_widgets.dart';
import '../data/scan_models.dart';
import '../data/scan_service.dart';

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
/// Camera preview with a Dish/Landmark toggle. Sends the photo + GPS +
/// compass heading to the `scan-identify` Edge Function. Offline it shows
/// "Scan needs internet" and offers manual search (S9).
class ScanCameraScreen extends StatefulWidget {
  const ScanCameraScreen({
    super.key,
    required this.initialMode,
    this.service = const SupabaseScanService(),
  });

  final ScanMode initialMode;
  final ScanService service;

  @override
  State<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends State<ScanCameraScreen> with WidgetsBindingObserver {
  late ScanMode _mode = widget.initialMode;

  CameraController? _camera;
  String? _cameraError;
  bool _offline = false;
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  Uint8List? _captured; // frozen frame shown while identifying
  bool _identifying = false;
  String? _scanError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    Connectivity().checkConnectivity().then(_onConnectivity);
    _connSub = Connectivity().onConnectivityChanged.listen(_onConnectivity);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connSub?.cancel();
    _camera?.dispose();
    super.dispose();
  }

  void _onConnectivity(List<ConnectivityResult> r) {
    if (!mounted) return;
    setState(() => _offline = r.every((c) => c == ConnectivityResult.none));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final cam = _camera;
      _camera = null;
      cam?.dispose();
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed && _camera == null) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _cameraError = 'No camera found on this device.');
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _camera = controller;
        _cameraError = null;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = e.code.contains('AccessDenied')
            ? 'Camera access is off. Enable it in Settings to scan.'
            : 'The camera could not start.';
      });
    }
  }

  Future<void> _capture() async {
    final cam = _camera;
    if (cam == null || !cam.value.isInitialized || _identifying) return;
    setState(() {
      _identifying = true;
      _scanError = null;
    });
    try {
      final ctxFuture = readScanContext();
      final photo = await cam.takePicture();
      final bytes = await photo.readAsBytes();
      if (!mounted) return;
      setState(() => _captured = bytes);

      final guesses = await widget.service.identify(
        imageBytes: bytes,
        mode: _mode,
        context: await ctxFuture,
      );
      if (!mounted) return;
      await context.push(
        AppRoutes.scanResult,
        extra: ScanOutcome(mode: _mode, imageBytes: bytes, guesses: guesses),
      );
    } on ScanException catch (e) {
      if (!mounted) return;
      setState(() {
        _scanError = e.message;
        if (e.offline) _offline = true;
      });
    } on CameraException {
      if (!mounted) return;
      setState(() => _scanError = 'Could not take the photo. Try again.');
    } catch (e, st) {
      debugPrint('Scan failed: $e\n$st');
      if (!mounted) return;
      setState(() => _scanError =
          kDebugMode ? 'Scan failed: $e' : 'Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _captured = null;
          _identifying = false;
        });
      }
    }
  }

  void _searchManually() => context.go(AppRoutes.dining);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const DiningHeader(title: "What's this?"),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_offline) {
      return DiningMessage(
        icon: Icons.cloud_off,
        text: 'Scan needs internet.\nYou can still search offline.',
        actionLabel: 'Search manually',
        onAction: _searchManually,
      );
    }
    if (_cameraError != null) {
      return DiningMessage(
        icon: Icons.no_photography_outlined,
        text: _cameraError!,
        actionLabel: 'Search manually',
        onAction: _searchManually,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<ScanMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: ScanMode.dish, label: Text('Dish'), icon: Icon(Icons.restaurant, size: 16)),
            ButtonSegment(value: ScanMode.landmark, label: Text('Landmark'), icon: Icon(Icons.account_balance, size: 16)),
          ],
          selected: {_mode},
          onSelectionChanged: _identifying ? null : (s) => setState(() => _mode = s.first),
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: DiningColors.purple,
            selectedForegroundColor: Colors.white,
            foregroundColor: DiningColors.purple,
          ),
        ),
        const SizedBox(height: 16),
        _Viewfinder(camera: _camera, captured: _captured),
        const SizedBox(height: 16),
        Center(child: _ShutterButton(enabled: _camera != null && !_identifying, onTap: _capture)),
        const SizedBox(height: 16),
        _DetectedPanel(
          mode: _mode,
          identifying: _identifying,
          error: _scanError,
          onRetry: _capture,
        ),
      ],
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder({required this.camera, required this.captured});

  final CameraController? camera;
  final Uint8List? captured;

  @override
  Widget build(BuildContext context) {
    final cam = camera;
    Widget content;
    if (captured != null) {
      content = Image.memory(captured!, fit: BoxFit.cover);
    } else if (cam != null && cam.value.isInitialized) {
      final size = cam.value.previewSize;
      content = size == null
          ? CameraPreview(cam)
          : FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(width: size.height, height: size.width, child: CameraPreview(cam)),
            );
    } else {
      content = const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: Colors.black12, child: content),
            Padding(
              padding: const EdgeInsets.all(28),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70, width: 1.5),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: 'Take photo',
      onPressed: enabled ? onTap : null,
      iconSize: 30,
      style: IconButton.styleFrom(
        backgroundColor: DiningColors.purple,
        foregroundColor: Colors.white,
        fixedSize: const Size(64, 64),
      ),
      icon: const Icon(Icons.photo_camera),
    );
  }
}

class _DetectedPanel extends StatelessWidget {
  const _DetectedPanel({
    required this.mode,
    required this.identifying,
    required this.error,
    required this.onRetry,
  });

  final ScanMode mode;
  final bool identifying;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (identifying) {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 10),
          Text(mode == ScanMode.dish ? 'Identifying dish...' : 'Locating landmark...',
              style: const TextStyle(fontWeight: FontWeight.w800, color: DiningColors.purpleDark)),
        ],
      );
    } else if (error != null) {
      content = Column(
        children: [
          Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: DiningColors.body)),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      );
    } else {
      content = Text(
        mode == ScanMode.dish ? 'Point at a dish, then tap the camera.' : 'Point at a landmark, then tap the camera.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: DiningColors.body),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: DiningColors.chipTint, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          const Text('DETECTED',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: DiningColors.purple)),
          const SizedBox(height: 6),
          content,
        ],
      ),
    );
  }
}
