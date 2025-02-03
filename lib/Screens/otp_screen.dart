import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:en2ly/Models/customer_model.dart';
import 'package:en2ly/Screens/name_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'map_screen.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber; // Phone number passed from the previous screen
  final Locale selectedLocale; // Current locale for localization

  const OtpScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
    required this.selectedLocale,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());
  late final CustomerModel customerModel;
  void _navigateToMapScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(customer: customerModel),
      ),
    );
  }

  void _navigateToNameRegistrationScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NameInputScreen(
          phoneNumber: widget.phoneNumber,
          selectedLocale: widget.selectedLocale,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            widget.selectedLocale.languageCode == 'ar'
                ? Icons.arrow_forward
                : Icons.arrow_back,
            color: const Color(0xFF4A4A4A),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Text(
              widget.selectedLocale.languageCode == 'ar'
                  ? 'أدخل الرمز المكون من 6 أرقام المرسل إلى هاتفك'
                  : 'Enter the 6-digit code sent to your phone',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                    (index) => SizedBox(
                  width: 50,
                  child: TextField(
                    controller: otpControllers[index],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      counterText: '',
                      border: const OutlineInputBorder(),
                      hintText: widget.selectedLocale.languageCode == 'ar'
                          ? '-'
                          : '-',
                    ),
                    onChanged: (text) {
                      if (text.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      } else if (text.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D3E50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  widget.selectedLocale.languageCode == 'ar'
                      ? 'تحقق من الرمز'
                      : 'Verify OTP',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    final otp = otpControllers.map((controller) => controller.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.selectedLocale.languageCode == 'ar'
              ? 'يرجى إدخال الرمز بالكامل'
              : 'Please enter the complete OTP'),
        ),
      );
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);

      // Check if user already exists in Firestore
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final userDoc =
        await _firestore.collection('users').doc(uid).get();
        print(userDoc.data());
        customerModel = CustomerModel.fromMap(userDoc.data()!);
        customerModel.customerId = uid;

        if (userDoc.exists) {
          // User exists, navigate to MapScreen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.selectedLocale.languageCode == 'ar'
                  ? 'مرحبًا بعودتك!'
                  : 'Welcome back!'),
            ),
          );
          _navigateToMapScreen(context);
        } else {
          // User is new, navigate to NameRegistrationScreen
          _navigateToNameRegistrationScreen(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.selectedLocale.languageCode == 'ar'
              ? 'خطأ أثناء التحقق من الرمز: $e'
              : 'Error verifying OTP: $e'),
        ),
      );
    }
  }
}