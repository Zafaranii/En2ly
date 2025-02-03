import 'package:flutter/material.dart';

import '../Screens/MenuBar/help.dart';
import '../Screens/MenuBar/messages.dart';
import '../Screens/MenuBar/Payment/payment.dart';
import '../Screens/MenuBar/settings.dart';
import '../Screens/MenuBar/trips.dart';

class MenuBarApp extends StatelessWidget {
  final String customerId;

  const MenuBarApp({required this.customerId,super.key});

  @override
  Widget build(BuildContext context) {
    // Menu items configuration
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.trip_origin,
        'title': 'Your Trips',
        'page':  YourTripsPage(customerId: customerId),
      },
      {
        'icon': Icons.message,
        'title': 'Messages',
        'page': const MessagesPage(),
      },
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'page': const SettingsPage(),
      },
      {
        'icon': Icons.payment,
        'title': 'Payment',
        'page': const PaymentPage(),
      },
      {
        'icon': Icons.help,
        'title': 'Help',
        'page': const HelpPage(),
      },
    ];

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          _buildDrawerHeader(),

          // Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return ListTile(
                  leading: Icon(item['icon']),
                  title: Text(item['title']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => item['page']),
                    );
                  },
                );
              },
            ),
          ),

          // Footer Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Legal', style: TextStyle(fontSize: 14)),
                SizedBox(height: 4),
                Text('v4.3712003', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Drawer Header
  Widget _buildDrawerHeader() {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(45, 62, 80, 1),
      ),
      currentAccountPicture: const CircleAvatar(
        backgroundImage: AssetImage(
            'images/customer.png'), // Replace with your image asset
      ),
      accountName: const Text(
        'Marwan Hazem',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      accountEmail: const Row(
        children: [
          Icon(Icons.star, size: 16, color: Colors.white),
          SizedBox(width: 4),
          Text(
            '4.7',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}