import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:en2ly/Models/customer_model.dart';
import 'package:en2ly/Screens/Order/itemsQty.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../Models/trip_model.dart';
import '../Services/location_service.dart';
import '../Services/nomination_service.dart';
import '../Widgets/menu_bar.dart';
import 'search_page.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  final CustomerModel customer;
  const MapScreen({required this.customer, super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Trip trip =  Trip.New();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final NominatimService _nominatimService = NominatimService();
  LatLng? _currentLocation;
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  double _calculateDistance(LatLng start, LatLng end) {
    final Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, start, end);
  }

  Future<void> _initializeLocation() async {
    final location = await _locationService.getCurrentLocation();
    if (location != null) {
      final currentLatLng = LatLng(location.latitude!, location.longitude!);
      final placeTitle = await _getPlaceTitle(currentLatLng);
      setState(() {
        _currentLocation = currentLatLng;
        _pickupLocation = currentLatLng;
        _pickupController.text = placeTitle ?? 'Unknown Location';
        _mapController.move(_currentLocation!, 15.0);
      });
    }
  }

  Future<String?> _getPlaceTitle(LatLng location) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?lat=${location
        .latitude}&lon=${location.longitude}&format=json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Unknown Location';
      }
    } catch (e) {
      print("Error fetching place title: $e");
    }
    return null;
  }

  Future<void> _drawRoute() async {
    if (_pickupLocation == null || _dropoffLocation == null) return;

    final start = _pickupLocation!;
    final end = _dropoffLocation!;

    final response = await http.get(
      Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf6248c0cf752d62b24795a583a130fff52fce&start=${start
              .longitude},${start.latitude}&end=${end.longitude},${end
              .latitude}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<
          dynamic> coords = data['features'][0]['geometry']['coordinates'];
      setState(() {
        _routePoints =
            coords.map((coord) => LatLng(coord[1], coord[0])).toList();
      });
      _focusOnBothLocations();
    } else {
      print('Failed to fetch route');
    }
  }


    void _focusOnLocation(LatLng location) {
      _mapController.move(location, 15.0);
    }

    void _focusOnBothLocations() {
      if (_pickupLocation != null && _dropoffLocation != null) {
        final mapSize = MediaQuery
            .of(context)
            .size;
        _focusBounds(
            _mapController, _pickupLocation!, _dropoffLocation!, mapSize);
      }
    }

    void _focusBounds(MapController mapController, LatLng pickup,
        LatLng dropoff, Size mapSize) {
      const int WORLD_DIM = 256;
      const int ZOOM_MAX = 18;

      double latRad(double lat) {
        var sinn = sin(lat * pi / 180);
        var radX2 = log((1 + sinn) / (1 - sinn)) / 2;
        return max(min(radX2, pi), -pi) / 2;
      }

      int zoom(double mapPx, double worldPx, double fraction) {
        return (log(mapPx / worldPx / fraction) / ln2).floor();
      }

      final southWest = LatLng(
        min(pickup.latitude, dropoff.latitude),
        min(pickup.longitude, dropoff.longitude),
      );
      final northEast = LatLng(
        max(pickup.latitude, dropoff.latitude),
        max(pickup.longitude, dropoff.longitude),
      );

      final latFraction = (latRad(northEast.latitude) -
          latRad(southWest.latitude)) / pi;
      final lngDiff = northEast.longitude - southWest.longitude;
      final lngFraction = (lngDiff < 0 ? lngDiff + 360 : lngDiff) / 360;

      final latZoom = zoom(mapSize.height, WORLD_DIM.toDouble(), latFraction);
      final lngZoom = zoom(mapSize.width, WORLD_DIM.toDouble(), lngFraction);

      final zoomLevel = min(latZoom, lngZoom).clamp(0, ZOOM_MAX);

      final center = LatLng(
        (southWest.latitude + northEast.latitude) / 2,
        (southWest.longitude + northEast.longitude) / 2,
      );

      mapController.move(center, zoomLevel.toDouble());
    }

    @override
    Widget build(BuildContext context) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Map Screen'),
          ),
          drawer:  MenuBarApp(customerId : widget.customer.customerId! ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLocation ?? LatLng(30.0444, 31.2357),
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://basemaps.cartocdn.com/rastertiles/voyager_nolabels/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  if (_pickupLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _pickupLocation!,
                          width: 80.0,
                          height: 80.0,
                          child: const Icon(Icons.location_on,
                              color: Colors.blue, size: 40.0),
                        ),
                      ],
                    ),
                  if (_dropoffLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _dropoffLocation!,
                          width: 80.0,
                          height: 80.0,
                          child: const Icon(Icons.location_on,
                              color: Colors.red, size: 40.0),
                        ),
                      ],
                    ),
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                ],
              ),
              Positioned(
                top: 20,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    TextField(
                      controller: _pickupController,
                      readOnly: true,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SearchPage(initialLocation: _pickupLocation),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _pickupLocation = result['location'];
                            _pickupController.text = result['title'];
                          });
                          _focusOnLocation(_pickupLocation!);
                          _drawRoute();
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: "Pickup Location",
                        prefixIcon: Icon(Icons.my_location),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _dropoffController,
                      readOnly: true,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SearchPage(initialLocation: _dropoffLocation),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _dropoffLocation = result['location'];
                            _dropoffController.text = result['title'];
                          });
                          _focusOnLocation(_dropoffLocation!);
                          _drawRoute();
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: "Dropoff Location",
                        prefixIcon: Icon(Icons.location_on),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              if (_pickupLocation != null && _dropoffLocation != null)
                Positioned(
                  bottom: 80,
                  left: 16,
                  right: 16,
                  child: ElevatedButton(
                    onPressed: () {
                      print("test : ${widget.customer.customerId}");
                      trip.pickupTitle = _pickupController.text;
                      trip.dropoffTitle = _dropoffController.text;
                      trip.pickupLocation = _pickupLocation!;
                      trip.dropoffLocation = _dropoffLocation!;
                      trip.customerCreatedById = widget.customer.customerId!;
                      trip.price = 150 + 5 * (_calculateDistance(_pickupLocation!, _dropoffLocation!)) + 1.5 * (_calculateDistance(_pickupLocation!, _dropoffLocation!)) ;



                      // Navigate to the next screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  QuantityPage(trip: trip),
                        ),
                      );
                    },
                    child: const Text("Next"),
                  ),
                ),
              Positioned(
                bottom: 20,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    if (_currentLocation != null) {
                      _focusOnLocation(_currentLocation!);
                    }
                  },
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
