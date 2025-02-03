import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:en2ly/Models/customer_model.dart';
import 'package:en2ly/Screens/ratingStar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import '../Services/location_service.dart';
import 'package:http/http.dart' as http;

class RideDetails extends StatefulWidget {
  final String tripId;
  const RideDetails({required this.tripId, super.key});

  @override
  _RideDetailsState createState() => _RideDetailsState();
}

class _RideDetailsState extends State<RideDetails> {
  int a = 0;
  final MapController _mapController = MapController();
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  List<LatLng> _routePoints = [];
  String? _tripStatus;
  String? _driverAssignedId; // Track driver ID
  Map<String, dynamic>? _driverDetails; // Cache for driver details

  @override
  void initState() {
    super.initState();
    _initializeCurrentLocation();
  }

  Future<void> _initializeCurrentLocation() async {
    final location = await LocationService().getCurrentLocation();
    if (location != null) {
      setState(() {
        _pickupLocation = LatLng(location.latitude!, location.longitude!);
      });
    }
  }

  Future<void> _drawRoute() async {
    if (_pickupLocation == null || _dropoffLocation == null) return;

    final start = _pickupLocation!;
    final end = _dropoffLocation!;

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf6248c0cf752d62b24795a583a130fff52fce&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coords = data['features'][0]['geometry']['coordinates'];
        setState(() {
          _routePoints =
              coords.map((coord) => LatLng(coord[1], coord[0])).toList();
        });
      } else {
        print('Failed to fetch route: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  Future<void> _fetchDriverDetails(String driverId) async {
    try {
      final driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .get();

      if (driverDoc.exists) {
        setState(() {
          _driverDetails = driverDoc.data();
        });
      }
    } catch (e) {
      print('Error fetching driver details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Trip not found.'));
          }

          final tripData = snapshot.data!.data() as Map<String, dynamic>;

          // Extract trip data
          _pickupLocation = LatLng(
            tripData['pickupLocation']['latitude'],
            tripData['pickupLocation']['longitude'],
          );
          _dropoffLocation = LatLng(
            tripData['dropoffLocation']['latitude'],
            tripData['dropoffLocation']['longitude'],
          );
          _tripStatus = tripData['tripStatus'];

          if (a == 0) {
            _drawRoute();
            a = 1;
          }

          // Delay navigation to ensure it happens after the build phase
          if (_tripStatus == 'finished') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RatingScreen(tripId : widget.tripId)),
                );
              }
            });
          }

          final newDriverAssignedId = tripData['driverAssignedId'];

          // Fetch driver details if the driver ID changes
          if (newDriverAssignedId != null &&
              newDriverAssignedId != _driverAssignedId) {
            _driverAssignedId = newDriverAssignedId;
            _fetchDriverDetails(_driverAssignedId!);
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _pickupLocation ?? LatLng(0, 0),
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    "https://basemaps.cartocdn.com/rastertiles/voyager_nolabels/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      if (_pickupLocation != null)
                        Marker(
                          point: _pickupLocation!,
                          width: 80.0,
                          height: 80.0,
                          child: const Icon(Icons.location_on,
                              color: Colors.blue, size: 40.0),
                        ),
                      if (_dropoffLocation != null)
                        Marker(
                          point: _dropoffLocation!,
                          width: 80.0,
                          height: 80.0,
                          child: const Icon(Icons.location_on,
                              color: Colors.red, size: 40.0),
                        ),
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D3E50),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_driverDetails != null)
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.network(
                                _driverDetails!['avatar_url'] ??
                                    'https://cdn-icons-png.flaticon.com/512/147/147144.png',
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_driverDetails!['firstName'] ?? 'N/A'}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  'Car Model: ${_driverDetails!['carModel'] ?? 'N/A'}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.white70),
                                ),
                                Text(
                                  'Reg Number: ${_driverDetails!['regNumber'] ?? 'N/A'}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        const Center(
                          child: Text(
                            'Waiting for driver assignment...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        'Trip Status: ${_tripStatus ?? 'Unknown'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}