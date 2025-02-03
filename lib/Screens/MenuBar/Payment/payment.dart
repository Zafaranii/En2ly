import 'package:flutter/material.dart';

import '../../../Models/card_model.dart';
import 'add_payemnt.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<PaymentCard> savedCards = []; // List to store saved cards

  @override
  Widget build(BuildContext context) {
    const Color navy = Color(0xFF2D3E50);
    const Color lightGrey = Color(0xFFF3F4F6);
    const Color blue = Color(0xFF535AFF);
    const Color darkGrey = Color(0xFF4A4A4A);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: navy,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Payment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
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
              TextButton(
                onPressed: () async {
                  // Navigate to the Add Payment Method page
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPaymentMethodPage(),
                    ),
                  );
                  // Update the saved cards when returning
                  if (result is PaymentCard) {
                    setState(() {
                      savedCards.add(result);
                    });
                  }
                },
                child: const Text(
                  'Add Payment Method',
                  style: TextStyle(
                    color: blue,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Saved Cards:',
                style: TextStyle(
                  color: darkGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              savedCards.isEmpty
                  ? const Text(
                'No cards added yet',
                style: TextStyle(color: darkGrey),
              )
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: savedCards.length,
                itemBuilder: (context, index) {
                  final card = savedCards[index];
                  return ListTile(
                    leading: const Icon(Icons.credit_card, color: blue),
                    title: Text(card.cardHolderName,
                        style: const TextStyle(color: darkGrey)),
                    subtitle: Text(
                      'Card Number: ${card.cardNumber}',
                      style: const TextStyle(color: darkGrey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: blue),
                      onPressed: () {
                        setState(() {
                          savedCards.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}