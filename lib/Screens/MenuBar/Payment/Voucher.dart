import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VoucherPage extends StatefulWidget {
  @override
  _VoucherPageState createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  final TextEditingController _voucherController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Define the colors
    const Color grey = Color(0xFF979797);
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
          'Add Voucher Code',
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
          children: [
            const Icon(Icons.card_giftcard, size: 40, color: navy),
            const SizedBox(height: 30),
            const Text(
              'Add Voucher Code',
              style: TextStyle(
                color: navy,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _voucherController,
              decoration: const InputDecoration(
                labelText: 'Voucher Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Return the entered voucher code
                Navigator.pop(context, _voucherController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
              ),
              child: const Text(
                'Done',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}