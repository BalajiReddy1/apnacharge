// lib/services/places_services.dart
import 'package:ev_app/models/charging_station_details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacesService {
  final String apiKey = "YOUR_GOOGLE_MAPS_API_KEY";

  Future<List<ChargingStationDetails>> fetchChargingStations(
      double latitude, double longitude, double radius) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius&keyword=ev+charging+station&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          List<dynamic> results = data['results'];
          List<ChargingStationDetails> stations = results
              .where((place) =>
                  place != null &&
                  place['place_id'] != null &&
                  place['types'] != null &&
                  place['types'].contains('point_of_interest') &&
                  place['name'] != null &&
                  (place['name'] as String).toLowerCase().contains('charging'))
              .map((json) => ChargingStationDetails.fromJson(json))
              .toList();
          return stations;
        } else {
          throw Exception('Error from Places API: ${data['status']}');
        }
      } else {
        throw Exception('Failed to fetch charging stations');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Failed to fetch charging stations');
    }
  }

  // New method for station details:
  Future<ChargingStationDetails> fetchStationDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=place_id,name,formatted_address,formatted_phone_number,website,rating,opening_hours,reviews&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'OK') {
          return ChargingStationDetails.fromJson(jsonData['result']);
        } else {
          throw Exception('Error from Places API: ${jsonData['status']}');
        }
      } else {
        throw Exception('Failed to fetch station details');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Failed to fetch station details');
    }
  }
}
