/// A single community report shown in the "recent reports" feed for a station.
/// Contains no reporter identity — only the status, optional note, and time.
class StationReport {
  final String status; // 'working' | 'not_working'
  final String? note;
  final DateTime? reportedAt;

  const StationReport({
    required this.status,
    this.note,
    this.reportedAt,
  });

  bool get isWorking => status == 'working';

  factory StationReport.fromRpc(Map<String, dynamic> row) {
    final at = row['reported_at'];
    return StationReport(
      status: row['status'] as String? ?? '',
      note: row['note'] as String?,
      reportedAt: at == null ? null : DateTime.tryParse(at.toString()),
    );
  }
}
