import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../data/dining_models.dart';
import '../data/dining_repository.dart';
import '../data/dining_repository_factory.dart';
import '../widgets/dining_widgets.dart';

enum _DiningFilter { all, localFood, restaurants }

/// S9 Dining.
///
/// Search + filter chips, "Taste Iloilo" dishes and "Places to try"
/// restaurants. The camera button opens the scanner (S12) in dish mode.
class DiningScreen extends StatefulWidget {
  const DiningScreen({super.key, this.repository});

  /// Override in tests. Defaults to [resolveDiningRepository].
  final DiningRepository? repository;

  @override
  State<DiningScreen> createState() => _DiningScreenState();
}

class _DiningScreenState extends State<DiningScreen> {
  late final DiningRepository _repo = widget.repository ?? resolveDiningRepository();
  final _controller = TextEditingController();
  Timer? _debounce;
  _DiningFilter _filter = _DiningFilter.all;

  DiningSearchResult? _result;
  bool _loading = true;
  Object? _error;
  int _requestId = 0; // drops stale responses when typing fast

  @override
  void initState() {
    super.initState();
    _runSearch('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String query) async {
    final id = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await _repo.search(query);
      if (!mounted || id != _requestId) return;
      setState(() {
        _result = r;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) _runSearch(value);
    });
  }

  void _onSubmitted(String value) {
    _debounce?.cancel();
    _runSearch(value);
  }

  void _clear() {
    _controller.clear();
    _debounce?.cancel();
    _runSearch('');
  }

  Widget _buildResults() {
    final result = _result;
    if (_error != null && result == null) {
      return DiningMessage(
        icon: Icons.error_outline,
        text: 'Something went wrong.',
        actionLabel: 'Try again',
        onAction: () => _runSearch(_controller.text),
      );
    }
    if (result == null) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final visibleDishes = _filter != _DiningFilter.restaurants && result.dishes.isNotEmpty;
    final visiblePlaces = _filter != _DiningFilter.localFood && result.restaurants.isNotEmpty;
    if (!visibleDishes && !visiblePlaces) {
      final q = _controller.text.trim();
      return DiningMessage(
        icon: Icons.search_off,
        text: q.isEmpty ? 'Nothing here yet.' : 'No results for "$q".',
      );
    }
    return _Results(
      result: result,
      filter: _filter,
      onFilter: (f) => setState(() => _filter = f),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const DiningHeader(title: 'Dining'),
          _SearchRow(
            controller: _controller,
            onChanged: _onQueryChanged,
            onSubmitted: _onSubmitted,
            onClear: _clear,
            onScan: () => context.push(AppRoutes.scan(mode: 'dish')),
          ),
          _FilterChips(
            selected: _filter,
            onSelected: (f) => setState(() => _filter = f),
          ),
          const SizedBox(height: 4),
          if (_loading && _result != null)
            const LinearProgressIndicator(
              minHeight: 2,
              color: DiningColors.purple,
              backgroundColor: DiningColors.chipTint,
            ),
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(bottom: 96),
              children: [_buildResults()],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onScan,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: c),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 14, color: Colors.black),
              cursorColor: DiningColors.purple,
              decoration: InputDecoration(
                hintText: 'Search food or places',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.black45),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, size: 18, color: DiningColors.purple),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, v, __) => v.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.close, size: 18),
                          color: Colors.black54,
                          onPressed: onClear,
                        ),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                enabledBorder: border(DiningColors.border),
                focusedBorder: border(DiningColors.purple),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Scan a dish',
            onPressed: onScan,
            style: IconButton.styleFrom(
              backgroundColor: DiningColors.headerTint,
              foregroundColor: DiningColors.purple,
            ),
            icon: const Icon(Icons.photo_camera_outlined, size: 20),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final _DiningFilter selected;
  final ValueChanged<_DiningFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    const labels = {
      _DiningFilter.all: 'All',
      _DiningFilter.localFood: 'Local food',
      _DiningFilter.restaurants: 'Restaurants',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Wrap(
        spacing: 8,
        children: [
          for (final entry in labels.entries)
            ChoiceChip(
              label: Text(entry.value),
              selected: selected == entry.key,
              onSelected: (_) => onSelected(entry.key),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected == entry.key
                    ? Colors.white
                    : DiningColors.purple,
              ),
              selectedColor: DiningColors.purple,
              backgroundColor: Colors.white,
              side: const BorderSide(color: DiningColors.border),
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.result,
    required this.filter,
    required this.onFilter,
  });

  final DiningSearchResult result;
  final _DiningFilter filter;
  final ValueChanged<_DiningFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    final showDishes = filter != _DiningFilter.restaurants;
    final showPlaces = filter != _DiningFilter.localFood;
    // "All" previews a few items; a specific chip shows the full list.
    final preview = filter == _DiningFilter.all;
    final dishes = preview ? result.dishes.take(1) : result.dishes;
    final places = preview ? result.restaurants.take(3) : result.restaurants;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDishes && result.dishes.isNotEmpty) ...[
          SectionHeader(
            'Taste Iloilo',
            onSeeAll: preview ? () => onFilter(_DiningFilter.localFood) : null,
          ),
          for (final d in dishes)
            DishCard(
              dish: d,
              onTap: () => context.push(AppRoutes.dish(d.id)),
            ),
        ],
        if (showPlaces && result.restaurants.isNotEmpty) ...[
          SectionHeader(
            'Places to try',
            onSeeAll:
                preview ? () => onFilter(_DiningFilter.restaurants) : null,
          ),
          for (final r in places)
            DiningListTile(
              title: r.name,
              subtitle: r.cuisine,
              caption: 'View restaurant',
              imageUrl: r.imageUrl,
              onTap: () => context.push(AppRoutes.restaurant(r.id)),
            ),
        ],
      ],
    );
  }
}
