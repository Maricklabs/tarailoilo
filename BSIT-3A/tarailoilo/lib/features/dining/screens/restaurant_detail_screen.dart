import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../data/dining_models.dart';
import '../data/dining_repository.dart';
import '../data/dining_repository_factory.dart';
import '../widgets/dining_widgets.dart';

/// S11 Restaurant.
///
/// Address, hours, contact, map pin, dishes served with dated allergen
/// declarations, and directions.
class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    this.repository,
  });

  /// ID taken from the route path.
  final String restaurantId;
  final DiningRepository? repository;

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantBundle {
  const _RestaurantBundle(this.restaurant, this.dishes);

  final Restaurant? restaurant;
  final List<Dish> dishes;
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late Future<_RestaurantBundle> _future = _load();

  Future<_RestaurantBundle> _load() async {
    final repo = widget.repository ?? resolveDiningRepository();
    final r = await repo.restaurantById(widget.restaurantId);
    if (r == null) return const _RestaurantBundle(null, []);
    return _RestaurantBundle(r, await repo.dishesServedBy(r.id));
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<_RestaurantBundle>(
        future: _future,
        builder: (context, snap) => Column(
          children: [
            DiningHeader(title: snap.data?.restaurant?.name ?? 'Restaurant'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 96),
                child: DiningAsync<_RestaurantBundle>(
                  future: _future,
                  onRetry: _retry,
                  isEmpty: (b) => b.restaurant == null,
                  emptyMessage: 'We could not find this restaurant.',
                  builder: (context, b) => _Body(bundle: b),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.bundle});

  final _RestaurantBundle bundle;

  @override
  Widget build(BuildContext context) {
    final r = bundle.restaurant!;
    const h2 = TextStyle(
        fontSize: 14, fontWeight: FontWeight.w800, color: DiningColors.purple);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: DiningImage(
              url: r.imageUrl,
              icon: Icons.storefront,
              borderRadius: 16,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(icon: Icons.place_outlined, text: r.address),
          _InfoRow(icon: Icons.schedule, text: r.hours),
          if (r.phone != null)
            _InfoRow(icon: Icons.phone_outlined, text: r.phone!),
          const SizedBox(height: 8),
          // TODO: embed a small static map pin here once the map feature
          // exposes a reusable widget; for now both actions open S14.
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.map),
                  style: FilledButton.styleFrom(
                      backgroundColor: DiningColors.purple),
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Directions'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.map),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DiningColors.purple,
                  side: const BorderSide(color: DiningColors.border),
                ),
                icon: const Icon(Icons.location_on_outlined, size: 18),
                label: const Text('View on map'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Dishes served', style: h2),
          const SizedBox(height: 8),
          if (bundle.dishes.isEmpty)
            const Text('No dishes listed yet.',
                style: TextStyle(fontSize: 12, color: DiningColors.body))
          else
            for (final d in bundle.dishes) _DishServed(dish: d, restaurant: r),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: DiningColors.purple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12, color: DiningColors.body)),
          ),
        ],
      ),
    );
  }
}

/// A dish this restaurant serves, with THIS restaurant's dated allergen
/// declaration (if any). Declarations are never presented as safe-to-eat.
class _DishServed extends StatelessWidget {
  const _DishServed({required this.dish, required this.restaurant});

  final Dish dish;
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final declaration = dish.declarations
        .where((d) => d.restaurantId == restaurant.id)
        .firstOrNull;

    final String allergenText;
    if (declaration == null) {
      allergenText = 'No allergen declaration from ${restaurant.name} yet.';
    } else {
      final list = declaration.allergens.isEmpty
          ? 'none listed'
          : declaration.allergens.join(', ');
      allergenText = 'Declared by ${restaurant.name} as of '
          '${AllergenPanel.formatDate(declaration.declaredOn)}: $list';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: DiningColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push(AppRoutes.dish(dish.id)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                DiningImage(
                  url: dish.imageUrl,
                  icon: Icons.ramen_dining,
                  width: 48,
                  height: 48,
                  borderRadius: 8,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: DiningColors.purpleDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        allergenText,
                        style: const TextStyle(
                            fontSize: 10, color: DiningColors.body),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    size: 20, color: DiningColors.purple),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
