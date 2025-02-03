import 'package:flutter/material.dart';
import 'otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthScreen extends StatefulWidget {
  final Locale selectedLocale; // Current selected locale

  const PhoneAuthScreen({Key? key, required this.selectedLocale}) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController phoneController = TextEditingController();
  String? verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            widget.selectedLocale.languageCode == 'ar' ? Icons.arrow_forward : Icons.arrow_back,
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
                  ? 'أدخل رقم هاتفك المحمول'
                  : 'Enter your mobile number',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 25,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/flag.png'), // Add flag image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '+20',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: widget.selectedLocale.languageCode == 'ar'
                          ? '١xxxxxxxxx'
                          : '1xxxxxxxxx',
                      hintStyle: const TextStyle(color: Color(0xFF979797)),
                      border: const OutlineInputBorder(),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (text) {
                      if (text != null && (text.length < 8 || text.length > 10)) {
                        return widget.selectedLocale.languageCode == 'ar'
                            ? "الرقم ليس بالتنسيق الصحيح"
                            : "Number is not in the correct format";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.selectedLocale.languageCode == 'ar'
                  ? 'بالمتابعة قد تتلقى رسالة SMS للتحقق. قد يتم تطبيق رسوم البيانات.'
                  : 'By continuing you may receive an SMS for verification. Message and data rates may apply.',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D3E50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  widget.selectedLocale.languageCode == 'ar' ? 'التالي' : 'Next',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendOtp() async {
    final phone = '+20${phoneController.text.trim()}';

    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.selectedLocale.languageCode == 'ar'
              ? 'يرجى إدخال رقم هاتف صالح'
              : 'Please enter a valid phone number'),
        ),
      );
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        // Empty implementation to skip auto-verification
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.selectedLocale.languageCode == 'ar'
                ? 'فشل التحقق: ${e.message}'
                : 'Verification failed: ${e.message}'),
          ),
        );
      },
      codeSent: (String id, int? resendToken) {
        setState(() {
          verificationId = id;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              verificationId: id,
              phoneNumber: phoneController.text,
              selectedLocale: widget.selectedLocale, // Pass locale to OTP screen
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String id) {
        setState(() {
          verificationId = id;
        });
      },
    );
  }
}