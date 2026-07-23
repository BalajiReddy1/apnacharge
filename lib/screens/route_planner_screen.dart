import 'dart:convert';
import 'dart:math';
import 'package:ev_app/const/colors.dart';
import 'package:ev_app/const/env.dart';
import 'package:ev_app/models/charging_station_details.dart';
import 'package:ev_app/services/open_charge_map_service.dart';
import 'package:ev_app/widgets/places_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({Key? key}) : super(key: key);

  @override
  _RoutePlannerScreenState createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final OpenChargeMapService _chargeMapService = OpenChargeMapService();

  String get _apiKey => Env.googleMapsApiKey;

  // India centroid as a neutral fallback until the user's location resolves.
  LatLng _mapCenter = const LatLng(20.5937, 78.9629);
  bool _locating = true;

  LatLng? _originLatLng;
  String _originLabel = 'Your location';
  LatLng? _destinationLatLng;
  String? _destinationLabel;

  bool _planning = false;
  String? _error;
  String? _distanceText;
  String? _durationText;
  int _chargersOnRoute = 0;

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
  }

  @override
  void dispose() {
    _chargeMapService.dispose();
    super.dispose();
  }

  /// Resolve the user's location once and use it as the default origin.
  Future<void> _initCurrentLocation() async {
    try {
      final loc = await _fetchCurrentLocation();
      if (!mounted) return;
      setState(() {
        _originLatLng = loc;
        _mapCenter = loc;
        _locating = false;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(loc));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locating = false;
        _originLabel = 'Choose origin';
      });
    }
  }

  Future<LatLng> _fetchCurrentLocation() async {
    final location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) throw Exception('Location service disabled');
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('Location permission denied');
      }
    }

    final current = await location.getLocation();
    return LatLng(current.latitude!, current.longitude!);
  }

  /// Open the autocomplete search and store the chosen place.
  Future<void> _pickPlace({required bool isOrigin}) async {
    if (_apiKey.isEmpty) {
      _showError('Search needs a Google API key. See setup in the README.');
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlacesAutocomplete(
          apiKey: _apiKey,
          onPlaceSelected: (placeId, description, LatLng latLng) {
            setState(() {
              if (isOrigin) {
                _originLatLng = latLng;
                _originLabel = description;
              } else {
                _destinationLatLng = latLng;
                _destinationLabel = description;
              }
            });
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Directions
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> _fetchRoute(
      String origin, String destination) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${Uri.encodeComponent(origin)}&destination=${Uri.encodeComponent(destination)}&key=$_apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch route (HTTP ${response.statusCode})');
  }

  List<LatLng> _decodePolyline(String encoded) {
    final poly = <LatLng>[];
    int index = 0, lat = 0, lng = 0;
    final len = encoded.length;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  Future<void> _planRoute() async {
    if (_originLatLng == null || _destinationLatLng == null) {
      setState(() => _error = 'Choose both an origin and a destination.');
      return;
    }

    setState(() {
      _planning = true;
      _error = null;
      _distanceText = null;
      _durationText = null;
      _chargersOnRoute = 0;
    });

    try {
      final origin =
          '${_originLatLng!.latitude},${_originLatLng!.longitude}';
      final destination =
          '${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}';

      final routeData = await _fetchRoute(origin, destination);
      if (routeData['status'] != 'OK') {
        setState(() => _error = 'Could not find a route between those points.');
        return;
      }

      final route = routeData['routes'][0];
      final points =
          _decodePolyline(route['overview_polyline']['points'] as String);
      final leg = route['legs'][0];

      setState(() {
        _markers
          ..clear()
          ..add(Marker(
            markerId: const MarkerId('origin'),
            position: _originLatLng!,
            infoWindow: const InfoWindow(title: 'Origin'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
          ))
          ..add(Marker(
            markerId: const MarkerId('destination'),
            position: _destinationLatLng!,
            infoWindow: const InfoWindow(title: 'Destination'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed),
          ));
        _polylines
          ..clear()
          ..add(Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: AppColors.medgreen,
            width: 5,
          ));
        _distanceText = leg['distance']?['text'] as String?;
        _durationText = leg['duration']?['text'] as String?;
      });

      await _fetchChargingStationsAlongRoute(points);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(_boundsFromLatLngList(points), 60),
      );
    } catch (e) {
      debugPrint('Route error: $e');
      setState(() => _error = 'Something went wrong planning the route.');
    } finally {
      if (mounted) setState(() => _planning = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Chargers along the route
  // ---------------------------------------------------------------------------

  /// Sample points evenly along the route and query Open Charge Map around
  /// each, so results genuinely follow the corridor rather than clustering at
  /// a single midpoint. Results are de-duplicated by station id.
  Future<void> _fetchChargingStationsAlongRoute(List<LatLng> points) async {
    if (points.isEmpty) return;

    const int maxSamples = 10;
    final samples = _sampleAlongRoute(points, maxSamples: maxSamples);
    // Radius per sample scales with spacing so consecutive circles overlap,
    // clamped to a sane corridor width.
    final radius = (_routeLength(points) / max(samples.length, 1) / 2)
        .clamp(5000.0, 25000.0);

    final results = await Future.wait(
      samples.map(
        (p) => _chargeMapService
            .fetchChargingStations(p.latitude, p.longitude, radius)
            .catchError((_) => <ChargingStationDetails>[]),
      ),
    );

    final byId = <String, ChargingStationDetails>{};
    for (final list in results) {
      for (final s in list) {
        byId[s.placeId] = s;
      }
    }

    if (!mounted) return;
    setState(() {
      for (final s in byId.values) {
        _markers.add(Marker(
          markerId: MarkerId(s.placeId),
          position: LatLng(s.latitude, s.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: s.name, snippet: s.operatorName),
        ));
      }
      _chargersOnRoute = byId.length;
    });
  }

  double _routeLength(List<LatLng> points) {
    double total = 0;
    for (int i = 1; i < points.length; i++) {
      total += _calculateDistance(points[i - 1].latitude,
          points[i - 1].longitude, points[i].latitude, points[i].longitude);
    }
    return total;
  }

  List<LatLng> _sampleAlongRoute(List<LatLng> points,
      {required int maxSamples}) {
    if (points.length <= 2) return points;

    final total = _routeLength(points);
    // Aim for ~maxSamples points, but never closer than 5 km apart.
    final step = max(total / maxSamples, 5000.0);

    final samples = <LatLng>[points.first];
    double acc = 0;
    for (int i = 1; i < points.length; i++) {
      acc += _calculateDistance(points[i - 1].latitude, points[i - 1].longitude,
          points[i].latitude, points[i].longitude);
      if (acc >= step) {
        samples.add(points[i]);
        acc = 0;
      }
    }
    samples.add(points.last);
    return samples;
  }

  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double r = 6371000;
    final dLat = _degToRad(lat2 - lat1);
    final dLng = _degToRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double x0 = list.first.latitude, x1 = list.first.latitude;
    double y0 = list.first.longitude, y1 = list.first.longitude;
    for (final latLng in list) {
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(x0, y0),
      northeast: LatLng(x1, y1),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Route Planner',
          style: GoogleFonts.arimo(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              children: [
                _locationField(
                  icon: Icons.my_location,
                  iconColor: AppColors.medgreen,
                  label: 'From',
                  value: _originLabel,
                  onTap: () => _pickPlace(isOrigin: true),
                ),
                const SizedBox(height: 8),
                _locationField(
                  icon: Icons.location_on,
                  iconColor: Colors.red,
                  label: 'To',
                  value: _destinationLabel ?? 'Choose destination',
                  onTap: () => _pickPlace(isOrigin: false),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _planning ? null : _planRoute,
                    child: _planning
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Plan Route'),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w500),
                    ),
                  ),
                if (_distanceText != null) _buildTripSummary(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _locating
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Getting your location…'),
                      ],
                    ),
                  )
                : GoogleMap(
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLng(_mapCenter),
                      );
                    },
                    markers: _markers,
                    polylines: _polylines,
                    initialCameraPosition:
                        CameraPosition(target: _mapCenter, zoom: 12),
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripSummary() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.medgreen.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(Icons.straighten, _distanceText ?? '—'),
          _summaryItem(Icons.schedule, _durationText ?? '—'),
          _summaryItem(
            Icons.ev_station,
            '$_chargersOnRoute on the way',
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.darkgreen),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Widget _locationField({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.search, color: Colors.black38, size: 20),
          ],
        ),
      ),
    );
  }
}
