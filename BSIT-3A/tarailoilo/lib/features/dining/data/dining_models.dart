/// Plain models for the Dining feature (S9, S10, S11).
///
/// TODO: when the Supabase / offline FTS layer exists, swap the sample data in
/// `dining_repository.dart` for real queries and map rows into these.
library;

/// An allergen statement made BY a restaurant about a dish, on a date.
///
/// App rule: allergens are only ever shown as "Declared by X as of DATE".
/// Never present them as a safety guarantee.
class AllergenDeclaration {
  const AllergenDeclaration({
    required this.restaurantId,
    required this.restaurantName,
    required this.declaredOn,
    required this.allergens,
  });

  final String restaurantId;
  final String restaurantName;
  final DateTime declaredOn;

  /// Empty means the restaurant declared no allergens (still not "safe").
  final List<String> allergens;
}

class Dish {
  const Dish({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.origin,
    required this.ingredients,
    required this.declarations,
    required this.restaurantIds,
    this.imageUrl,
    this.isIloiloFavorite = false,
  });

  final String id;
  final String name;

  /// One-liner shown on cards.
  final String tagline;

  /// "What is it" paragraph.
  final String description;

  /// "The origin of ..." history paragraph.
  final String origin;
  final List<String> ingredients;
  final List<AllergenDeclaration> declarations;
  final List<String> restaurantIds;
  final String? imageUrl;
  final bool isIloiloFavorite;
}

class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.address,
    required this.hours,
    required this.dishIds,
    this.phone,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;

  /// Short label, e.g. "Batchoy".
  final String cuisine;
  final String address;
  final String hours;
  final String? phone;
  final List<String> dishIds;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
}

/// Combined result of a dining search.
class DiningSearchResult {
  const DiningSearchResult({required this.dishes, required this.restaurants});

  final List<Dish> dishes;
  final List<Restaurant> restaurants;

  bool get isEmpty => dishes.isEmpty && restaurants.isEmpty;
}
