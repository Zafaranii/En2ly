import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Models/customer_model.dart';
import 'map_screen.dart';

class NameInputScreen extends StatefulWidget {
  final Locale selectedLocale;
  final String phoneNumber;

  const NameInputScreen({
    super.key,
    required this.selectedLocale,
    required this.phoneNumber,
  });

  @override
  _NameInputScreenState createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CustomerModel customer = CustomerModel();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Write data to Firestore
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await _firestore.collection('users').doc(uid).set({
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'phoneNumber': widget.phoneNumber,
            'createdAt': FieldValue.serverTimestamp(),
          });
          customer.customerId = uid;
          customer.firstName = _firstNameController.text.trim();
          customer.lastName = _lastNameController.text.trim();
          customer.phoneNum = widget.phoneNumber;
          // Navigate to MapScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  MapScreen(customer: customer,)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.selectedLocale.languageCode == 'ar'
                    ? 'حدث خطأ. يرجى المحاولة مرة أخرى'
                    : 'An error occurred. Please try again.',
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.selectedLocale.languageCode == 'ar'
                  ? 'فشل الحفظ في قاعدة البيانات: $e'
                  : 'Failed to save to database: $e',
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.selectedLocale.languageCode == 'ar'
                ? 'يرجى ملء جميع الحقول'
                : 'Please fill in all fields',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D3E50),
        elevation: 0,
        title: Text(
          widget.selectedLocale.languageCode == 'ar'
              ? 'أدخل اسمك'
              : "What's your name?",
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
            ),
          ),
          Positioned(
            left: 32,
            top: 100,
            child: Text(
              widget.selectedLocale.languageCode == 'ar'
                  ? "ما اسمك؟"
                  : "What's your name?",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ),
          Positioned(
            left: 32,
            top: 160,
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        hintText: widget.selectedLocale.languageCode == 'ar'
                            ? "الاسم الأول"
                            : "First",
                        hintStyle: const TextStyle(color: Color(0xFF979797)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Color(0xFF979797)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Color(0xFF2D3E50)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return widget.selectedLocale.languageCode == 'ar'
                              ? 'يرجى إدخال الاسم الأول'
                              : 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        hintText: widget.selectedLocale.languageCode == 'ar'
                            ? "الاسم الأخير"
                            : "Last",
                        hintStyle: const TextStyle(color: Color(0xFF979797)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Color(0xFF979797)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Color(0xFF2D3E50)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return widget.selectedLocale.languageCode == 'ar'
                              ? 'يرجى إدخال الاسم الأخير'
                              : 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 32,
            bottom: 50,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 64,
              child: ElevatedButton(
                onPressed: _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D3E50),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  widget.selectedLocale.languageCode == 'ar'
                      ? "التالي"
                      : "Next",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}