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
import 'package:ev_app/models/station_status_summary.dart';
import 'package:ev_app/services/open_charge_map_service.dart';
import 'package:ev_app/services/places_services.dart';
import 'package:ev_app/services/favorites_manager.dart';
import 'package:ev_app/services/station_reports_service.dart';
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
  final OpenChargeMapService _chargeMapService = OpenChargeMapService();
  bool _isFetching = false;

  @override
  void dispose() {
    _chargeMapService.dispose();
    super.dispose();
  }

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
        debugPrint('Location service not enabled.');
        return;
      }
    }

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        debugPrint('Location permission not granted.');
        return;
      }
    }

    _currentLocation = await _locationService.getLocation();
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
      List<ChargingStationDetails> stations = await _chargeMapService
          .fetchChargingStations(latitude, longitude, radius);
      debugPrint('Charging stations fetched: ${stations.length}');

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
      debugPrint('Error fetching charging stations: $e');
      setState(() {
        _isFetching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load charging stations. Check your connection.'),
          ),
        );
      }
    }
  }

  void _showStationBottomSheet(ChargingStationDetails station) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return _StationDetailsSheet(
          station: station,
          onDirections: () =>
              _openDirections(station.latitude, station.longitude),
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
    // No-op: camera position is user-location-sensitive and must not be logged.
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
      floatingActionButton: _currentLocation == null
          ? null
          : FloatingActionButton(
              onPressed: _recenterToMyLocation,
              tooltip: 'My location',
              child: const Icon(Icons.my_location),
            ),
      body: _currentLocation == null
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location…'),
                ],
              ),
            )
          : Stack(
              children: [
                GoogleMap(
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
                // Status pill: fetching spinner or station count.
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _isFetching
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Finding stations…'),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.ev_station,
                                    size: 16, color: AppColors.medgreen),
                                const SizedBox(width: 6),
                                Text(
                                  '${_markers.length} stations nearby',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// Animate the map back to the user's current location.
  Future<void> _recenterToMyLocation() async {
    if (_currentLocation == null) return;
    _mapController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      ),
    );
  }
}

/// Bottom sheet showing real Open Charge Map details for a station, with a
/// favorites toggle and a "Get Directions" action.
class _StationDetailsSheet extends StatefulWidget {
  final ChargingStationDetails station;
  final VoidCallback onDirections;

  const _StationDetailsSheet({
    required this.station,
    required this.onDirections,
  });

  @override
  State<_StationDetailsSheet> createState() => _StationDetailsSheetState();
}

class _StationDetailsSheetState extends State<_StationDetailsSheet> {
  final StationReportsService _reportsService = StationReportsService();

  bool _isFavorite = false;
  bool _favLoaded = false;

