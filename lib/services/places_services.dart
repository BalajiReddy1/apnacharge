// lib/services/places_services.dart
//
// Thin wrapper around Google Places used for location *search / autocomplete*
// only. Charging-station data now comes from [OpenChargeMapService], which
// returns real EV attributes instead of Google POIs.
import 'package:ev_app/const/env.dart';

class PlacesService {
  /// Google Maps / Places API key, sourced from the environment.
  /// Consumed by the autocomplete widget for location search.
  String get apiKey => Env.googleMapsApiKey;
}
