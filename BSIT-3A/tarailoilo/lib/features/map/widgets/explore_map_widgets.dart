import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../data/iloilo_places.dart';
import '../../../data/offline_map_service.dart';

const mapHeaderBg = Color(0xFFF8E8F4);
const mapMagenta = Color(0xFFD1189B);
const mapTitle = Color(0xFFA63F8C);
const mapLegendText = Color(0xFF6B1F58);
const mapDropdownBg = Color(0xFFD9AED0);
const mapMenuBg = Color(0xFF5E2A52);

class MapHeader extends StatelessWidget {
  const MapHeader({super.key, required this.onScan});
  final VoidCallback onScan;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: mapHeaderBg,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: const Row(
              children: [
                Icon(Icons.arrow_back, size: 18, color: mapMagenta),
                SizedBox(width: 8),
                Text(
                  'TARA ILO',
                  style: TextStyle(
                    color: mapMagenta,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'TARA MAPS',
                  style: TextStyle(
                    color: mapTitle,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              InkWell(
                onTap: onScan,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: mapTitle,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Scan Landmark',
                      style: TextStyle(
                        color: mapMagenta,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MapLegend extends StatelessWidget {
  const MapLegend({super.key});
  Widget _item(PlaceCategory c) => SizedBox(
    width: 96,
    child: Row(
      children: [
        Icon(Icons.location_on_outlined, size: 16, color: c.color),
        const SizedBox(width: 4),
        Text(
          c.label,
          style: const TextStyle(fontSize: 10, color: mapLegendText),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Legend:',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: mapLegendText,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _item(PlaceCategory.restaurant),
            _item(PlaceCategory.museum),
            _item(PlaceCategory.other),
          ],
        ),
        const SizedBox(height: 6),
        Row(children: [_item(PlaceCategory.church), _item(PlaceCategory.mall)]),
      ],
    );
  }
}

class PlaceFilterDropdown extends StatelessWidget {
  const PlaceFilterDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// null = all places.
  final PlaceCategory? value;
  final ValueChanged<PlaceCategory?> onChanged;
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.w800,
    );
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: mapDropdownBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PlaceCategory?>(
          value: value,
          isDense: true,
          hint: const Text('Select Place', style: style),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          dropdownColor: mapMenuBg,
          borderRadius: BorderRadius.circular(8),
          style: style,
          selectedItemBuilder: (_) => [
            const Text('All places', style: style),
            for (final c in PlaceCategory.values) Text(c.label, style: style),
          ],
          items: [
            const DropdownMenuItem<PlaceCategory?>(
              value: null,
              child: Text('All places'),
            ),
            for (final c in PlaceCategory.values)
              DropdownMenuItem<PlaceCategory?>(value: c, child: Text(c.label)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

Marker placeMarker(Place p, VoidCallback onTap) => Marker(
  point: p.position,
  width: 44,
  height: 48,
  alignment: Alignment.topCenter, // pin tip sits on the coordinate
  child: GestureDetector(
    onTap: onTap,
    child: Icon(Icons.location_on_outlined, size: 44, color: p.category.color),
  ),
);

void showPlaceDetailsSheet(BuildContext context, Place p) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: p.category.color),
              const SizedBox(width: 6),
              Text(
                p.category.label,
                style: const TextStyle(color: mapLegendText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            p.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: mapMagenta),
            onPressed: () {
              Navigator.pop(sheetContext);
              context.push(AppRoutes.landmark(p.id)); // S15
            },
            child: const Text('View details'),
          ),
        ],
      ),
    ),
  );
}

/// Recenter + start/stop route recording buttons.
class MapOverlayControls extends StatelessWidget {
  const MapOverlayControls({
    super.key,
    required this.tracking,
    required this.onRecenter,
    required this.onToggleRecording,
  });
  final bool tracking;
  final VoidCallback onRecenter;
  final VoidCallback onToggleRecording;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton.small(
          heroTag: 'recenter',
          backgroundColor: Colors.white,
          onPressed: onRecenter,
          child: const Icon(Icons.my_location, color: mapMagenta),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'record',
          backgroundColor: tracking ? mapMagenta : Colors.white,
          onPressed: onToggleRecording,
          child: Icon(
            tracking ? Icons.stop : Icons.fiber_manual_record,
            color: tracking ? Colors.white : mapMagenta,
          ),
        ),
      ],
    );
  }
}

class OfflineDownloadBanner extends StatelessWidget {
  const OfflineDownloadBanner({super.key, required this.service});
  final OfflineMapService service;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double?>(
      valueListenable: service.progress,
      builder: (_, v, __) {
        if (v == null) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Saving Iloilo map for offline use… ${v.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: v / 100, color: mapMagenta),
              ],
            ),
          ),
        );
      },
    );
  }
}
