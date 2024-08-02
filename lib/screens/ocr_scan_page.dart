// // checked code use it if other not works

// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:poc_scans/screens/search_list_screen.dart';

// class OcrScanPage extends StatefulWidget {
//   @override
//   _OcrScanPageState createState() => _OcrScanPageState();
// }

// class _OcrScanPageState extends State<OcrScanPage> {
//   CameraController? _cameraController;
//   late Future<void> _initializeControllerFuture;
//   bool _isScanning = false;
//   String scanResult = '';

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   void _initializeCamera() async {
//     final cameras = await availableCameras();
//     final firstCamera = cameras.first;

//     _cameraController = CameraController(
//       firstCamera,
//       ResolutionPreset.max,
//     );

//     _initializeControllerFuture = _cameraController!.initialize();
//     setState(() {});
//   }

//   Future<void> _scanText() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return;
//     }

//     setState(() {
//       _isScanning = true;
//     });

//     try {
//       final picture = await _cameraController!.takePicture();
//       final inputImage = InputImage.fromFilePath(picture.path);
//       final textRecognizer = TextRecognizer();
//       final recognizedText = await textRecognizer.processImage(inputImage);

//       await searchFormulas(recognizedText.text);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to scan text: $e')),
//       );
//     } finally {
//       setState(() {
//         _isScanning = false;
//       });
//     }
//   }

//   Future<void> searchFormulas(String searchTerm) async {
//     const String baseUrl = 'https://gw.thebhive.net';
//     final response = await http.get(Uri.parse(
//         '$baseUrl/formulas/search-by-ocr?ocrResult=${Uri.encodeComponent(searchTerm)}'));

//     print(
//         'Request URL: $baseUrl/formulas/search-by-ocr?ocrResult=${Uri.encodeComponent(searchTerm)}');
//     print('Response: ${response.body}');

//     if (response.statusCode == 200) {
//       List<dynamic> jsonResponse = json.decode(response.body);
//       setState(() {
//         if (jsonResponse.isEmpty) {
//           _showAlert(context, 'No results found');
//           _showTextSearch();
//         } else {
//           scanResult = jsonEncode(jsonResponse);
//           _showSearchList(jsonResponse);
//         }
//       });
//     } else {
//       _showAlert(context, 'Label read error');
//     }
//   }

//   void _showAlert(BuildContext context, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Alert'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showTextSearch() {
//     // Implement your logic to show text search
//   }

//   void _showSearchList(List<dynamic> searchResults) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SearchListScreen(searchResults: searchResults),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return Stack(
//               fit: StackFit.expand,
//               children: [
//                 CameraPreview(_cameraController!),
//                 if (_isScanning)
//                   Center(child: CircularProgressIndicator())
//                 else
//                   Positioned(
//                     bottom: 50,
//                     left: 0,
//                     right: 0,
//                     child: Center(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           padding: EdgeInsets.symmetric(
//                             vertical: 15,
//                             horizontal: 20,
//                           ),
//                         ),
//                         onPressed: _scanText,
//                         child: Text(
//                           'Scan Text',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:io';
// import 'package:image/image.dart' as img;
// import 'package:path_provider/path_provider.dart';
// import 'package:poc_scans/screens/search_list_screen.dart';

// class OcrScanPage extends StatefulWidget {
//   @override
//   _OcrScanPageState createState() => _OcrScanPageState();
// }

// class _OcrScanPageState extends State<OcrScanPage> {
//   CameraController? _cameraController;
//   late Future<void> _initializeControllerFuture;
//   bool _isScanning = false;
//   String scanResult = '';
//   final GlobalKey _cameraPreviewKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   void _initializeCamera() async {
//     final cameras = await availableCameras();
//     final firstCamera = cameras.first;

//     _cameraController = CameraController(
//       firstCamera,
//       ResolutionPreset.max,
//     );

//     _initializeControllerFuture = _cameraController!.initialize();
//     setState(() {});
//   }

//   Future<void> _scanText() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return;
//     }

//     setState(() {
//       _isScanning = true;
//     });

//     try {
//       final picture = await _cameraController!.takePicture();

//       // Crop the image to the center rectangular region
//       final croppedImagePath = await _cropImageToCenterRegion(picture.path);

//       final inputImage = InputImage.fromFilePath(croppedImagePath);
//       final textRecognizer = TextRecognizer();
//       final recognizedText = await textRecognizer.processImage(inputImage);

//       print("Reccognized Text : $recognizedText");

//       await searchFormulas(recognizedText.text);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to scan text: $e')),
//       );
//     } finally {
//       setState(() {
//         _isScanning = false;
//       });
//     }
//   }

//   Future<String> _cropImageToCenterRegion(String imagePath) async {
//     final bytes = await File(imagePath).readAsBytes();
//     final image = img.decodeImage(bytes)!;

//     final roiWidth = (image.width * 0.5).toInt();
//     final roiHeight = (image.height * 0.3).toInt();
//     final centerX = image.width ~/ 2;
//     final centerY = image.height ~/ 2;

//     final croppedImage = img.copyCrop(
//       image,
//       x: centerX - roiWidth ~/ 2,
//       y: centerY - roiHeight ~/ 2,
//       width: roiWidth,
//       height: roiHeight,
//     );

//     final tempDir = await getTemporaryDirectory();
//     final croppedImagePath = '${tempDir.path}/cropped_image.jpg';
//     final croppedFile = File(croppedImagePath);
//     croppedFile.writeAsBytesSync(img.encodeJpg(croppedImage));

//     return croppedImagePath;
//   }

//   Future<void> searchFormulas(String searchTerm) async {
//     const String baseUrl = 'https://gw.thebhive.net';
//     final response = await http.get(Uri.parse(
//         '$baseUrl/formulas/search-by-ocr?ocrResult=${Uri.encodeComponent(searchTerm)}'));

//     print("Sercing text Text : $searchTerm");

//     print(
//         'Request URL: $baseUrl/formulas/search-by-ocr?ocrResult=${Uri.encodeComponent(searchTerm)}');
//     print('Response: ${response.body}');

//     if (response.statusCode == 200) {
//       List<dynamic> jsonResponse = json.decode(response.body);
//       setState(() {
//         if (jsonResponse.isEmpty) {
//           _showAlert(context, 'No results found');
//           _showTextSearch();
//         } else {
//           scanResult = jsonEncode(jsonResponse);
//           _showSearchList(jsonResponse);
//         }
//       });
//     } else {
//       _showAlert(context, 'Label read error');
//     }
//   }

//   void _showAlert(BuildContext context, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Alert'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showTextSearch() {
//     // Implement your logic to show text search
//   }

//   void _showSearchList(List<dynamic> searchResults) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SearchListScreen(searchResults: searchResults),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return Stack(
//               fit: StackFit.expand,
//               children: [
//                 CameraPreview(_cameraController!),
//                 Center(
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 0.5,
//                     height: MediaQuery.of(context).size.height * 0.3,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: Colors.red,
//                         width: 2.0,
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (_isScanning)
//                   Center(child: CircularProgressIndicator())
//                 else
//                   Positioned(
//                     bottom: 50,
//                     left: 0,
//                     right: 0,
//                     child: Center(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           padding: EdgeInsets.symmetric(
//                             vertical: 15,
//                             horizontal: 20,
//                           ),
//                         ),
//                         onPressed: _scanText,
//                         child: Text(
//                           'Scan Text',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
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
  final GlobalKey _cameraPreviewKey = GlobalKey();

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
// Start timing the scan
      final startTime = DateTime.now(); 

      // Crop the image to the center rectangular region
      final croppedImagePath = await _cropImageToCenterRegion(picture.path);

      final inputImage = InputImage.fromFilePath(croppedImagePath);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
 // End timing the scan
      final endTime = DateTime.now();
      final scanDuration = endTime.difference(startTime);
      print("Time taken for scan: ${scanDuration.inMilliseconds} ms");

      print("Recognized Text: $recognizedText");

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

  Future<String> _cropImageToCenterRegion(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(bytes)!;

    final roiWidth = (image.width * 0.8).toInt();
    // Smaller height for single line
    final roiHeight =
        (image.height * 0.08).toInt(); 
    final centerX = image.width ~/ 2;
    final centerY = image.height ~/ 2;

    final croppedImage = img.copyCrop(
      image,
      x: centerX - roiWidth ~/ 2,
      y: centerY - roiHeight ~/ 2,
      width: roiWidth,
      height: roiHeight,
    );

    final tempDir = await getTemporaryDirectory();
    final croppedImagePath = '${tempDir.path}/cropped_image.jpg';
    final croppedFile = File(croppedImagePath);
    croppedFile.writeAsBytesSync(img.encodeJpg(croppedImage));

    return croppedImagePath;
  }

  Future<void> searchFormulas(String searchTerm) async {
    const String baseUrl = 'https://gw.thebhive.net';

    final startTime = DateTime.now(); 

    final response = await http.get(Uri.parse(
        '$baseUrl/formulas/search-by-ocr?ocrResult=${Uri.encodeComponent(searchTerm)}'));
// End timing the HTTP request
    final endTime = DateTime.now(); 
    final requestDuration = endTime.difference(startTime);
    print("Time taken for HTTP response: ${requestDuration.inMilliseconds} ms");

    print("Searching text: $searchTerm");

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
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    // Smaller height for single line
                    height: MediaQuery.of(context).size.height *
                        0.08, 
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                  ),
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
