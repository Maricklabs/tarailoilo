import '../../../data/remote/supabase_service.dart';
import 'dining_models.dart';
import 'dining_repository.dart';

/// Reads Dining data from the Supabase tables (dishes, restaurants,
/// dish_restaurants, allergen_declarations).
///
/// The catalog is small, so search fetches everything once per query and
/// filters in Dart. When offline FTS lands (local database), it replaces this
/// class behind the same [DiningRepository] interface.
class SupabaseDiningRepository implements DiningRepository {
  const SupabaseDiningRepository();

  // A dish with its restaurant links and dated allergen declarations.
  static const _dishSelect = '*, dish_restaurants(restaurant_id), '
      'allergen_declarations(restaurant_id, declared_on, allergens, restaurants(name))';
  static const _restaurantSelect = '*, dish_restaurants(dish_id)';

  static List<Map<String, dynamic>> _rows(dynamic data) =>
      (data as List).cast<Map<String, dynamic>>();

  static Dish _dish(Map<String, dynamic> r) => Dish(
        id: r['id'] as String,
        name: r['name'] as String,
        tagline: (r['tagline'] ?? '') as String,
        description: (r['description'] ?? '') as String,
        origin: (r['origin'] ?? '') as String,
        ingredients: List<String>.from(r['ingredients'] as List? ?? const []),
        imageUrl: r['image_url'] as String?,
        isIloiloFavorite: r['is_iloilo_favorite'] == true,
        restaurantIds: [
          for (final x in r['dish_restaurants'] as List? ?? const [])
            (x as Map)['restaurant_id'] as String,
        ],
        declarations: [
          for (final x in r['allergen_declarations'] as List? ?? const [])
            AllergenDeclaration(
              restaurantId: (x as Map)['restaurant_id'] as String,
              restaurantName: ((x['restaurants'] as Map?)?['name'] ?? '') as String,
              declaredOn: DateTime.parse(x['declared_on'] as String),
              allergens: List<String>.from(x['allergens'] as List? ?? const []),
            ),
        ],
      );

  static Restaurant _restaurant(Map<String, dynamic> r, {List<String>? dishIds}) => Restaurant(
        id: r['id'] as String,
        name: r['name'] as String,
        cuisine: (r['cuisine'] ?? '') as String,
        address: (r['address'] ?? '') as String,
        hours: (r['hours'] ?? '') as String,
        phone: r['phone'] as String?,
        imageUrl: r['image_url'] as String?,
        latitude: (r['latitude'] as num?)?.toDouble(),
        longitude: (r['longitude'] as num?)?.toDouble(),
        dishIds: dishIds ??
            [
              for (final x in r['dish_restaurants'] as List? ?? const [])
                (x as Map)['dish_id'] as String,
            ],
      );

  @override
  Future<DiningSearchResult> search(String query) async {
    final db = SupabaseService.client;
    final results = await Future.wait([
      db.from('dishes').select(_dishSelect).order('name'),
      db.from('restaurants').select(_restaurantSelect).order('name'),
    ]);
    final dishes = _rows(results[0]).map(_dish).toList();
    final restaurants = _rows(results[1]).map(_restaurant).toList();

    final q = query.trim().toLowerCase();
    bool hit(String s) => q.isEmpty || s.toLowerCase().contains(q);
    return DiningSearchResult(
      dishes: dishes
          .where((d) => hit(d.name) || hit(d.tagline) || d.ingredients.any(hit))
          .toList(),
      restaurants: restaurants.where((r) => hit(r.name) || hit(r.cuisine)).toList(),
    );
  }

  @override
  Future<Dish?> dishById(String id) async {
    final row = await SupabaseService.client
        .from('dishes')
        .select(_dishSelect)
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : _dish(row);
  }

  @override
  Future<Restaurant?> restaurantById(String id) async {
    final row = await SupabaseService.client
        .from('restaurants')
        .select(_restaurantSelect)
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : _restaurant(row);
  }

  @override
  Future<List<Restaurant>> restaurantsServing(String dishId) async {
    final data = await SupabaseService.client
        .from('dish_restaurants')
        .select('restaurants(*)')
        .eq('dish_id', dishId);
    return [
      for (final r in _rows(data))
        if (r['restaurants'] != null)
          _restaurant(r['restaurants'] as Map<String, dynamic>, dishIds: [dishId]),
    ];
  }

  @override
  Future<List<Dish>> dishesServedBy(String restaurantId) async {
    final data = await SupabaseService.client
        .from('dish_restaurants')
        .select('dishes($_dishSelect)')
        .eq('restaurant_id', restaurantId);
    return [
      for (final r in _rows(data))
        if (r['dishes'] != null) _dish(r['dishes'] as Map<String, dynamic>),
    ];
  }

  @override
  Future<List<Dish>> otherDishes({required String excludeId, int limit = 3}) async {
    final data = await SupabaseService.client
        .from('dishes')
        .select(_dishSelect)
        .neq('id', excludeId)
        .limit(limit);
    return _rows(data).map(_dish).toList();
  }
}
