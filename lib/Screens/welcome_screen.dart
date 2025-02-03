import 'package:en2ly/Screens/phone_auth_screen.dart';
import 'package:en2ly/Screens/tst1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'name_register.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  Locale _currentLocale = const Locale('ar'); // Default language is Arabic

  // Toggle between Arabic and English
  void _toggleLanguage() {
    setState(() {
      _currentLocale = _currentLocale.languageCode == 'ar'
          ? const Locale('en')
          : const Locale('ar');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _currentLocale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                // Language Toggle Button
                Padding(
                  padding: const EdgeInsets.only(right: 26.0, top: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _toggleLanguage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D3E50),
                      ),
                      child: Text(
                        _currentLocale.languageCode == 'ar' ? 'English' : 'العربية',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
                // Logo Image
                Image.asset(
                  'images/logo.png',
                  width: 251,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                // Main Heading
                Text(
                  _currentLocale.languageCode == 'ar' ? 'انقلي' : 'En2ly',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 40),
                // Subtitle with Icon
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 19, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: const Color(0xFF2D3E50),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 6),
                      Image.asset(
                        'images/safety_icon.png',
                        width: 42,
                        height: 42,
                      ),
                      Text(
                        _currentLocale.languageCode == 'ar'
                            ? '    انقل ب أمان'
                            : '    Travel Safely',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 75),
                // "Let's Go!" Button
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhoneAuthScreen(selectedLocale: _currentLocale),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D3E50),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 70,
                        vertical: 22,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      minimumSize: const Size(304, 0),
                    ),
                    child: Text(
                      _currentLocale.languageCode == 'ar'
                          ? "! هيا بنا"
                          : "Let's Go!",
                      style: const TextStyle(
                        color: Color(0xFFF3F4F6),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}