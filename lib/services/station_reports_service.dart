import 'package:ev_app/models/station_status_summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Valid report values. Kept in sync with the CHECK constraint in the
/// `station_reports` table so the client never sends an out-of-range value.
class ReportStatus {
  static const working = 'working';
  static const notWorking = 'not_working';
  static const _allowed = {working, notWorking};
}

/// Reads and writes crowd-sourced station reliability reports.
///
/// Security is enforced server-side by Row Level Security: a user can only
/// read/write their own report row, and the public summary comes from a
/// SECURITY DEFINER function that returns aggregates only. This service adds
/// client-side guards (auth + input validation) so bad calls fail fast.
class StationReportsService {
  static const _table = 'station_reports';

  final SupabaseClient _client;

  StationReportsService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  bool get _isSignedIn => _client.auth.currentUser != null;

  /// Aggregate community status for a station (counts only, no PII).
  Future<StationStatusSummary> getSummary(String stationId) async {
    final result = await _client.rpc(
      'get_station_status_summary',
      params: {'p_station_id': stationId},
    );
    if (result is List && result.isNotEmpty) {
      return StationStatusSummary.fromRpc(result.first as Map<String, dynamic>);
    }
    return StationStatusSummary.empty;
  }

  /// The current user's own report for this station, if any
  /// (`ReportStatus.working` / `ReportStatus.notWorking`), else null.
  Future<String?> getMyReport(String stationId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final row = await _client
        .from(_table)
        .select('status')
        .eq('station_id', stationId)
        .eq('user_id', userId)
        .maybeSingle();

    return row == null ? null : row['status'] as String?;
  }

  /// Submit or change the current user's report for a station.
  Future<void> report(String stationId, String status) async {
    if (!ReportStatus._allowed.contains(status)) {
      throw ArgumentError('Invalid report status: $status');
    }
    if (!_isSignedIn) {
      throw StateError('You must be signed in to report a station.');
    }

    // One report per (station, user): upsert on the unique key. user_id is
    // filled server-side from auth.uid() and validated by RLS.
    await _client.from(_table).upsert(
      {'station_id': stationId, 'status': status},
      onConflict: 'station_id,user_id',
    );
  }

  /// Retract the current user's report for a station.
  Future<void> retract(String stationId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client
        .from(_table)
        .delete()
        .eq('station_id', stationId)
        .eq('user_id', userId);
  }
}
