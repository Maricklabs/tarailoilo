/// Moves data between Supabase and the local drift database.
///
/// Planned behaviour (PROJECT_PROMPT.md section 6 "Sync"):
/// * **Pull:** for each content table, fetch rows where
///   `updated_at > last_sync` and upsert them into drift (rows with
///   `is_deleted = true` are removed locally).
/// * **Push:** user actions made offline are written to the drift `outbox`
///   table and sent to Supabase when the device is back online.
/// * **Conflicts:** last write wins.
///
/// TODO(data owner): implement once the drift database exists in
/// `lib/data/local/`.
class SyncService {
  /// Downloads content changes since the last sync.
  Future<void> pullDeltas() async {}

  /// Uploads queued offline actions from the outbox.
  Future<void> pushOutbox() async {}
}
