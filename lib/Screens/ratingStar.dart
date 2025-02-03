import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:en2ly/Models/customer_model.dart';
import 'package:en2ly/Screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

class RatingScreen extends StatefulWidget {
  final String tripId; // Trip ID passed from the previous screen

  RatingScreen({required this.tripId});

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double rating = 5.0; // Default rating value
  CustomerModel? customer; // Holds the fetched customer model
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchCustomerDetails(); // Fetch customer details on initialization
  }

  Future<void> _fetchCustomerDetails() async {
    try {
      // Fetch the trip document using the tripId
      final tripDoc = await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .get();

      if (tripDoc.exists) {
        final tripData = tripDoc.data()!;
        final customerCreatedById = tripData['customerCreatedById'];
        print(customerCreatedById);
        // Fetch the customer document using the customerCreatedById
        final customerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(customerCreatedById)
            .get();

        if (customerDoc.exists) {
          setState(() {
            customer = CustomerModel.fromMap(customerDoc.data()!); // Map customer details
            customer?.customerId = customerCreatedById;
            isLoading = false; // Loading complete
          });
        }
      }
    } catch (e) {
      print('Error fetching customer details: $e');
    }
  }

  Future<void> updateDriverRatingForTrip(String tripId, double rating) async {
    final tripDoc = FirebaseFirestore.instance.collection('trips').doc(tripId);

    await tripDoc.update({
      'driverRating': rating, // Save the submitted rating
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Us'),
        backgroundColor: Colors.green, // Match the star color for consistency
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader while fetching
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFE8F5E9), // Light green background
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ensures vertical centering
            crossAxisAlignment: CrossAxisAlignment.center, // Horizontal centering
            children: [
              const Text(
                'How was your experience?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              SmoothStarRating(
                allowHalfRating: false,
                onRatingChanged: (value) {
                  setState(() {
                    rating = value; // Update the rating value dynamically
                  });
                },
                starCount: 5,
                rating: rating,
                size: 50.0,
                color: Colors.green,
                borderColor: Colors.green,
                spacing: 15.0, // Added more spacing for better visibility
                filledIconData: Icons.star,
                halfFilledIconData: Icons.star_half,
                defaultIconData: Icons.star_border,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (customer == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error: Customer details not loaded.')),
                    );
                    return; // Prevent further execution if customer is null
                  }

                  final String tripId = widget.tripId; // Get tripId from RatingScreen
                  await updateDriverRatingForTrip(tripId, rating); // Save rating to the trip document

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for your feedback!')),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapScreen(customer: customer!)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}