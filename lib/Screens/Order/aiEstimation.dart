import 'dart:io';
import 'dart:typed_data';
import 'package:en2ly/Screens/Order/payment.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'dart:developer' as devtools;

import '../../Models/trip_model.dart';


class ItemDimensionsPageAi extends StatefulWidget {
  final Trip trip;

  const ItemDimensionsPageAi({super.key, required this.trip});

  @override
  State<ItemDimensionsPageAi> createState() => _ItemDimensionsPageAiState();
}

class _ItemDimensionsPageAiState extends State<ItemDimensionsPageAi> {
  File? _imageFile;
  late tfl.Interpreter _interpreter;
  bool _modelReady = false;

  final List<Map<String, dynamic>> _itemData = [];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      final options = tfl.InterpreterOptions();
      _interpreter = await tfl.Interpreter.fromAsset(
        'assets/furniture_model.tflite',
        options: options,
      );
      devtools.log("Model loaded successfully.");
      setState(() {
        _modelReady = true;
      });
    } catch (e) {
      devtools.log("Error loading model: $e");
    }
  }

  Future<void> _pickImageAndAddItem(int index) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() {
      _imageFile = File(file.path);
    });

    if (_modelReady) {
      final itemResult = await _runInference(File(file.path));
      if (itemResult != null) {
        setState(() {
          if (index < _itemData.length) {
            _itemData[index] = itemResult;
          } else {
            _itemData.add(itemResult);
          }
        });
      }
    }
  }

  Uint8List _preprocessImage(File file) {
    final rawImg = img.decodeImage(file.readAsBytesSync());
    if (rawImg == null) {
      throw Exception("Cannot decode image");
    }
    final resized = img.copyResize(rawImg, width: 224, height: 224);
    final Float32List buffer = Float32List(224 * 224 * 3);
    int idx = 0;
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        final r = (img.getRed(pixel) / 255.0 - 0.485) / 0.229;
        final g = (img.getGreen(pixel) / 255.0 - 0.456) / 0.224;
        final b = (img.getBlue(pixel) / 255.0 - 0.406) / 0.225;
        buffer[idx++] = r;
        buffer[idx++] = g;
        buffer[idx++] = b;
      }
    }
    return buffer.buffer.asUint8List();
  }

  Future<Map<String, dynamic>?> _runInference(File imageFile) async {
    try {
      final inputData = _preprocessImage(imageFile);
      _interpreter.allocateTensors();

      final inputs = <Object>[inputData];
      final dimsBuffer = List<List<double>>.generate(1, (_) => List<double>.filled(3, 0.0));
      final classBuffer = List<List<double>>.generate(1, (_) => List<double>.filled(5, 0.0));

      final outputs = <int, Object>{
        0: dimsBuffer,
        1: classBuffer,
      };

      _interpreter.runForMultipleInputs(inputs, outputs);

      double w = dimsBuffer[0][0];
      double d = dimsBuffer[0][1];
      double h = dimsBuffer[0][2];

      final List<double> cList = classBuffer[0];
      int maxIdx = 0;
      double maxVal = cList[0];
      for (int i = 1; i < cList.length; i++) {
        if (cList[i] > maxVal) {
          maxVal = cList[i];
          maxIdx = i;
        }
      }

      final predictedCls = ["Almirah", "Chair", "Refrigerator", "Table", "Television"][maxIdx];
      return {
        'name': predictedCls,
        'height': h.round(),
        'width': w.round(),
        'depth': d.round(),
        'image': imageFile,
      };
    } catch (e) {
      devtools.log("Error in inference: $e");
      return null;
    }
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Dimensions"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.trip.noOfItems,
              itemBuilder: (context, index) {
                final item = index < _itemData.length ? _itemData[index] : null;

                return ListTile(
                  title: Text(item?['name'] ?? "Item ${index + 1}"),
                  subtitle: item != null
                      ? Text(
                      "H: ${item['height']?.toStringAsFixed(2)},"
                          "W: ${item['width']?.toStringAsFixed(2)}, "
                          "D: ${item['depth']?.toStringAsFixed(2)}")
                      : const Text("No data yet"),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    onPressed: () => _pickImageAndAddItem(index),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.trip.items.clear();
              widget.trip.items.addAll(_itemData);
              print("Trip Items Updated: ${widget.trip.items}");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  PaymentApp(trip: widget.trip,)));
              },
            child: const Text("Save and Return"),
          ),
        ],
      ),
    );
  }
}