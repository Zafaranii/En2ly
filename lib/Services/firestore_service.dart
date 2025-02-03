import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:latlong2/latlong.dart';

import '../Models/trip_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload an image to Firebase Storage and return its URL
  Future<String?> uploadImage(File imageFile, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Save trip data to Firestore and return the document ID
  Future<String?> saveTripData(Trip tripModel) async {
    try {
      final docRef = await _firestore.collection('trips').add(tripModel.toMap());
      print('Trip data saved successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error saving trip data: $e');
      return null;
    }
  }

  // Process items, upload photos, save trip, and return the trip ID
  Future<String?> processAndSaveTrip({
    required String pickupTitle,
    required String dropoffTitle,
    required double price,
    required String paymentMethod,
    required LatLng pickupLocation,
    required LatLng dropoffLocation,
    required int noOfItems,
    required String customerCreatedById,
    required List<Map<String, dynamic>> itemsWithImages,
  }) async {
    try {
      if (itemsWithImages.length != noOfItems) {
        throw Exception(
          'Mismatch between noOfItems ($noOfItems) and itemsWithImages length (${itemsWithImages.length}).',
        );
      }

      List<Map<String, dynamic>> items = [];

      // Process each item and upload its image
      for (int i = 0; i < noOfItems; i++) {
        final Map<String, dynamic> item = itemsWithImages[i];
        final File? image = item['image'] as File?;
        String? imageUrl;

        if (image != null) {
          imageUrl = await uploadImage(
            image,
            'item_images/item_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
        }

        items.add({
          'name': item['name'] ?? '',
          'height': item['height'] ?? 0,
          'width': item['width'] ?? 0,
          'depth': item['depth'] ?? 0,
        });
      }

      // Create a Trip model
      Trip tripModel = Trip(
        pickupTitle: pickupTitle,
        dropoffTitle: dropoffTitle,
        price: price,
        paymentMethod: paymentMethod,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        noOfItems: noOfItems,
        customerCreatedById: customerCreatedById,
        tripStatus: 'pending',
        items: items,
        date : DateTime.now()
      );

      // Save to Firestore
      return await saveTripData(tripModel);
    } catch (e) {
      print('Error processing and saving trip: $e');
      return null;
    }
  }
}