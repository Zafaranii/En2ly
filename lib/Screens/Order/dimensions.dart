import 'package:en2ly/Screens/Order/payment.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


import '../../Models/trip_model.dart';

class ItemDimensionsPage extends StatefulWidget {
  final Trip trip;

  const ItemDimensionsPage({super.key, required this.trip});

  @override
  State<ItemDimensionsPage> createState() => _ItemDimensionsPageState();
}

class _ItemDimensionsPageState extends State<ItemDimensionsPage> {
  // List to store dimensions and image data for each item
  final List<Map<String, dynamic>> _itemData = [];
  double price = 0;

  @override
  void initState() {
    super.initState();

    // Initialize controllers for each item's fields
    for (int i = 0; i < widget.trip.noOfItems ; i++) {
      _itemData.add({
        'name': TextEditingController(),
        'height': TextEditingController(),
        'width': TextEditingController(),
        'length': TextEditingController(),
        'image': null, // Placeholder for image
      });
    }
  }

  // Function to pick an image (camera or gallery)
  Future<void> _pickImage(int index) async {
    final ImagePicker picker = ImagePicker();

    // Show options dialog
    final XFile? image = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Picture'),
                onTap: () async {
                  Navigator.of(context).pop(await picker.pickImage(source: ImageSource.camera));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop(await picker.pickImage(source: ImageSource.gallery));
                },
              ),
            ],
          ),
        );
      },
    );

    if (image != null) {
      setState(() {
        _itemData[index]['image'] = File(image.path);
      });
    }
  }



  void _submitDimensions() async {

    // Loop through all items to gather data
    for (int i = 0; i < widget.trip.noOfItems; i++) {
      widget.trip.items.add({
        'name': _itemData[i]['name'].text,
        'height': _itemData[i]['height'].text,
        'width': _itemData[i]['width'].text,
        'length': _itemData[i]['length'].text,
        'image': _itemData[i]['image'], // Image file or null
      });
      price += 70.5 * (double.parse(_itemData[i]['height'].text) * double.parse(_itemData[i]['width'].text) * double.parse(_itemData[i]['length'].text));
    }

    widget.trip.price += price * 70.5;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Items and dimensions saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          title: const Text("Enter Item Details"),
          backgroundColor: const Color(0xFF2D3E50),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Please enter the details for ${widget.trip.noOfItems} items:",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                // Generate fields dynamically
                ...List.generate(widget.trip.noOfItems, (index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Item ${index + 1}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Name Field
                          TextField(
                            controller: _itemData[index]['name'],
                            decoration: const InputDecoration(
                              labelText: "Name",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Height Field
                          TextField(
                            controller: _itemData[index]['height'],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Height (cm)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Width Field
                          TextField(
                            controller: _itemData[index]['width'],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Width (cm)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Length Field
                          TextField(
                            controller: _itemData[index]['length'],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Length (cm)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Image Upload
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _pickImage(index),
                                icon: const Icon(Icons.camera_alt),
                                label: const Text("Upload or Capture"),
                              ),
                              const SizedBox(width: 10),
                              _itemData[index]['image'] != null
                                  ? Image.file(
                                _itemData[index]['image'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                                  : const Text("No Image Selected"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:() {
                      _submitDimensions();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  PaymentApp(trip: widget.trip,)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D3E50),
                    ),
                    child: const Text(
                      "Submit Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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