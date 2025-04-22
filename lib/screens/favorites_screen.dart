import 'package:ev_app/models/charging_station_details.dart';
import 'package:flutter/material.dart';
import '../services/favorites_manager.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<ChargingStationDetails> favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    favorites = await FavoritesManager.getFavorites();
    setState(() {});
  }

  Future<void> _removeFavorite(String placeId) async {
    await FavoritesManager.removeFavorite(placeId);
    _loadFavorites(); // Reload after removal
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Removed from favorites")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text("No favorites added yet."),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                ChargingStationDetails station = favorites[index];
                return ListTile(
                  title: Text(station.name),
                  subtitle: Text(station.address),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeFavorite(station.placeId),
                  ),
                );
              },
            ),
    );
  }
}
