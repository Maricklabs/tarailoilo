import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../data/dining_models.dart';
import '../data/dining_repository.dart';
import '../widgets/dining_widgets.dart';

/// S10 Dish Detail.
///
/// Meaning, origin and history, ingredients. Allergens only as "Declared by
/// [restaurant] as of [date]", never presented as safe to eat. Restaurants
/// serving the dish link to S11 and the map.
class DishDetailScreen extends StatefulWidget {
  const DishDetailScreen({
    super.key,
    required this.dishId,
    this.repository = const SampleDiningRepository(),
  });

  /// ID taken from the route path.
  final String dishId;
  final DiningRepository repository;

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  late Future<_DishBundle> _future = _load();
  bool _saved = false; // TODO: wire to the favourites store.

  Future<_DishBundle> _load() async {
    final repo = widget.repository;
    final dish = await repo.dishById(widget.dishId);
    if (dish == null) return const _DishBundle.missing();
    final results = await Future.wait([
      repo.restaurantsServing(dish.id),
      repo.otherDishes(excludeId: dish.id),
    ]);
    return _DishBundle(
      dish: dish,
      restaurants: results[0] as List<Restaurant>,
      others: results[1] as List<Dish>,
    );
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<_DishBundle>(
        future: _future,
        builder: (context, snap) {
          final dish = snap.data?.dish;
          return Column(
            children: [
              DiningHeader(
                title: dish?.name ?? 'Dish',
                trailing: dish == null
                    ? null
                    : _LocateChip(onTap: () => context.push(AppRoutes.map)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 96),
                  child: DiningAsync<_DishBundle>(
                    future: _future,
                    onRetry: _retry,
                    isEmpty: (b) => b.dish == null,
                    emptyMessage: 'We could not find this dish.',
                    builder: (context, b) => _Body(
                      bundle: b,
                      saved: _saved,
                      onToggleSaved: () => setState(() => _saved = !_saved),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DishBundle {
  const _DishBundle({
    required Dish dish,
    required this.restaurants,
    required this.others,
  }) : dish = dish;

  const _DishBundle.missing()
      : dish = null,
        restaurants = const [],
        others = const [];

  final Dish? dish;
  final List<Restaurant> restaurants;
  final List<Dish> others;
}

class _LocateChip extends StatelessWidget {
  const _LocateChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: const Icon(Icons.location_on, size: 14, color: Colors.white),
      label: const Text('Locate in Maps'),
      labelStyle: const TextStyle(
          fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
      backgroundColor: DiningColors.purple,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.bundle,
    required this.saved,
    required this.onToggleSaved,
  });

  final _DishBundle bundle;
  final bool saved;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final dish = bundle.dish!;
    const h2 = TextStyle(
        fontSize: 14, fontWeight: FontWeight.w800, color: DiningColors.purple);
    const body =
        TextStyle(fontSize: 12, height: 1.5, color: DiningColors.body);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: DiningImage(
                    url: dish.imageUrl,
                    borderRadius: 16,
                    width: double.infinity),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  tooltip: saved ? 'Remove from favorites' : 'Save',
                  onPressed: onToggleSaved,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: DiningColors.purple,
                    minimumSize: const Size(32, 32),
                  ),
                  icon: Icon(saved ? Icons.favorite : Icons.favorite_border,
                      size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('What is it?', style: h2),
          const SizedBox(height: 6),
          Text(dish.description, style: body),
          if (dish.ingredients.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Ingredients', style: h2),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final i in dish.ingredients)
                  Chip(
                    label: Text(i),
                    labelStyle: const TextStyle(
                        fontSize: 11, color: DiningColors.purpleDark),
                    backgroundColor: DiningColors.chipTint,
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text('The origin of ${dish.name}', style: h2),
          const SizedBox(height: 6),
          Text(dish.origin, style: body),
          const SizedBox(height: 16),
          AllergenPanel(declarations: dish.declarations),
          if (bundle.restaurants.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Shops that serve it', style: h2),
            const SizedBox(height: 6),
            for (final r in bundle.restaurants)
              DiningListTile(
                      horizontalPadding: 0,
                      title: r.name,
                      subtitle: r.address,
                      imageUrl: r.imageUrl,
                      onTap: () => context.push(AppRoutes.restaurant(r.id)),
                    ),
          ],
          if (bundle.others.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Keep discovering', style: h2),
            const SizedBox(height: 6),
            for (final d in bundle.others)
              DiningListTile(
                    horizontalPadding: 0,
                    title: d.name,
                    subtitle: d.tagline,
                    imageUrl: d.imageUrl,
                    icon: Icons.ramen_dining,
                    onTap: () => context.push(AppRoutes.dish(d.id)),
                  ),
          ],
        ],
      ),
    );
  }
}
