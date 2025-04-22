import 'dart:convert';
import 'package:ev_app/models/charging_station_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
class FavoritesManager {
  static const String favoritesKey = 'favorites';

  static Future<List<ChargingStationDetails>> getFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoritesJsonList = prefs.getStringList(favoritesKey);
    if (favoritesJsonList == null) {
      return [];
    } else {
      return favoritesJsonList
          .map((jsonStr) =>
              ChargingStationDetails.fromJson(json.decode(jsonStr) as Map<String, dynamic>))
          .toList();
    }
  }

  static Future<bool> addFavorite(ChargingStationDetails station) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritesJsonList = prefs.getStringList(favoritesKey) ?? [];

    // Avoid duplicates.
    if (favoritesJsonList.any((jsonStr) {
      final existing =
          ChargingStationDetails.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
      return existing.placeId == station.placeId;
    })) {
      return false;
    }
    favoritesJsonList.add(json.encode(station.toJson()));
    return await prefs.setStringList(favoritesKey, favoritesJsonList);
  }

  static Future<bool> removeFavorite(String placeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoritesJsonList = prefs.getStringList(favoritesKey);
    if (favoritesJsonList == null) return false;
    favoritesJsonList.removeWhere((jsonStr) {
      final station =
          ChargingStationDetails.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
      return station.placeId == placeId;
    });
    return await prefs.setStringList(favoritesKey, favoritesJsonList);
  }

  static Future<bool> isFavorite(String placeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoritesJsonList = prefs.getStringList(favoritesKey);
    if (favoritesJsonList == null) return false;
    return favoritesJsonList.any((jsonStr) {
      final station =
          ChargingStationDetails.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
      return station.placeId == placeId;
    });
  }
}
