// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:location/location.dart';
// import 'package:nominatim_flutter/model/request/search_request.dart';
// import 'package:nominatim_flutter/nominatim_flutter.dart';
// import 'package:http/http.dart' as http;
//
// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});
//
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   final MapController mapController = MapController();
//   LocationData? currentLocation;
//   LatLng? pickupLocation;
//   LatLng? dropoffLocation;
//   List<LatLng> routePoints = [];
//   List<Marker> markers = [];
//   final TextEditingController searchController = TextEditingController();
//   List<Map<String, dynamic>> searchSuggestions = []; // List to hold search suggestions
//   final Location location = Location();
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeLocation();
//   }
//
//   Future<void> _initializeLocation() async {
//     try {
//       // Check if location services are enabled
//       bool serviceEnabled = await location.serviceEnabled();
//       if (!serviceEnabled) {
//         serviceEnabled = await location.requestService();
//         if (!serviceEnabled) {
//           return;
//         }
//       }
//
//       // Request necessary permissions
//       PermissionStatus permission = await location.hasPermission();
//       if (permission == PermissionStatus.denied) {
//         permission = await location.requestPermission();
//         if (permission != PermissionStatus.granted) {
//           return;
//         }
//       }
//
//       // Get the user's current location
//       var userLocation = await location.getLocation();
//       setState(() {
//         currentLocation = userLocation;
//         pickupLocation = LatLng(userLocation.latitude!, userLocation.longitude!);
//         markers.add(
//           Marker(
//             width: 80.0,
//             height: 80.0,
//             point: pickupLocation!,
//             child: const Icon(Icons.my_location, color: Colors.blue, size: 40.0),
//           ),
//         );
//       });
//
//       // Listen for location changes
//       location.onLocationChanged.listen((LocationData newLocation) {
//         setState(() {
//           currentLocation = newLocation;
//         });
//       }).onError((error) {
//         print("Location stream error: $error");
//       });
//     } catch (e) {
//       print("Error initializing location: $e");
//     }
//   }
//
//   Future<void> _searchLocation(String query) async {
//     try {
//       final searchRequest = SearchRequest(
//         query: query,
//         limit: 5,
//         addressDetails: true,
//         extraTags: true,
//         nameDetails: true,
//         countryCodes: ['EG'], // Limit to Egypt
//       );
//
//       final searchResults = await NominatimFlutter.instance.search(
//         searchRequest: searchRequest,
//         language: 'en-US,en;q=0.5',
//       );
//
//       setState(() {
//         searchSuggestions = searchResults
//             .map((result) => {
//           'display_name': result.displayName,
//           'lat': double.parse(result.lat ?? '0'),
//           'lon': double.parse(result.lon ?? '0'),
//         })
//             .toList();
//       });
//     } catch (e) {
//       print("Error fetching search results: $e");
//     }
//   }
//
//   void _selectDropoffLocation(Map<String, dynamic> suggestion) {
//     final LatLng destination = LatLng(suggestion['lat'], suggestion['lon']);
//     setState(() {
//       dropoffLocation = destination;
//       markers.add(
//         Marker(
//           width: 80.0,
//           height: 80.0,
//           point: destination,
//           child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
//         ),
//       );
//       searchSuggestions = []; // Clear suggestions after selection
//     });
//
//     _drawRoute();
//     mapController.move(destination, 15.0);
//   }
//
//   void _setDropoffLocationByTap(LatLng point) {
//     setState(() {
//       dropoffLocation = point;
//       markers.add(
//         Marker(
//           width: 80.0,
//           height: 80.0,
//           point: point,
//           child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
//         ),
//       );
//     });
//     _drawRoute();
//   }
//
//   Future<void> _drawRoute() async {
//     if (pickupLocation == null || dropoffLocation == null) return;
//
//     final start = pickupLocation!;
//     final end = dropoffLocation!;
//     final response = await http.get(
//       Uri.parse(
//           'https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf6248c0cf752d62b24795a583a130fff52fce&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}'),
//     );
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final List<dynamic> coords = data['features'][0]['geometry']['coordinates'];
//       setState(() {
//         routePoints = coords.map((coord) => LatLng(coord[1], coord[0])).toList();
//       });
//     } else {
//       print('Failed to fetch route');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pickup and Dropoff'),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(120.0),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Pickup: ${pickupLocation != null ? '${pickupLocation!.latitude}, ${pickupLocation!.longitude}' : 'Not set'}',
//                     ),
//                     Text(
//                       'Dropoff: ${dropoffLocation != null ? '${dropoffLocation!.latitude}, ${dropoffLocation!.longitude}' : 'Not set'}',
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: searchController,
//                   onChanged: (value) {
//                     if (value.isNotEmpty) {
//                       _searchLocation(value);
//                     } else {
//                       setState(() {
//                         searchSuggestions = [];
//                       });
//                     }
//                   },
//                   decoration: InputDecoration(
//                     hintText: 'Search for dropoff location',
//                     border: OutlineInputBorder(),
//                     suffixIcon: IconButton(
//                       icon: const Icon(Icons.search),
//                       onPressed: () => _searchLocation(searchController.text),
//                     ),
//                   ),
//                 ),
//                 if (searchSuggestions.isNotEmpty)
//                   Container(
//                     color: Colors.white,
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: searchSuggestions.length,
//                       itemBuilder: (context, index) {
//                         final suggestion = searchSuggestions[index];
//                         return ListTile(
//                           title: Text(suggestion['display_name']),
//                           onTap: () => _selectDropoffLocation(suggestion),
//                         );
//                       },
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: currentLocation == null
//           ? const Center(child: CircularProgressIndicator())
//           : FlutterMap(
//         mapController: mapController,
//         options: MapOptions(
//           initialCenter: LatLng(
//               currentLocation!.latitude!, currentLocation!.longitude!),
//           initialZoom: 15.0,
//           onTap: (tapPosition, point) => _setDropoffLocationByTap(point),
//         ),
//         children: [
//           TileLayer(
//             urlTemplate:
//             "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//             subdomains: const ['a', 'b', 'c'],
//           ),
//           MarkerLayer(
//             markers: markers,
//           ),
//           PolylineLayer(
//             polylines: [
//               Polyline(
//                 points: routePoints,
//                 strokeWidth: 4.0,
//                 color: Colors.blue,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }