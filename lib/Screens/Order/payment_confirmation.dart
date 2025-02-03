// Second Page: Payment Confirmation
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaymentConfirmationPage extends StatefulWidget {
  final String selectedOption;

  const PaymentConfirmationPage({super.key, required this.selectedOption});

  @override
  State<PaymentConfirmationPage> createState() =>
      _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  @override
  Widget build(BuildContext context) {
    const Color navy = Color(0xFF2D3E50);
    const Color lightGrey = Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Payment Confirmation',
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
              'Your payment has been made',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromRGBO(45, 62, 80, 1),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Image.network(
                'https://cdn-icons-png.flaticon.com/512/190/190411.png',
                height: 100,
                width: 100,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Thank you for using our service\nPayment method: ${widget.selectedOption}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
                textAlign: TextAlign.center,
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
                onPressed: () {
                  // Do nothing on Done button press
                },
                child: Text(
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