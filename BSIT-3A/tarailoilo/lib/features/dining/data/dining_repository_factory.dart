import 'package:flutter/foundation.dart' show kDebugMode;

import '../../../data/remote/supabase_service.dart';
import 'dining_models.dart';
import 'dining_repository.dart';
import 'supabase_dining_repository.dart';

/// Picks the data source for Dining.
///
/// * Supabase configured  -> real data.
/// * Not configured, debug build -> built-in sample data, so the UI still runs.
/// * Not configured, release build -> an error state, never fake data.
DiningRepository resolveDiningRepository() {
  if (SupabaseService.isReady) return const SupabaseDiningRepository();
  if (kDebugMode) return const SampleDiningRepository();
  return const _UnconfiguredDiningRepository();
}

class _UnconfiguredDiningRepository implements DiningRepository {
  const _UnconfiguredDiningRepository();

  Never _fail() => throw StateError('Dining needs Supabase to be configured.');

  @override
  Future<DiningSearchResult> search(String query) async => _fail();
  @override
  Future<Dish?> dishById(String id) async => _fail();
  @override
  Future<Restaurant?> restaurantById(String id) async => _fail();
  @override
  Future<List<Restaurant>> restaurantsServing(String dishId) async => _fail();
  @override
  Future<List<Dish>> dishesServedBy(String restaurantId) async => _fail();
  @override
  Future<List<Dish>> otherDishes({required String excludeId, int limit = 3}) async => _fail();
}
