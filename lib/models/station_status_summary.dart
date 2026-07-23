/// Aggregated community reliability for a station: how many recent reports
/// say it's working vs. not, and when it was last reported. Individual
/// reporters are never exposed — only these counts.
class StationStatusSummary {
  final int workingCount;
  final int notWorkingCount;
  final DateTime? lastReported;

  const StationStatusSummary({
    required this.workingCount,
    required this.notWorkingCount,
    this.lastReported,
  });

  static const empty =
      StationStatusSummary(workingCount: 0, notWorkingCount: 0);

  int get totalCount => workingCount + notWorkingCount;

  bool get hasReports => totalCount > 0;

  /// Fraction of recent reports that say "working" (0.0–1.0), or null when
  /// there are no reports to judge from.
  double? get workingRatio =>
      totalCount == 0 ? null : workingCount / totalCount;

  factory StationStatusSummary.fromRpc(Map<String, dynamic> row) {
    final last = row['last_reported'];
    return StationStatusSummary(
      workingCount: (row['working_count'] as num?)?.toInt() ?? 0,
      notWorkingCount: (row['not_working_count'] as num?)?.toInt() ?? 0,
      lastReported: last == null ? null : DateTime.tryParse(last.toString()),
    );
  }
}
