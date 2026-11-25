import 'dining_models.dart';

/// Data access for Dining. Screens depend only on this interface so the
/// offline FTS / Supabase implementation can replace [SampleDiningRepository]
/// without touching UI code.
abstract class DiningRepository {
  /// Empty [query] returns everything.
  Future<DiningSearchResult> search(String query);
  Future<Dish?> dishById(String id);
  Future<Restaurant?> restaurantById(String id);
  Future<List<Restaurant>> restaurantsServing(String dishId);
  Future<List<Dish>> dishesServedBy(String restaurantId);
  Future<List<Dish>> otherDishes({required String excludeId, int limit = 3});
}

/// In-memory stand-in so the UI is runnable before the data layer exists.
///
/// Copy is placeholder content for layout only. Replace with reviewed local
/// data before release (allergen declarations especially).
class SampleDiningRepository implements DiningRepository {
  const SampleDiningRepository();

  static final _declared = DateTime(2026, 10, 1);

  static final List<Dish> _dishes = [
    Dish(
      id: 'la-paz-batchoy',
      name: 'La Paz Batchoy',
      tagline: 'A comforting noodle soup from La Paz, Iloilo.',
      description:
          'A noodle soup associated with La Paz, often topped with pork '
          'and crisp chicharron. Recipes vary by cook and shop.',
      origin:
          'Unverified claims reveal that it is Federico Guillergan St. who '
          'concocted the dish in 1938. However, an assumption also shows that '
          'Teodoro Lepura learned the basics of making one in the 1930s, and '
          'established a Batchoy canteen in 1945. Both persons have their own '
          'chain of Batchoy restaurants scattered over the Philippines today. '
          'Though another account traces the origin of Batchoy from Chinese '
          'history, this is yet to be proven.',
      ingredients: ['Noodles', 'Pork/beef', 'Innards', 'Chicken'],
      declarations: [
        AllergenDeclaration(
          restaurantId: 'teds-batchoy',
          restaurantName: "Ted's Batchoy",
          declaredOn: _declared,
          allergens: ['Wheat', 'Shellfish'],
        ),
      ],
      restaurantIds: ['teds-batchoy', 'robertos'],
      isIloiloFavorite: true,
    ),
    const Dish(
      id: 'kansi',
      name: 'Kansi',
      tagline: 'Brief description',
      description: 'A sour beef shank soup, often compared to bulalo.',
      origin: 'Placeholder history text.',
      ingredients: ['Beef shank', 'Batwan or sour fruit', 'Lemongrass'],
      declarations: [],
      restaurantIds: [],
    ),
    const Dish(
      id: 'kbl',
      name: 'KBL',
      tagline: 'Brief description',
      description: 'Kadyos, baboy, and langka stewed in a sour broth.',
      origin: 'Placeholder history text.',
      ingredients: ['Kadyos beans', 'Pork', 'Langka'],
      declarations: [],
      restaurantIds: [],
    ),
    const Dish(
      id: 'pancit-molo',
      name: 'Pancit Molo',
      tagline: 'Dumpling soup from the Molo district.',
      description: 'Wonton-style dumplings served in a clear savory broth.',
      origin: 'Placeholder history text.',
      ingredients: ['Pork dumplings', 'Chicken broth', 'Garlic'],
      declarations: [],
      restaurantIds: [],
    ),
    const Dish(
      id: 'pinaupong-manok',
      name: 'Pinaupong Manok',
      tagline: 'Chicken cooked buried in hot salt.',
      description: 'Whole chicken slow-cooked under heated rock salt.',
      origin: 'Placeholder history text.',
      ingredients: ['Chicken', 'Rock salt', 'Lemongrass'],
      declarations: [],
      restaurantIds: [],
    ),
  ];

  static const List<Restaurant> _restaurants = [
    Restaurant(
      id: 'teds-batchoy',
      name: "Ted's Batchoy",
      cuisine: 'Batchoy',
      address: 'La Paz Public Market, La Paz, Iloilo City',
      hours: 'Daily, 7:00 AM - 8:00 PM',
      phone: '+63 000 000 0000',
      dishIds: ['la-paz-batchoy'],
      latitude: 10.7155,
      longitude: 122.5560,
    ),
    Restaurant(
      id: 'robertos',
      name: 'Robertos',
      cuisine: 'Local food',
      address: 'Iloilo City',
      hours: 'Daily, 10:00 AM - 9:00 PM',
      dishIds: ['la-paz-batchoy'],
    ),
  ];

  Future<T> _delay<T>(T value) =>
      Future<T>.delayed(const Duration(milliseconds: 250), () => value);

  @override
  Future<DiningSearchResult> search(String query) {
    final q = query.trim().toLowerCase();
    bool hit(String s) => q.isEmpty || s.toLowerCase().contains(q);
    return _delay(DiningSearchResult(
      dishes: _dishes
          .where((d) => hit(d.name) || hit(d.tagline) || d.ingredients.any(hit))
          .toList(),
      restaurants:
          _restaurants.where((r) => hit(r.name) || hit(r.cuisine)).toList(),
    ));
  }

  @override
  Future<Dish?> dishById(String id) =>
      _delay(_dishes.where((d) => d.id == id).firstOrNull);

  @override
  Future<Restaurant?> restaurantById(String id) =>
      _delay(_restaurants.where((r) => r.id == id).firstOrNull);

  @override
  Future<List<Restaurant>> restaurantsServing(String dishId) => _delay(
      _restaurants.where((r) => r.dishIds.contains(dishId)).toList());

  @override
  Future<List<Dish>> dishesServedBy(String restaurantId) {
    final r = _restaurants.where((r) => r.id == restaurantId).firstOrNull;
    final ids = r?.dishIds ?? const <String>[];
    return _delay(_dishes.where((d) => ids.contains(d.id)).toList());
  }

  @override
  Future<List<Dish>> otherDishes({required String excludeId, int limit = 3}) =>
      _delay(_dishes.where((d) => d.id != excludeId).take(limit).toList());
}
