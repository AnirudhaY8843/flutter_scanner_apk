import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:poc_scans/screens/search_list_screen.dart';

class QRScanPage extends StatefulWidget {
  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;
  String scanResult = '';

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

  void _showTextSearch() {}

  void _showSearchList(List<dynamic> searchResults) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchListScreen(searchResults: searchResults),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            //   controller: cameraController,
            //   onDetect: (barcodeCapture) {
            //     final Barcode? barcode = barcodeCapture.barcodes.first;
            //     if (barcode != null && barcode.rawValue != null && isScanning) {
            //       setState(() {
            //         isScanning = false;
            //       });
            //       searchFormulas(barcode.rawValue!).then((_) {
            //         setState(() {
            //           isScanning = true;
            //         });
            //       });
            //     } else {
            //       print('No barcode detected or isScanning is false');
            //     }
            //   },
            // ),
            onDetect: (barcodeCapture) {
              final List<Barcode> barcodes = barcodeCapture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null && isScanning) {
                  setState(() {
                    isScanning = false;
                  });
                  print('Barcode detected: $code');
                  searchFormulas(code).then((_) {
                    setState(() {
                      isScanning = true;
                    });
                  });
                  break;
                }
              }
              if (barcodes.isEmpty) {
                print('No barcode detected');
              }
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red,
                  width: 2.0,
                ),
              ),
              height: 200,
              width: 200,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () {
                cameraController.toggleTorch();
              },
              icon: Icon(Icons.flash_on),
              label: Text('Toggle Flash'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

class DisplayScreen extends StatelessWidget {
  final String data;

  DisplayScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Data'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_2,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                'Scanned QR Code Data:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                data,
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Scan Another QR Code'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';


// class QRScanPage extends StatefulWidget {
//   @override
//   _QRScanPageState createState() => _QRScanPageState();
// }

// class _QRScanPageState extends State<QRScanPage> {
//   MobileScannerController cameraController = MobileScannerController();
//   bool isScanning = true;
//   String scanResult = '';

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
//           _showSearchList();
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
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('QR Code Scanner'),
//       ),
//       body: Stack(
//         children: [
//           MobileScanner(
//             controller: cameraController,
//             onDetect: (barcodeCapture) {
//               final Barcode? barcode = barcodeCapture.barcodes.first;
//               if (barcode != null && barcode.rawValue != null && isScanning) {
//                 setState(() {
//                   isScanning = false;
//                 });
//                 searchFormulas(barcode.rawValue!).then((_) {
//                   setState(() {
//                     isScanning = true;
//                   });
//                 });
//               } else {
//                 print('No barcode detected or isScanning is false');
//               }
//             },
//           ),
//           Align(
//             alignment: Alignment.center,
//             child: Container(
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Colors.red,
//                   width: 2.0,
//                 ),
//               ),
//               height: 200,
//               width: 200,
//             ),
//           ),
//           Positioned(
//             bottom: 20,
//             left: 20,
//             right: 20,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 cameraController.toggleTorch();
//               },
//               icon: Icon(Icons.flash_on),
//               label: Text('Toggle Flash'),
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(vertical: 12),
//                 textStyle: TextStyle(fontSize: 18),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     cameraController.dispose();
//     super.dispose();
//   }
// }

// class DisplayScreen extends StatelessWidget {
//   final String data;

//   DisplayScreen({required this.data});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('QR Code Data'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.qr_code_2,
//                 size: 100,
//                 color: Colors.blue,
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Scanned QR Code Data:',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 data,
//                 style: TextStyle(fontSize: 24),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text('Scan Another QR Code'),
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//                   textStyle: TextStyle(fontSize: 18),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }







// class QRScanPage extends StatefulWidget {
//   @override
//   _QRScanPageState createState() => _QRScanPageState();
// }

// class _QRScanPageState extends State<QRScanPage> {
//   MobileScannerController cameraController = MobileScannerController();
//   bool isScanning = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('QR Code Scanner'),
//       ),
//       body: Stack(
//         children: [
//           MobileScanner(
//             controller: cameraController,
//             onDetect: (barcodeCapture) {
//               final Barcode? barcode = barcodeCapture.barcodes.first;
//               if (barcode != null && barcode.rawValue != null && isScanning) {
//                 setState(() {
//                   isScanning = false;
//                 });
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         DisplayScreen(data: barcode.rawValue!),
//                   ),
//                 ).then((_) {
//                   setState(() {
//                     isScanning = true;
//                   });
//                 });
//               }
//             },
//           ),
//           Align(
//             alignment: Alignment.center,
//             child: Container(
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Colors.red,
//                   width: 2.0,
//                 ),
//               ),
//               height: 200,
//               width: 200,
//             ),
//           ),
//           Positioned(
//             bottom: 20,
//             left: 20,
//             right: 20,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 cameraController.toggleTorch();
//               },
//               icon: Icon(Icons.flash_on),
//               label: Text('Toggle Flash'),
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(vertical: 12),
//                 textStyle: TextStyle(fontSize: 18),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     cameraController.dispose();
//     super.dispose();
//   }
// }

// class DisplayScreen extends StatelessWidget {
//   final String data;

//   DisplayScreen({required this.data});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('QR Code Data'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.qr_code_2,
//                 size: 100,
//                 color: Colors.blue,
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Scanned QR Code Data:',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 data,
//                 style: TextStyle(fontSize: 24),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text('Scan Another QR Code'),
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//                   textStyle: TextStyle(fontSize: 18),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
