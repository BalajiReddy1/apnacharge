import 'dart:math';
import 'dart:async';
import 'package:ev_app/const/colors.dart';
import 'package:ev_app/screens/route_planner_screen.dart';
import 'package:ev_app/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ev_app/models/charging_station_details.dart';
import 'package:ev_app/services/places_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ev_app/widgets/places_autocomplete.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController _mapController;
  LocationData? _currentLocation;
  final Location _locationService = Location();
  final Set<Marker> _markers = {};
  final PlacesService _placesService = PlacesService();
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();

    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        print('Location service not enabled.');
        return;
      }
    }

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('Location permission not granted.');
        return;
      }
    }

    _currentLocation = await _locationService.getLocation();
    print('_currentLocation: $_currentLocation');
    if (_currentLocation != null) {
      setState(() {});
      _fetchChargingStations(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
        5000,
      );
    }
  }

  Future<void> _fetchChargingStations(
      double latitude, double longitude, double radius) async {
    if (_isFetching) return;
    setState(() {
      _isFetching = true;
    });

    try {
      List<ChargingStationDetails> stations = await _placesService
          .fetchChargingStations(latitude, longitude, radius);
      print('Charging stations fetched: ${stations.length}');

      // Create markers for each station using onTap callback to show bottom sheet.
      Set<Marker> newMarkers = stations.map((station) {
        return Marker(
          markerId: MarkerId(station.placeId),
          position: LatLng(station.latitude, station.longitude),
          infoWindow: const InfoWindow(title: ""),
          onTap: () {
            _showStationBottomSheet(station);
          },
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );
      }).toSet();

      setState(() {
        _markers.addAll(newMarkers);
        _isFetching = false;
      });
    } catch (e) {
      print('Error fetching charging stations: $e');
      setState(() {
        _isFetching = false;
      });
    }
  }

  void _showStationBottomSheet(ChargingStationDetails station) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Station Name
                Text(
                  station.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                // Address Row
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        station.address,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Rating Row
                if (station.rating != null)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${station.rating}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                // Dummy data fields
                Text(
                  "Number of Connectors: ${station.numberOfConnectors}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Connector Types: ${station.connectorTypes.join(', ')}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Status: ${station.status}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Price per 15 min: ₹${station.pricePer15Min}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Timing: ${station.timing}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Accessibility: ${station.isPublic ? 'Public' : 'Private'}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Capacity: ${station.capacity}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                // Get Directions Button
                ElevatedButton.icon(
                  onPressed: () {
                    _openDirections(station.latitude, station.longitude);
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text("Get Directions"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                // Close Button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacesAutocomplete(
          apiKey: _placesService
              .apiKey, // Assuming _placesService holds your API key
          onPlaceSelected: (placeId, description, LatLng latLng) {
            // Use the selected location to recenter the map
            _mapController.animateCamera(
              CameraUpdate.newLatLng(latLng),
            );
            // Optionally re-fetch charging stations for the new location:
            _fetchChargingStations(latLng.latitude, latLng.longitude, 5000);
          },
        ),
      ),
    );
  }

  // Launch directions in Google Maps using a URL scheme.
  Future<void> _openDirections(double lat, double lng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch directions.')));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    print('Camera moved: ${position.target}');
  }

  void _onCameraIdle() async {
    if (_mapController != null) {
      LatLngBounds bounds = await _mapController.getVisibleRegion();
      double centerLat =
          (bounds.northeast.latitude + bounds.southwest.latitude) / 2;
      double centerLng =
          (bounds.northeast.longitude + bounds.southwest.longitude) / 2;
      double radius = _calculateRadius(bounds);
      _fetchChargingStations(centerLat, centerLng, radius);
    }
  }

  double _calculateRadius(LatLngBounds bounds) {
    double latDistance = _calculateDistance(
      bounds.northeast.latitude,
      bounds.northeast.longitude,
      bounds.southwest.latitude,
      bounds.northeast.longitude,
    );
    double lngDistance = _calculateDistance(
      bounds.northeast.latitude,
      bounds.northeast.longitude,
      bounds.northeast.latitude,
      bounds.southwest.longitude,
    );
    return (latDistance + lngDistance) / 2;
  }

  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double radiusOfEarth = 6371000; // in meters
    double dLat = (lat2 - lat1) * (pi / 180);
    double dLng = (lng2 - lng1) * (pi / 180);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radiusOfEarth * c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(), // Assuming you have an AppDrawer widget
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.medgreen,
        title: Text(
          'Apna Charge',
          style: GoogleFonts.arimo(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
              color: Colors.white,
            ),
            onPressed: _handleSearch,
          ),
          IconButton(
            icon: const Icon(
              Icons.directions,
              color: Colors.white,
            ),
            onPressed: () {
              // Navigate to the Route Planner screen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RoutePlannerScreen()),
              );
            },
          ),
        ],
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentLocation!.latitude!,
                  _currentLocation!.longitude!,
                ),
                zoom: 14,
              ),
              myLocationEnabled: true,
              markers: _markers,
              zoomControlsEnabled: false,
            ),
    );
  }
}
