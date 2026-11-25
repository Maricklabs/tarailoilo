import '../../core/constants.dart';
import '../../core/errors.dart';
import '../../models/app_event.dart';
import 'supabase_service.dart';

/// Reads approved events from the Supabase `events` table.
///
/// RLS lets everyone (guests too) read rows where `is_deleted = false`.
class EventsService {
  /// Events that end on or after the first day of the current month, so the
  /// month calendar also shows this month's past events.
  Future<List<AppEvent>> fetchEvents({DateTime? now}) async {
    if (!SupabaseService.isReady) {
      throw const AppException('Online events are not configured (.env missing).');
    }
    final today = now ?? DateTime.now();
    final monthStart = DateTime(today.year, today.month, 1).toUtc().toIso8601String();

    final rows = await SupabaseService.client
        .from('events')
        .select()
        .eq('is_deleted', false)
        .gte('ends_at', monthStart)
        .order('starts_at')
        .timeout(AppConstants.networkTimeout);

    return rows.map(AppEvent.fromJson).toList();
  }
}
