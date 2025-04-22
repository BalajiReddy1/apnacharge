import 'dart:convert';
import 'package:ev_app/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class PlacesAutocomplete extends StatefulWidget {
  final String apiKey;
  final Function(String placeId, String description, LatLng latLng)
      onPlaceSelected;

  const PlacesAutocomplete({
    Key? key,
    required this.apiKey,
    required this.onPlaceSelected,
  }) : super(key: key);

  @override
  _PlacesAutocompleteState createState() => _PlacesAutocompleteState();
}

class _PlacesAutocompleteState extends State<PlacesAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _suggestions = [];

  Future<void> _onChanged(String input) async {
    if (input.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=${widget.apiKey}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        setState(() {
          _suggestions = data['predictions'];
        });
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  Future<void> _onSuggestionTap(dynamic suggestion) async {
    final placeId = suggestion['place_id'];
    final detailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=${widget.apiKey}';
    final detailsResponse = await http.get(Uri.parse(detailsUrl));

    if (detailsResponse.statusCode == 200) {
      final detailsData = json.decode(detailsResponse.body);
      if (detailsData['status'] == 'OK') {
        final lat = detailsData['result']['geometry']['location']['lat'];
        final lng = detailsData['result']['geometry']['location']['lng'];
        widget.onPlaceSelected(
            placeId, suggestion['description'], LatLng(lat, lng));
        Navigator.pop(context); // Close the autocomplete dialog/screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Search',
          style: GoogleFonts.arimo(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: AppColors.darkgreen, width: 1.4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: TextField(
                    style: TextStyle(
                        color: AppColors.darkestbg,
                        fontSize: 18,
                        fontWeight: FontWeight.w400),
                    controller: _controller,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'Enter a location to search',
                        hintStyle: GoogleFonts.arimo(
                            color: AppColors.darkestbg,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.darkestbg,
                          weight: 30,
                        )),
                    onChanged: _onChanged,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    title: Text(
                      suggestion['description'],
                      style: TextStyle(
                          color: AppColors.medgreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    onTap: () => _onSuggestionTap(suggestion),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
