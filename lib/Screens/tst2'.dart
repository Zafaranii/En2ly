// import 'package:flutter/material.dart';
// import 'phone_auth_screen.dart';
//
// class AccountSelectionScreen extends StatelessWidget {
//   final Locale selectedLocale; // Locale passed from previous screen
//
//   const AccountSelectionScreen({Key? key, required this.selectedLocale})
//       : super(key: key);
//
//   void _navigateToNextScreen(BuildContext context, String accountType) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PhoneAuthScreen(accountType: accountType),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isArabic = selectedLocale.languageCode == 'ar'; // Check for Arabic locale
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF3F4F6),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 37),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 131),
//               Text(
//                 isArabic ? 'أختر نوع الحساب' : 'Choose an account',
//                 style: const TextStyle(
//                   fontSize: 30,
//                   fontWeight: FontWeight.w500,
//                   fontFamily: 'Roboto',
//                 ),
//               ),
//               const SizedBox(height: 111),
//               InkWell(
//                 onTap: () => _navigateToNextScreen(context, 'driver'),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: isArabic
//                       ? [
//                     const Text(
//                       'سائق',
//                       style: TextStyle(
//                         fontSize: 40,
//                         fontFamily: 'Red Hat Display',
//                         color: Color(0xFF4A4A4A),
//                       ),
//                     ),
//                     Image.asset(
//                       'images/driver.png',
//                       width: 128,
//                       height: 128,
//                     ),
//                   ]
//                       : [
//                     Image.asset(
//                       'images/driver.png',
//                       width: 128,
//                       height: 128,
//                     ),
//                     const Text(
//                       'DRIVER',
//                       style: TextStyle(
//                         fontSize: 30,
//                         fontFamily: 'Red Hat Display',
//                         color: Color(0xFF4A4A4A),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 103),
//               InkWell(
//                 onTap: () => _navigateToNextScreen(context, 'customer'),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: isArabic
//                       ? [
//                     const Text(
//                       'عميل',
//                       style: TextStyle(
//                         fontSize: 40,
//                         fontFamily: 'Red Hat Display',
//                         color: Color(0xFF4A4A4A),
//                       ),
//                     ),
//                     Image.asset(
//                       'images/customer.png',
//                       width: 128,
//                       height: 128,
//                     ),
//                   ]
//                       : [
//                     Image.asset(
//                       'images/customer.png',
//                       width: 128,
//                       height: 128,
//                     ),
//                     const Text(
//                       'CUSTOMER',
//                       style: TextStyle(
//                         fontSize: 30,
//                         fontFamily: 'Red Hat Display',
//                         color: Color(0xFF4A4A4A),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }