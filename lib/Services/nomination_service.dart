import 'package:nominatim_flutter/model/request/search_request.dart';
import 'package:nominatim_flutter/nominatim_flutter.dart';

class NominatimService {
  Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    try {
      final searchRequest = SearchRequest(
        query: query,
        limit: 5,
        addressDetails: true,
        extraTags: true,
        nameDetails: true,
        countryCodes: ['EG'], // Limit to Egypt
      );

      final searchResults = await NominatimFlutter.instance.search(
        searchRequest: searchRequest,
        language: 'en-US,en;q=0.5',
      );

      return searchResults
          .map((result) => {
        'display_name': result.displayName,
        'lat': double.parse(result.lat ?? '0'),
        'lon': double.parse(result.lon ?? '0'),
      })
          .toList();
    } catch (e) {
      print("Error fetching search results: $e");
      return [];
    }
  }
}