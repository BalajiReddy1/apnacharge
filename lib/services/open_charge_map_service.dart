import 'dart:convert';
import 'package:ev_app/const/env.dart';
import 'package:ev_app/models/charging_station_details.dart';
import 'package:http/http.dart' as http;

/// Fetches real EV charging station data from the Open Charge Map API.
///
/// Open Charge Map (https://openchargemap.org) is a free, open, community
/// maintained global registry of EV charging locations. It returns genuine
/// attributes — operator, connector types, power ratings, operational status
/// and pricing — which replaces the placeholder/random data the app used
/// before.
class OpenChargeMapService {
  static const String _baseUrl = 'https://api.openchargemap.io/v3/poi';

  final http.Client _client;

  OpenChargeMapService({http.Client? client})
      : _client = client ?? http.Client();

  /// Fetch charging stations within [radiusMeters] of ([latitude], [longitude]).
  ///
  /// Throws an [OpenChargeMapException] on network or API failure so callers
  /// can surface a meaningful message to the user.
  Future<List<ChargingStationDetails>> fetchChargingStations(
    double latitude,
    double longitude,
    double radiusMeters, {
    int maxResults = 100,
  }) async {
    // The OCM API works over distance in km, capped to keep responses light.
    final radiusKm = (radiusMeters / 1000).clamp(1, 100);

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'output': 'json',
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'distance': radiusKm.toStringAsFixed(1),
      'distanceunit': 'KM',
      'maxresults': maxResults.toString(),
      'compact': 'true',
      'verbose': 'false',
      if (Env.openChargeMapApiKey.isNotEmpty) 'key': Env.openChargeMapApiKey,
    });

    try {
      final response = await _client.get(uri, headers: {
        'Accept': 'application/json',
        // OCM asks unauthenticated clients to identify themselves.
        'User-Agent': 'ApnaCharge/1.0 (Flutter)',
      });

      if (response.statusCode != 200) {
        throw OpenChargeMapException(
          'Open Charge Map returned HTTP ${response.statusCode}',
        );
      }

      final decoded = json.decode(response.body);
      if (decoded is! List) {
        throw OpenChargeMapException('Unexpected response format');
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ChargingStationDetails.fromOcm)
          // Drop anything without usable coordinates.
          .where((s) => s.latitude != 0.0 || s.longitude != 0.0)
          .toList();
    } on OpenChargeMapException {
      rethrow;
    } catch (e) {
      throw OpenChargeMapException('Failed to fetch charging stations: $e');
    }
  }

  /// Fetch a single station by its Open Charge Map ID.
  Future<ChargingStationDetails?> fetchStationById(String id) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'output': 'json',
      'chargepointid': id,
      'compact': 'true',
      'verbose': 'false',
      if (Env.openChargeMapApiKey.isNotEmpty) 'key': Env.openChargeMapApiKey,
    });

    try {
      final response = await _client.get(uri, headers: {
        'Accept': 'application/json',
        'User-Agent': 'ApnaCharge/1.0 (Flutter)',
      });
      if (response.statusCode != 200) return null;

      final decoded = json.decode(response.body);
      if (decoded is List && decoded.isNotEmpty) {
        return ChargingStationDetails.fromOcm(
            decoded.first as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();
}

/// Raised when the Open Charge Map API can't be reached or returns an error.
class OpenChargeMapException implements Exception {
  final String message;
  OpenChargeMapException(this.message);

  @override
  String toString() => message;
}
