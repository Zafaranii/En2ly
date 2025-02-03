import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:en2ly/Models/customer_model.dart';
import 'package:en2ly/Screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Screens/map_screen.dart';
import 'Screens/tst0.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print('Firebase initialized successfully');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,// Start with the SplashScreen
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});


  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3)); // Show splash screen for 3 seconds
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Landing1Page()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/logo.png', // Add your image here
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              const Text(
                'انقلي' ,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Landing1Page extends StatelessWidget {
  Landing1Page({super.key});

  // Check if the user is logged in
  Future<bool> _checkUserLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  // Fetch customer data from Firestore
  Future<CustomerModel?> _getCustomerData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        return CustomerModel.New(
          user.uid,
          snapshot.data()?['firstName'] ?? '',
          snapshot.data()?['lastName'] ?? '',
          snapshot.data()?['phoneNumber'] ?? '',
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<bool>(
        future: _checkUserLoggedIn(),
        builder: (context, loggedInSnapshot) {
          if (loggedInSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (loggedInSnapshot.hasError || !(loggedInSnapshot.data ?? false)) {
            // If not logged in, go to LandingPage
            return const LandingPage();
          }

          // User is logged in, fetch their data
          return FutureBuilder<CustomerModel?>(
            future: _getCustomerData(),
            builder: (context, customerSnapshot) {
              if (customerSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (customerSnapshot.hasError || customerSnapshot.data == null) {
                return const LandingPage(); // Error or no data, go to LandingPage
              }
              final customer = customerSnapshot.data!;
              // Pass the CustomerModel to MapScreen
              return MapScreen(customer: customer );
            },
          );
        },
      ),
    );
  }
}
