import 'package:ev_app/models/charging_station_details.dart';

/// User-selected filters applied to the list/map of charging stations.
///
/// An empty filter matches everything. Matching is done client-side against
/// the already-fetched Open Charge Map data, so toggling is instant.
class StationFilter {
  /// Connector categories to require (matches if the station has ANY of them).
  /// Empty means "any connector".
  final Set<String> connectors;

  /// Minimum max-power in kW. 0 means "any power".
  final double minPowerKW;

  /// Hide stations the data explicitly marks as out of service.
  final bool hideOutOfService;

  const StationFilter({
    this.connectors = const {},
    this.minPowerKW = 0,
    this.hideOutOfService = false,
  });

  /// Selectable connector categories, matched as case-insensitive substrings
  /// against the connector titles Open Charge Map returns.
  static const List<String> connectorOptions = [
    'CCS',
    'CHAdeMO',
    'Type 2',
    'Type 1',
    'Tesla',
    'GB/T',
  ];

  /// Selectable minimum-power presets (label -> kW).
  static const Map<String, double> powerOptions = {
    'Any': 0,
    '22+ kW': 22,
    '50+ kW': 50,
    '150+ kW': 150,
  };

  bool get isActive =>
      connectors.isNotEmpty || minPowerKW > 0 || hideOutOfService;

  /// Number of active filter groups (for a badge on the filter button).
  int get activeCount =>
      (connectors.isNotEmpty ? 1 : 0) +
      (minPowerKW > 0 ? 1 : 0) +
      (hideOutOfService ? 1 : 0);

  StationFilter copyWith({
    Set<String>? connectors,
    double? minPowerKW,
    bool? hideOutOfService,
  }) {
    return StationFilter(
      connectors: connectors ?? this.connectors,
      minPowerKW: minPowerKW ?? this.minPowerKW,
      hideOutOfService: hideOutOfService ?? this.hideOutOfService,
    );
  }

  /// Whether a station passes this filter.
  bool matches(ChargingStationDetails s) {
    if (hideOutOfService && s.isOperational == false) return false;

    if (minPowerKW > 0) {
      final power = s.maxPowerKW;
      if (power == null || power < minPowerKW) return false;
    }

    if (connectors.isNotEmpty) {
      final types = s.connectorTypes.map((t) => t.toLowerCase()).toList();
      final hasAny = connectors.any(
        (c) => types.any((t) => t.contains(c.toLowerCase())),
      );
      if (!hasAny) return false;
    }

    return true;
  }
}
