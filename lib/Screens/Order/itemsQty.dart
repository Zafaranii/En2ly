import 'package:flutter/material.dart';

import '../../Models/trip_model.dart';
import 'dimensions_midpoint.dart';


// QuantityPage: Receives an object through its constructor
class QuantityPage extends StatelessWidget {
  final Trip trip; // Object received from previous page
  final TextEditingController _quantityController = TextEditingController();

  QuantityPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Dynamic Title Based on Received Object
            Text(
              "How Many Items you are gonna move?",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3E50), // Navy text color
              ),
            ),
            const SizedBox(height: 30),
            // Quantity Input
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Qty',
                hintStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF2D3E50), // Border color
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Next Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Action for the "Next" button
                  trip.noOfItems = int.parse(_quantityController.text);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) =>  DimensionOptionsPage(trip: trip,)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D3E50), // Navy color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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