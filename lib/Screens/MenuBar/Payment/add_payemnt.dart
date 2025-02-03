import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../Models/card_model.dart';

class AddPaymentMethodPage extends StatefulWidget {
  @override
  _AddPaymentMethodPageState createState() => _AddPaymentMethodPageState();
}

class _AddPaymentMethodPageState extends State<AddPaymentMethodPage> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Define the colors
    const Color blue = Color(0xFF535AFF);
    const Color navy = Color(0xFF2D3E50);
    const Color lightGrey = Color(0xFFF3F4F6);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Payment Method',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: lightGrey,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Card Details',
              style: TextStyle(
                color: navy,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: cardNumberController,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: cardHolderNameController,
              decoration: const InputDecoration(
                labelText: 'Card Holder Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (cardNumberController.text.isNotEmpty &&
                    cardHolderNameController.text.isNotEmpty) {
                  final card = PaymentCard(
                    cardNumber: cardNumberController.text,
                    cardHolderName: cardHolderNameController.text,
                  );
                  Navigator.pop(context, card); // Return card details
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please enter all card details'),
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
              ),
              child: const Text(
                'Save Card',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}