import 'package:en2ly/Models/trip_model.dart';
import 'package:en2ly/Screens/Order/payment_confirmation.dart';
import 'package:flutter/material.dart';

import '../../Services/firestore_service.dart';
import '../ride_details.dart';


class PaymentApp extends StatelessWidget {
  final Trip trip;
  const PaymentApp({super.key, required  this.trip});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PaymentMethodPage(trip: trip),
    );
  }
}

// First Page: Select Payment Method
class PaymentMethodPage extends StatefulWidget {
  final Trip trip;
  const PaymentMethodPage({super.key, required this.trip});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String selectedOption = ''; // Tracks the selected payment method
  String? tripId;
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _submitDimensions() async {
    try {
      // Call FirestoreService to save the trip
      tripId = await _firestoreService.processAndSaveTrip(
        pickupTitle: widget.trip.pickupTitle,
        dropoffTitle: widget.trip.dropoffTitle,
        price: (selectedOption == 'Credit') ? widget.trip.price - 100 : widget.trip.price,
        paymentMethod: selectedOption,
        pickupLocation: widget.trip.pickupLocation,
        dropoffLocation: widget.trip.dropoffLocation,
        noOfItems: widget.trip.noOfItems,
        customerCreatedById: widget.trip.customerCreatedById,
        itemsWithImages: widget.trip.items,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip saved successfully!')),
      );
    } catch (e) {
      // Log and display error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving trip: $e')),
      );
      tripId = null; // Reset tripId to null in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color grey = Color(0xFF979797);
    const Color navy = Color(0xFF2D3E50);
    const Color lightGrey = Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        title: const Text(
          'Select Payment Method',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Select your preferred payment method',
              style: TextStyle(fontSize: 16, color: Color.fromRGBO(45, 62, 80, 1)),
            ),
            const SizedBox(height: 30),
            // Credit or Debit Card Option
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedOption = 'Credit';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selectedOption == 'Credit'
                      ? Colors.blue.shade50
                      : Colors.white,
                  border: Border.all(
                    color: selectedOption == 'Credit'
                        ? Colors.blue
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Image.network(
                      'https://cdn-icons-png.flaticon.com/512/633/633611.png',
                      height: 40,
                      width: 40,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Credit or Debit Card',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: navy),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: Row(
                children: [
                  const SizedBox(width: 220),
                  Text(
                    '${widget.trip.price}',
                    style: TextStyle(
                        fontSize: 18,
                        decoration: TextDecoration.lineThrough,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                  const SizedBox(width: 25),
                  Text(
                    '${widget.trip.price - 100}',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Cash Option
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedOption = 'Cash';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selectedOption == 'Cash'
                      ? Colors.blue.shade50
                      : Colors.white,
                  border: Border.all(
                    color: selectedOption == 'Cash'
                        ? Colors.blue
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Image.network(
                      'https://cdn-icons-png.flaticon.com/512/123/123394.png',
                      height: 40,
                      width: 40,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Cash',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: navy),
                    ),
                    const SizedBox(width: 150),
                    Text(
                      '${widget.trip.price} EGP',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: navy),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Done Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(45, 62, 80, 1),
                ),
                onPressed: selectedOption.isNotEmpty
                    ? () async {
                  await _submitDimensions(); // Wait for _submitDimensions to complete
                  if (tripId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => selectedOption == 'Credit'
                            ? PaymentConfirmationPage(
                          selectedOption: selectedOption,
                        )
                            : RideDetails(tripId: tripId!),
                      ),
                    );
                  } else {
                    // Handle the case where tripId is still null
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to save trip. Please try again.')),
                    );
                  }
                }
                    : null, // Disable button if no option is selected
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}