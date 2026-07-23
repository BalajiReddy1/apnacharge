/// Domain model for an EV charging station.
///
/// Data is sourced from the Open Charge Map API (https://openchargemap.org),
/// a free and open global registry of EV charging locations. Unlike the old
/// implementation, none of these fields are randomly generated — they reflect
/// the real attributes returned by the API (operator, connector types, power,
/// operational status, usage cost, etc.).
class ChargingStationDetails {
  /// Stable identifier. Corresponds to the Open Charge Map POI `ID`.
  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? website;

  /// Network / operator that runs the station (e.g. "Tata Power", "Statiq").
  final String? operatorName;

  /// Whether the station is currently operational, when known.
  final bool? isOperational;

  /// Human-readable status title (e.g. "Operational", "Planned").
  final String? statusTitle;

  /// Access type, e.g. "Public", "Private - Restricted Access".
  final String? usageType;

  /// Free-form cost description as provided by the operator (e.g. "₹18/kWh").
  final String? usageCost;

  /// Total number of charge points at this location, when known.
  final int? numberOfPoints;

  /// The individual connectors available at the station.
  final List<Connection> connections;

  ChargingStationDetails({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.website,
    this.operatorName,
    this.isOperational,
    this.statusTitle,
    this.usageType,
    this.usageCost,
    this.numberOfPoints,
    this.connections = const [],
  });

  /// Distinct connector types across all connections (e.g. ["CCS", "Type 2"]).
  List<String> get connectorTypes =>
      connections.map((c) => c.type).where((t) => t.isNotEmpty).toSet().toList();

  /// Number of physical connectors. Falls back to the sum of connection
  /// quantities when the API doesn't report an explicit point count.
  int get numberOfConnectors {
    if (numberOfPoints != null && numberOfPoints! > 0) return numberOfPoints!;
    final sum = connections.fold<int>(0, (acc, c) => acc + (c.quantity ?? 1));
    return sum > 0 ? sum : connections.length;
  }

  /// Highest power rating (kW) among the connectors, when known.
  double? get maxPowerKW {
    final powers = connections
        .map((c) => c.powerKW)
        .whereType<double>()
        .where((p) => p > 0)
        .toList();
    if (powers.isEmpty) return null;
    return powers.reduce((a, b) => a > b ? a : b);
  }

  /// A short label describing whether the station is public or private.
  String get accessLabel {
    if (usageType == null) return 'Unknown';
    return usageType!.toLowerCase().contains('public') ? 'Public' : 'Private';
  }

  /// Parse a single POI object from the Open Charge Map `/poi` response.
  factory ChargingStationDetails.fromOcm(Map<String, dynamic> json) {
    final addressInfo = json['AddressInfo'] as Map<String, dynamic>? ?? {};
    final operatorInfo = json['OperatorInfo'] as Map<String, dynamic>?;
    final statusType = json['StatusType'] as Map<String, dynamic>?;
    final usageTypeInfo = json['UsageType'] as Map<String, dynamic>?;
    final connectionsJson = json['Connections'] as List<dynamic>? ?? [];

    final addressParts = <String?>[
      addressInfo['AddressLine1'] as String?,
      addressInfo['AddressLine2'] as String?,
      addressInfo['Town'] as String?,
      addressInfo['StateOrProvince'] as String?,
    ].where((p) => p != null && p.trim().isNotEmpty).toList();

    return ChargingStationDetails(
      placeId: json['ID'].toString(),
      name: (addressInfo['Title'] as String?) ?? 'Charging Station',
      address: addressParts.isNotEmpty
          ? addressParts.join(', ')
          : 'Address unavailable',
      latitude: (addressInfo['Latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (addressInfo['Longitude'] as num?)?.toDouble() ?? 0.0,
      phoneNumber: addressInfo['ContactTelephone1'] as String?,
      website: addressInfo['RelatedURL'] as String?,
      operatorName: operatorInfo?['Title'] as String?,
      isOperational: statusType?['IsOperational'] as bool?,
      statusTitle: statusType?['Title'] as String?,
      usageType: usageTypeInfo?['Title'] as String?,
      usageCost: json['UsageCost'] as String?,
      numberOfPoints: (json['NumberOfPoints'] as num?)?.toInt(),
      connections: connectionsJson
          .whereType<Map<String, dynamic>>()
          .map(Connection.fromOcm)
          .toList(),
    );
  }

  /// Serialize to our own compact JSON shape (used for local favorites).
  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'website': website,
      'operatorName': operatorName,
      'isOperational': isOperational,
      'statusTitle': statusTitle,
      'usageType': usageType,
      'usageCost': usageCost,
      'numberOfPoints': numberOfPoints,
      'connections': connections.map((c) => c.toJson()).toList(),
    };
  }

  /// Reconstruct from our own [toJson] shape. This is symmetric with
  /// [toJson], which is what makes favorites round-trip correctly.
  factory ChargingStationDetails.fromJson(Map<String, dynamic> json) {
    return ChargingStationDetails(
      placeId: json['placeId'].toString(),
      name: json['name'] as String? ?? 'Charging Station',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      operatorName: json['operatorName'] as String?,
      isOperational: json['isOperational'] as bool?,
      statusTitle: json['statusTitle'] as String?,
      usageType: json['usageType'] as String?,
      usageCost: json['usageCost'] as String?,
      numberOfPoints: (json['numberOfPoints'] as num?)?.toInt(),
      connections: (json['connections'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(Connection.fromJson)
          .toList(),
    );
  }
}

/// A single connector at a charging station.
class Connection {
  /// Connector type title, e.g. "CCS (Type 2)", "Type 2 (Socket Only)".
  final String type;

  /// Power rating in kW, when reported.
  final double? powerKW;

  /// How many of this connector exist at the station.
  final int? quantity;

  /// "AC (Single-Phase)", "DC", etc.
  final String? currentType;

  Connection({
    required this.type,
    this.powerKW,
    this.quantity,
    this.currentType,
  });

  factory Connection.fromOcm(Map<String, dynamic> json) {
    final connectionType = json['ConnectionType'] as Map<String, dynamic>?;
    final currentTypeInfo = json['CurrentType'] as Map<String, dynamic>?;
    return Connection(
      type: (connectionType?['Title'] as String?) ?? 'Unknown',
      powerKW: (json['PowerKW'] as num?)?.toDouble(),
      quantity: (json['Quantity'] as num?)?.toInt(),
      currentType: currentTypeInfo?['Title'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'powerKW': powerKW,
        'quantity': quantity,
        'currentType': currentType,
      };

  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
        type: json['type'] as String? ?? 'Unknown',
        powerKW: (json['powerKW'] as num?)?.toDouble(),
        quantity: (json['quantity'] as num?)?.toInt(),
        currentType: json['currentType'] as String?,
      );
}
