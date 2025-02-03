import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  // Method to launch the phone dialer
  Future<void> _callUs() async {
    final Uri phoneNumber = Uri(scheme: 'tel', path: '+201234567890'); // Replace with your Egyptian phone number
    if (await canLaunchUrl(phoneNumber)) {
      await launchUrl(phoneNumber);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  // Method to show "Coming Soon" popup
  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Coming Soon'),
          content: const Text('Chat with us feature is under development.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Call Us Button
            ElevatedButton.icon(
              onPressed: _callUs,
              icon: const Icon(Icons.call),
              label: const Text('Call Us'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            // Chat With Us Button
            ElevatedButton.icon(
              onPressed: () => _showComingSoon(context),
              icon: const Icon(Icons.chat),
              label: const Text('Chat with Us'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}