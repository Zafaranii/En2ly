import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/nomination_service.dart';

class SearchPage extends StatefulWidget {
  final LatLng? initialLocation;

  const SearchPage({super.key, this.initialLocation});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchSuggestions = [];
  final NominatimService _nominatimService = NominatimService();

  Future<void> _searchLocation(String query) async {
    final suggestions = await _nominatimService.searchLocation(query);
    setState(() {
      _searchSuggestions = suggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Location"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchLocation,
              decoration: const InputDecoration(
                hintText: "Search location",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _searchSuggestions[index];
                return ListTile(
                  title: Text(suggestion['display_name']),
                  onTap: () {
                    Navigator.pop(context, {
                      'location': LatLng(suggestion['lat'], suggestion['lon']),
                      'title': suggestion['display_name'],
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}