  StationStatusSummary? _summary;
  String? _myReport;
  bool _reportsLoading = true;
  bool _reportsAvailable = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
    _loadReports();
  }

  Future<void> _loadFavorite() async {
    final fav = await FavoritesManager.isFavorite(widget.station.placeId);
    if (mounted) {
      setState(() {
        _isFavorite = fav;
        _favLoaded = true;
      });
    }
  }

  Future<void> _loadReports() async {
    try {
      final summary =
          await _reportsService.getSummary(widget.station.placeId);
      final mine = await _reportsService.getMyReport(widget.station.placeId);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _myReport = mine;
        _reportsLoading = false;
        _reportsAvailable = true;
      });
    } catch (_) {
      // Backend not reachable / migration not applied yet — degrade quietly.
      if (!mounted) return;
      setState(() {
        _reportsLoading = false;
        _reportsAvailable = false;
      });
    }
  }

  Future<void> _submitReport(String status) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (_myReport == status) {
        // Tapping your current vote retracts it.
        await _reportsService.retract(widget.station.placeId);
        _myReport = null;
      } else {
        await _reportsService.report(widget.station.placeId, status);
        _myReport = status;
      }
      final summary =
          await _reportsService.getSummary(widget.station.placeId);
      if (!mounted) return;
      setState(() => _summary = summary);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not submit your report.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await FavoritesManager.removeFavorite(widget.station.placeId);
    } else {
      await FavoritesManager.addFavorite(widget.station);
    }
    if (mounted) {
      setState(() => _isFavorite = !_isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to favorites' : 'Removed from favorites',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final station = widget.station;
    final bool? operational = station.isOperational;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: name + favorite toggle.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    station.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _favLoaded ? _toggleFavorite : null,
                  icon: Icon(
                    _isFavorite ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 28,
                  ),
                ),
              ],
            ),
            if (station.operatorName != null) ...[
              const SizedBox(height: 2),
              Text(
                station.operatorName!,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 10),
            // Status chip.
            if (operational != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: operational
                      ? Colors.green.withOpacity(0.12)
                      : Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      operational ? Icons.check_circle : Icons.error_outline,
                      size: 16,
                      color: operational ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      station.statusTitle ??
                          (operational ? 'Operational' : 'Not operational'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: operational ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            // Address.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 20),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    station.address,
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Connectors.
            _infoRow(Icons.ev_station, 'Connectors',
                '${station.numberOfConnectors}'),
            if (station.maxPowerKW != null)
              _infoRow(Icons.bolt, 'Max power',
                  '${station.maxPowerKW!.toStringAsFixed(0)} kW'),
            if (station.connectorTypes.isNotEmpty)
              _infoRow(Icons.power, 'Types',
                  station.connectorTypes.join(', ')),
            _infoRow(Icons.lock_open, 'Access', station.accessLabel),
            if (station.usageCost != null && station.usageCost!.isNotEmpty)
              _infoRow(Icons.currency_rupee, 'Cost', station.usageCost!),
            const SizedBox(height: 8),
            // Per-connector detail.
            if (station.connections.isNotEmpty) ...[
              const Divider(),
              const Text(
                'Available connectors',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              ...station.connections.map((c) {
                final power =
                    c.powerKW != null ? ' · ${c.powerKW!.toStringAsFixed(0)} kW' : '';
                final current = c.currentType != null ? ' · ${c.currentType}' : '';
                final qty = (c.quantity ?? 1) > 1 ? '${c.quantity}× ' : '';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '• $qty${c.type}$power$current',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }),
            ],
            const SizedBox(height: 12),
            _buildCommunitySection(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: widget.onDirections,
              icon: const Icon(Icons.directions),
              label: const Text('Get Directions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Community reliability: aggregate status + the user's own report buttons.
  Widget _buildCommunitySection() {
    if (_reportsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Loading community status…'),
          ],
        ),
      );
    }

    if (!_reportsAvailable) {
      return const SizedBox.shrink();
    }

    final summary = _summary ?? StationStatusSummary.empty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          'Is it working?',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        _buildStatusLine(summary),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _reportButton(
                label: 'Working',
                icon: Icons.check_circle,
                color: Colors.green,
                selected: _myReport == ReportStatus.working,
                onTap: () => _submitReport(ReportStatus.working),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _reportButton(
                label: 'Not working',
                icon: Icons.cancel,
                color: Colors.red,
                selected: _myReport == ReportStatus.notWorking,
                onTap: () => _submitReport(ReportStatus.notWorking),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusLine(StationStatusSummary summary) {
    if (!summary.hasReports) {
      return const Text(
        'No reports yet — be the first to help other drivers.',
        style: TextStyle(fontSize: 14, color: Colors.black54),
      );
    }

    final pct = (summary.workingRatio! * 100).round();
    final good = pct >= 50;
    final lastText = summary.lastReported != null
        ? ' · last ${_timeAgo(summary.lastReported!)}'
        : '';

    return Row(
      children: [
        Icon(
          good ? Icons.thumb_up : Icons.warning_amber_rounded,
          size: 18,
          color: good ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$pct% report working · ${summary.totalCount} '
            '${summary.totalCount == 1 ? 'report' : 'reports'}$lastText',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _reportButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: _submitting ? null : onTap,
      icon: Icon(icon, size: 18, color: selected ? Colors.white : color),
      label: Text(
        label,
        style: TextStyle(color: selected ? Colors.white : color),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? color : Colors.transparent,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
