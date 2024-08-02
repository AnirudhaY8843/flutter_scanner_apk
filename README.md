# poc_scans

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


#the ocr scanning

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:poc_scans/screens/search_list_screen.dart';

class OcrScanPage extends StatefulWidget {
  @override
  _OcrScanPageState createState() => _OcrScanPageState();
}

class _OcrScanPageState extends State<OcrScanPage> {
  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isScanning = false;
  String scanResult = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.max,
    );

    _initializeControllerFuture = _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _scanText() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {
      final picture = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(picture.path);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      await searchFormulas(recognizedText.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scan text: $e')),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> searchFormulas(String searchTerm) async {
    const String baseUrl = 'https://gw.thebhive.net';
    final response = await http.get(Uri.parse(
        '$baseUrl/formulas/search-by-ocr?ocrResult=${Uri.encodeComponent(searchTerm)}'));

    print(
        'Request URL: $baseUrl/formulas/search-by-ocr?ocrResult=${Uri.encodeComponent(searchTerm)}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        if (jsonResponse.isEmpty) {
          _showAlert(context, 'No results found');
          _showTextSearch();
        } else {
          scanResult = jsonEncode(jsonResponse);
          _showSearchList(jsonResponse);
        }
      });
    } else {
      _showAlert(context, 'Label read error');
    }
  }

  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showTextSearch() {
    // Implement your logic to show text search
  }

  void _showSearchList(List<dynamic> searchResults) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchListScreen(searchResults: searchResults),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_cameraController!),
                if (_isScanning)
                  Center(child: CircularProgressIndicator())
                else
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                        ),
                        onPressed: _scanText,
                        child: Text(
                          'Scan Text',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}



///second approach google lens failed
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:poc_scans/screens/search_list_screen.dart';

class OcrScanPage extends StatefulWidget {
  @override
  _OcrScanPageState createState() => _OcrScanPageState();
}

class _OcrScanPageState extends State<OcrScanPage> {
  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isScanning = false;
  Rect? _selectionRect;
  Offset? _startPoint;
  String scanResult = ''; // Declare scanResult here

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.max,
    );

    _initializeControllerFuture = _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _scanSelectedArea() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {
      final picture = await _cameraController!.takePicture();
      final image = await decodeImageFromList(await picture.readAsBytes());
      final rect = _selectionRect!;
      final croppedImage = await cropImage(
        image: image,
        rect: rect,
      );

      final inputImage = InputImage.fromBytes(
        bytes: croppedImage,
        metadata: InputImageMetadata(
          size: Size(rect.width, rect.height),
          bytesPerRow: rect.width.toInt(), // Adjust if needed
          rotation: InputImageRotation.rotation0deg, // Adjust if needed
          format: InputImageFormat.yuv420, // Adjust based on your image format
        ),
      );

      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      setState(() {
        scanResult = recognizedText.text; // Store recognized text
      });

      await searchFormulas(recognizedText.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scan selected area: $e')),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<Uint8List> cropImage({
    required ui.Image image,
    required Rect rect,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, rect);
    final paint = Paint();
    canvas.drawImageRect(
      image,
      rect,
      Rect.fromLTWH(0, 0, rect.width, rect.height),
      paint,
    );
    final picture = recorder.endRecording();
    final img = await picture.toImage(rect.width.toInt(), rect.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _startPoint = details.localPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      final currentPoint = details.localPosition;
      if (_startPoint != null) {
        _selectionRect = Rect.fromPoints(_startPoint!, currentPoint);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_selectionRect != null) {
      _scanSelectedArea();
    }
  }

  Future<void> searchFormulas(String searchTerm) async {
    const String baseUrl = 'https://gw.thebhive.net';
    final response = await http.get(Uri.parse(
        '$baseUrl/formulas/search-by-ocr?ocrResult=${Uri.encodeComponent(searchTerm)}'));

    print(
        'Request URL: $baseUrl/formulas/search-by-ocr?ocrResult=${Uri.encodeComponent(searchTerm)}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        if (jsonResponse.isEmpty) {
          _showAlert(context, 'No results found');
          _showTextSearch();
        } else {
          scanResult =
              jsonEncode(jsonResponse); // Use scanResult here if needed
          _showSearchList(jsonResponse);
        }
      });
    } else {
      _showAlert(context, 'Label read error');
    }
  }

  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showTextSearch() {
    // Implement your logic to show text search
  }

  void _showSearchList(List<dynamic> searchResults) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchListScreen(searchResults: searchResults),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_cameraController!),
                if (_selectionRect != null)
                  CustomPaint(
                    painter: SelectionPainter(_selectionRect!),
                  ),
                GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                ),
                if (_isScanning)
                  Center(child: CircularProgressIndicator())
                else
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                        ),
                        onPressed: _scanSelectedArea,
                        child: Text(
                          'Scan Selected Area',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class SelectionPainter extends CustomPainter {
  final Rect selectionRect;

  SelectionPainter(this.selectionRect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(selectionRect, paint);

    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(selectionRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
