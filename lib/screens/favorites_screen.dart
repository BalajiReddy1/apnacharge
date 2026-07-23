import 'package:ev_app/const/colors.dart';
import 'package:ev_app/models/charging_station_details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/favorites_manager.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<ChargingStationDetails> favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final loaded = await FavoritesManager.getFavorites();
    if (!mounted) return;
    setState(() {
      favorites = loaded;
      _loading = false;
    });
  }

  Future<void> _removeFavorite(String placeId) async {
    await FavoritesManager.removeFavorite(placeId);
    await _loadFavorites();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Removed from favorites')));
  }

  Future<void> _openDirections(ChargingStationDetails station) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${station.latitude},${station.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.medgreen,
        title: Text(
          'Favorites',
          style: GoogleFonts.arimo(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_border, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No favorites yet',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Tap the star on a charging station to save it here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: favorites.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final station = favorites[index];
                    final subtitleParts = <String>[
                      if (station.operatorName != null) station.operatorName!,
                      if (station.maxPowerKW != null)
                        '${station.maxPowerKW!.toStringAsFixed(0)} kW',
                      '${station.numberOfConnectors} connectors',
                    ];
                    return ListTile(
                      leading: const Icon(Icons.ev_station,
                          color: AppColors.medgreen),
                      title: Text(
                        station.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(subtitleParts.join(' · ')),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.directions,
                                color: AppColors.medgreen),
                            onPressed: () => _openDirections(station),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeFavorite(station.placeId),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
