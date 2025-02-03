import 'dart:ffi';

import 'package:latlong2/latlong.dart';

class Trip {
  late String pickupTitle;
  late String dropoffTitle;
  late double price;
  late String paymentMethod;
  late LatLng pickupLocation;
  late LatLng dropoffLocation;
  late int noOfItems;
  String? driverAssignedId;
  late String customerCreatedById;
  late String tripStatus;
  late List<Map<String, dynamic>> items;
  late DateTime date;

  Trip.New() {
    items = []; // Initialize the items list to avoid null issues
  }
  Trip({
      required this.pickupTitle,
      required this.dropoffTitle,
      required this.price,
      required this.paymentMethod,
  required this.pickupLocation,
  required this.dropoffLocation,
  required this.noOfItems,
   this.driverAssignedId,
  required  this.customerCreatedById,
  required  this.tripStatus,
  required this.items,
  required this.date});

  Map<String, dynamic> toMap() {
    return {
      'pickupTitle': pickupTitle,
      'dropoffTitle': dropoffTitle,
      'price': price,
      'paymentMethod': paymentMethod,
      'pickupLocation': {
        'latitude': pickupLocation.latitude,
        'longitude': pickupLocation.longitude,
      },
      'dropoffLocation': {
        'latitude': dropoffLocation.latitude,
        'longitude': dropoffLocation.longitude,
      },
      'noOfItems': noOfItems,
      'driverAssignedId': driverAssignedId,
      'customerCreatedById': customerCreatedById,
      'tripStatus': tripStatus,
      'items': items, // Includes dimensions and image URL
      'date' : date
    };
  }
}