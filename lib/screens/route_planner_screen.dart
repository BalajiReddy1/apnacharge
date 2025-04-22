import 'dart:convert';
import 'dart:math';
import 'package:ev_app/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:ev_app/services/places_services.dart';

class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({Key? key}) : super(key: key);

  @override
  _RoutePlannerScreenState createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Default current location fallback (San Francisco)
  LatLng _currentLocationCoordinates = const LatLng(37.773972, -122.431297);
  final String _apiKey =
      "YOUR_GOOGLE_MAPS_API_KEY"; // Replace with your API key.
  final PlacesService _placesService = PlacesService();

  LatLng? _origin;
  LatLng? _destination;

  @override
  void initState() {
    super.initState();
    _setCurrentLocationAsOrigin();
  }

  /// Fetch current location and update the origin field as well as the map center.
  Future<void> _setCurrentLocationAsOrigin() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    LocationData currentLocation = await location.getLocation();
    setState(() {
      _currentLocationCoordinates = LatLng(
          currentLocation.latitude ?? _currentLocationCoordinates.latitude,
          currentLocation.longitude ?? _currentLocationCoordinates.longitude);
      // Pre-fill the origin text field with a coordinate string.
      _originController.text =
          "${_currentLocationCoordinates.latitude.toStringAsFixed(5)}, ${_currentLocationCoordinates.longitude.toStringAsFixed(5)}";
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentLocationCoordinates),
        );
      }
    });
  }

  /// -------------------------------
  /// 1. Directions API Call and Polyline Decoding
  /// -------------------------------

  /// Calls the Google Directions API with origin, destination (and waypoints if needed)
  Future<Map<String, dynamic>> _fetchRoute(String origin, String destination,
      {List<String>? waypoints}) async {
    String waypointParam = "";
    if (waypoints != null && waypoints.isNotEmpty) {
      waypointParam = "&waypoints=" + waypoints.join("|");
    }
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${Uri.encodeComponent(origin)}&destination=${Uri.encodeComponent(destination)}$waypointParam&key=$_apiKey";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch route");
    }
  }

  /// Decodes an encoded polyline string into a list of LatLng
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = LatLng(lat / 1E5, lng / 1E5);
      poly.add(p);
    }
    return poly;
  }

  /// -------------------------------
  /// 2. Plan Route and Display on Map
  /// -------------------------------
  Future<void> _planRoute() async {
    // Use the text from the controllers, default is the current location in origin.
    if (_originController.text.isEmpty || _destinationController.text.isEmpty)
      return;
    String originInput = _originController.text;
    String destinationInput = _destinationController.text;

    try {
      Map<String, dynamic> routeData =
          await _fetchRoute(originInput, destinationInput);
      if (routeData['status'] == 'OK') {
        final route = routeData['routes'][0];
        final overviewPolyline = route['overview_polyline']['points'];
        List<LatLng> polylineCoordinates = _decodePolyline(overviewPolyline);

        // Get origin and destination from the first leg.
        final leg = route['legs'][0];
        _origin =
            LatLng(leg['start_location']['lat'], leg['start_location']['lng']);
        _destination =
            LatLng(leg['end_location']['lat'], leg['end_location']['lng']);

        setState(() {
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId("origin"),
              position: _origin!,
              infoWindow: const InfoWindow(title: "Origin"),
            ),
          );
          _markers.add(
            Marker(
              markerId: const MarkerId("destination"),
              position: _destination!,
              infoWindow: const InfoWindow(title: "Destination"),
            ),
          );
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId("route"),
              points: polylineCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          );
        });

        // Fetch and display charging stations along the route.
        _fetchChargingStationsAlongRoute(polylineCoordinates);

        // Recenter map to fit the route.
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(
              _boundsFromLatLngList(polylineCoordinates), 50),
        );
      } else {
        print("Route error: ${routeData['status']}");
      }
    } catch (e) {
      print("Error planning route: $e");
    }
  }

  /// Computes and fetches charging stations based on the route polyline.
  Future<void> _fetchChargingStationsAlongRoute(
      List<LatLng> polylineCoordinates) async {
    double minLat = polylineCoordinates.first.latitude;
    double maxLat = polylineCoordinates.first.latitude;
    double minLng = polylineCoordinates.first.longitude;
    double maxLng = polylineCoordinates.first.longitude;

    for (var point in polylineCoordinates) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }
    double centerLat = (minLat + maxLat) / 2;
    double centerLng = (minLng + maxLng) / 2;
    LatLng center = LatLng(centerLat, centerLng);

    double radius = _calculateDistance(centerLat, centerLng, maxLat, maxLng);

    try {
      List stations = await _placesService.fetchChargingStations(
          center.latitude, center.longitude, radius);
      print("Fetched ${stations.length} charging stations along the route.");

      setState(() {
        for (var station in stations) {
          _markers.add(
            Marker(
              markerId: MarkerId(station.placeId),
              position: LatLng(station.latitude, station.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
              infoWindow: InfoWindow(title: station.name),
            ),
          );
        }
      });
    } catch (e) {
      print("Error fetching charging stations along route: $e");
    }
  }

  Future<LatLng> _fetchCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Exception("Location service disabled");
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception("Location permission denied");
      }
    }

    LocationData currentLocation = await location.getLocation();
    return LatLng(currentLocation.latitude!, currentLocation.longitude!);
  }

  /// Calculate distance in meters between two coordinates.
  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double R = 6371000;
    double dLat = _degToRad(lat2 - lat1);
    double dLng = _degToRad(lng2 - lng1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);

  /// Helper to get bounds from a list of LatLng.
  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double x0 = list.first.latitude, x1 = list.first.latitude;
    double y0 = list.first.longitude, y1 = list.first.longitude;
    for (LatLng latLng in list) {
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

  /// -------------------------------
  /// 3. Build the UI
  /// -------------------------------
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LatLng>(
      future:
          _fetchCurrentLocation(), // The function to fetch the user's current location.
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the location is being fetched, show a loading indicator.
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          // If there's an error (e.g., permissions not granted), show an error message.
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (snapshot.hasData) {
          // When the location is successfully retrieved, set up the map and planner.
          _currentLocationCoordinates =
              snapshot.data!; // Update with fetched location.

          return Scaffold(
            backgroundColor: AppColors.medgreen,
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              backgroundColor: AppColors.medgreen,
              title: Text(
                'Route Planner',
                style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1),
              ),
            ),
            body: Column(
              children: [
                // Input fields for origin and destination.
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: AppColors.bglight,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                      controller: _originController,
                      decoration: InputDecoration(
                        hintText: "Enter Origin",
                        hintStyle: GoogleFonts.arimo(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: AppColors.bglight,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                      controller: _destinationController,
                      decoration: InputDecoration(
                        hintText: "Enter Destination",
                        hintStyle: GoogleFonts.arimo(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6),
                ElevatedButton(
                  onPressed: _planRoute,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bglight,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    textStyle: GoogleFonts.arimo(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(
                    "Plan Route",
                    style: GoogleFonts.arimo(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1),
                  ),
                ),
                SizedBox(height: 10),
                // The map, centered on the current location.
                Expanded(
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLng(_currentLocationCoordinates),
                      );
                    },
                    markers: _markers,
                    polylines: _polylines,
                    initialCameraPosition: CameraPosition(
                      target: _currentLocationCoordinates,
                      zoom: 14,
                    ),
                    myLocationEnabled: true,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox(); // Safety fallback, though not typically reached.
      },
    );
  }
}
