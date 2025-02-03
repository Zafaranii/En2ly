import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class YourTripsPage extends StatefulWidget {
  final String customerId; // Receive the customerId as a parameter

  const YourTripsPage({super.key, required this.customerId});

  @override
  State<YourTripsPage> createState() => _YourTripsPageState();
}

class _YourTripsPageState extends State<YourTripsPage> {
  late final Stream<QuerySnapshot> _tripsStream;
  final Map<String, Map<String, dynamic>> _cachedDriverDetails = {}; // Cache driver details

  @override
  void initState() {
    super.initState();
    _tripsStream = FirebaseFirestore.instance
        .collection('trips')
        .where('customerCreatedById', isEqualTo: widget.customerId)
        .snapshots();
  }

  Future<Map<String, dynamic>?> _fetchDriverDetails(String driverId) async {
    if (_cachedDriverDetails.containsKey(driverId)) {
      return _cachedDriverDetails[driverId];
    }

    if (driverId.isEmpty) {
      return null; // Return null if driverId is empty
    }

    try {
      final driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .get();

      if (driverDoc.exists) {
        final driverData = driverDoc.data();
        if (driverData != null) {
          setState(() {
            _cachedDriverDetails[driverId] = driverData;
          });
        }
        return driverData;
      }
    } catch (e) {
      print('Error fetching driver details: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const Color navy = Color(0xFF2D3E50);
    const Color white = Colors.white;

    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: [
          // Top Navy Bar with Back Arrow
          Container(
            width: double.infinity,
            height: 100,
            color: navy,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Past Trips',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Placeholder for symmetry
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Display trips from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _tripsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching trips.'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No trips found.'));
                }

                final trips = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index].data() as Map<String, dynamic>;
                    final String driverId = trip['driverAssignedId'] ?? '';
                    final fromAddress = trip['pickupTitle'] ?? 'Unknown Start Location';
                    final toAddress = trip['dropoffTitle'] ?? 'Unknown Destination';
                    final tripStatus = trip['tripStatus'] ?? 'Unknown Status';

                    if (driverId.isEmpty) {
                      // Show placeholder for trips with invalid driverId
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: TripComponent(
                          driver: 'Unknown Driver',
                          vehicle: 'Unknown Vehicle',
                          cost: trip['price']?.toString() ?? 'Unknown Cost',
                          time: trip['date'] != null
                              ? (trip['date'] as Timestamp).toDate()
                              : DateTime.now(),
                          fromAddress: fromAddress,
                          toAddress: toAddress,
                          tripStatus: tripStatus,
                        ),
                      );
                    }

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _fetchDriverDetails(driverId),
                      builder: (context, driverSnapshot) {
                        if (driverSnapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (driverSnapshot.hasError || driverSnapshot.data == null) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: Text('Error fetching driver details.')),
                          );
                        }

                        final driver = driverSnapshot.data!;
                        final driverName = '${driver['firstName'] ?? ''} ${driver['lastName'] ?? ''}'.trim();
                        final vehicleInfo =
                            '${driver['carModel'] ?? 'Unknown Model'}: ${driver['carType'] ?? 'Unknown Type'}';

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: TripComponent(
                            driver: driverName.isNotEmpty ? driverName : 'Unknown Driver',
                            vehicle: vehicleInfo,
                            cost: trip['price']?.toString() ?? 'Unknown Cost',
                            time: trip['date'] != null
                                ? (trip['date'] as Timestamp).toDate()
                                : DateTime.now(),
                            fromAddress: fromAddress,
                            toAddress: toAddress,
                            tripStatus: tripStatus,
                          ),
                        );
                      },
                    );
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

// Reusable Component for Trip
class TripComponent extends StatelessWidget {
  final String driver;
  final String vehicle;
  final String cost;
  final DateTime time;
  final String fromAddress; // New field
  final String toAddress;   // New field
  final String tripStatus;  // New field

  const TripComponent({
    super.key,
    required this.driver,
    required this.vehicle,
    required this.cost,
    required this.time,
    required this.fromAddress,
    required this.toAddress,
    required this.tripStatus,
  });

  @override
  Widget build(BuildContext context) {
    const Color navy = Color(0xFF2D3E50);
    const Color white = Colors.white;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset(
                  'images/driver.png', // Replace with your local image path
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: white,
                      ),
                    ),
                    Text(
                      vehicle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    cost,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),
                  Text(
                    time.toString().split(' ')[0],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'From: $fromAddress',
            style: const TextStyle(
              fontSize: 12,
              color: white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'To: $toAddress',
            style: const TextStyle(
              fontSize: 12,
              color: white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Status: $tripStatus',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }
}